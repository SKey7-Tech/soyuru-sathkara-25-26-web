import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/paper.dart';
import '../../repositories/paper_repository.dart';

/// DEV B — downloads a paper's PDF once and keeps it on the phone.
///
/// Files go in the application *support* directory, not the cache directory.
/// Android is free to delete the cache dir under storage pressure, and a
/// student who downloaded a paper on school wifi to read at home without data
/// must still have it that evening. Support dir is also not user-visible, so
/// it does not need the storage permission that writing to Downloads/ would.
class PdfCacheService {
  PdfCacheService(this._papers, this._dio);

  final PaperRepository _papers;
  final Dio _dio;

  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}papers');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> fileFor(Paper paper) async {
    final dir = await _dir();
    return File('${dir.path}${Platform.pathSeparator}${paper.cacheFileName}');
  }

  /// The cached file, or null if this paper has not been downloaded.
  ///
  /// Also treats a zero-byte file as absent: an interrupted write in an older
  /// build, or a disk-full failure, can leave one behind, and handing an empty
  /// file to the PDF viewer produces a baffling "corrupt document" error
  /// instead of an obvious "not downloaded yet".
  Future<File?> cachedFile(Paper paper) async {
    final file = await fileFor(paper);
    if (!await file.exists()) return null;
    if (await file.length() == 0) {
      await file.delete();
      return null;
    }
    return file;
  }

  /// Downloads the PDF, reporting progress as 0.0–1.0 (null when the server
  /// sends no Content-Length and the total is unknowable).
  ///
  /// Writes to a `.part` file and renames only on success. Without that, a
  /// connection dropping at 80% would leave a truncated file that
  /// [cachedFile] reports as ready, and the student gets a corrupt PDF with no
  /// way to re-download it.
  Future<File> download(
    Paper paper, {
    void Function(double? progress)? onProgress,
  }) async {
    final target = await fileFor(paper);
    final part = File('${target.path}.part');

    if (await part.exists()) await part.delete();

    final url = await _papers.pdfUrl(paper);

    try {
      await _dio.download(
        url,
        part.path,
        onReceiveProgress: (received, total) {
          onProgress?.call(total > 0 ? received / total : null);
        },
        options: Options(
          // Papers are up to ~8.6 MB and these students are often on 2G.
          // Dio's default receiveTimeout would abort a perfectly healthy slow
          // download; the connect timeout stays short so a dead network still
          // fails fast.
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 30),
          followRedirects: true,
          // Handle non-2xx ourselves so the error message can be useful.
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final downloaded = await part.length();
      if (downloaded == 0) {
        await part.delete();
        throw const FileSystemException('Downloaded file was empty');
      }

      // Size mismatch means the seed's size_bytes is stale or the upload was
      // truncated. Worth surfacing rather than caching a wrong file forever.
      final expected = paper.sizeBytes;
      if (expected != null && expected > 0 && downloaded != expected) {
        throw FileSystemException(
          'Size mismatch: expected $expected bytes, got $downloaded. '
          'Re-run scripts/upload_pdfs.mjs, or update size_bytes in the seed.',
        );
      }

      if (await target.exists()) await target.delete();
      final file = await part.rename(target.path);

      // Log after the file is safely in place, never before.
      await _papers.logDownload(paper.id);

      return file;
    } catch (_) {
      if (await part.exists()) {
        try {
          await part.delete();
        } catch (_) {
          /* nothing useful to do; the .part is skipped on the next attempt */
        }
      }
      rethrow;
    }
  }

  Future<void> remove(Paper paper) async {
    final file = await fileFor(paper);
    if (await file.exists()) await file.delete();
  }

  /// Total bytes held on the phone, for the Downloads screen footer.
  Future<int> totalCachedBytes() async {
    final dir = await _dir();
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is File && !entity.path.endsWith('.part')) {
        total += await entity.length();
      }
    }
    return total;
  }
}

// ----------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
    ),
  );
});

final pdfCacheServiceProvider = Provider<PdfCacheService>((ref) {
  return PdfCacheService(
    ref.watch(paperRepositoryProvider),
    ref.watch(dioProvider),
  );
});

// ----------------------------------------------------------------------
// Per-paper download state
// ----------------------------------------------------------------------

sealed class PaperDownloadState {
  const PaperDownloadState();
}

/// Not on the phone.
class PaperNotDownloaded extends PaperDownloadState {
  const PaperNotDownloaded();
}

/// In flight. [progress] is null when the total size is unknown.
class PaperDownloading extends PaperDownloadState {
  const PaperDownloading(this.progress);
  final double? progress;

  int? get percent => progress == null ? null : (progress! * 100).round();
}

/// On the phone and ready to open.
class PaperDownloaded extends PaperDownloadState {
  const PaperDownloaded(this.file);
  final File file;
}

/// The download failed. The file is not on the phone.
class PaperDownloadError extends PaperDownloadState {
  const PaperDownloadError(this.error);
  final Object error;
}

/// One controller per paper. Keyed on [Paper], whose == is by id.
class PaperDownloadController
    extends FamilyAsyncNotifier<PaperDownloadState, Paper> {
  /// A download outlives the widget that started it — the student can navigate
  /// away mid-transfer, which disposes this notifier while dio is still
  /// streaming bytes. Writing to `state` after that throws, so every emit
  /// checks this flag first. (Riverpod 2.x has no `ref.mounted`; onDispose is
  /// the supported way to know.)
  bool _disposed = false;

  @override
  Future<PaperDownloadState> build(Paper arg) async {
    ref.onDispose(() => _disposed = true);

    final file = await ref.read(pdfCacheServiceProvider).cachedFile(arg);
    return file == null ? const PaperNotDownloaded() : PaperDownloaded(file);
  }

  Future<void> start() async {
    // Ignore a second tap while a download is already running.
    if (state.valueOrNull is PaperDownloading) return;

    state = const AsyncData(PaperDownloading(null));

    try {
      final file = await ref.read(pdfCacheServiceProvider).download(
            arg,
            onProgress: (progress) {
              if (_disposed) return;
              state = AsyncData(PaperDownloading(progress));
            },
          );

      if (_disposed) return;
      state = AsyncData(PaperDownloaded(file));

      // The Downloads screen's list is now stale.
      ref.invalidate(downloadsProvider);
    } catch (error) {
      if (_disposed) return;
      state = AsyncData(PaperDownloadError(error));
    }
  }

  /// Deletes the local file. Keeps the `downloads` log row — the student
  /// downloaded it, and that history is what the Downloads screen shows.
  Future<void> removeFromPhone() async {
    await ref.read(pdfCacheServiceProvider).remove(arg);
    if (_disposed) return;
    state = const AsyncData(PaperNotDownloaded());
    ref.invalidate(downloadsProvider);
  }
}

final paperDownloadProvider = AsyncNotifierProvider.family<
    PaperDownloadController, PaperDownloadState, Paper>(
  PaperDownloadController.new,
);

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paper.dart';
import '../../repositories/paper_repository.dart';
import 'pdf_cache_service.dart';

/// DEV B. Reads a paper's PDF from the on-device copy.
///
/// Always renders from a local file, never from a URL. Syncfusion can stream
/// over the network, but re-fetching an 8 MB paper every time it is opened
/// would be unusable on the connections this app has to work on — and it would
/// mean the paper is not readable offline, which is the point of downloading.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key, required this.paperId});

  final String paperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final paper = ref.watch(paperProvider(paperId));

    return AsyncView(
      value: paper,
      onRetry: () => ref.invalidate(paperProvider(paperId)),
      loading: Scaffold(appBar: AppBar(), body: const LoadingView()),
      builder: (value) {
        if (value == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.description_outlined,
              title: l10n.emptyNoPapersTitle,
              message: l10n.pdfOpenFailed,
            ),
          );
        }
        return _PaperView(paper: value);
      },
    );
  }
}

class _PaperView extends ConsumerStatefulWidget {
  const _PaperView({required this.paper});

  final Paper paper;

  @override
  ConsumerState<_PaperView> createState() => _PaperViewState();
}

class _PaperViewState extends ConsumerState<_PaperView> {
  final PdfViewerController _pdfController = PdfViewerController();

  int _page = 1;
  int _pageCount = 0;

  /// Guards the auto-start below so it fires at most once per screen.
  bool _requestedDownload = false;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final download = ref.watch(paperDownloadProvider(widget.paper));

    final value = download.valueOrNull;

    // Reaching this screen is itself the request to read the paper, so if it is
    // not on the phone yet, fetch it rather than showing a Download button the
    // student has already effectively pressed.
    //
    // Scheduled off the build phase: modifying a provider during build throws.
    if (!download.isLoading && value is PaperNotDownloaded && !_requestedDownload) {
      _requestedDownload = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(paperDownloadProvider(widget.paper).notifier).start();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.paper.titleFor(language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (_pageCount > 0)
              Text(
                l10n.pdfPageOf(_page, _pageCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        toolbarHeight: 64,
      ),
      body: switch (value) {
        null => const LoadingView(),
        PaperNotDownloaded() => LoadingView(message: l10n.downloadStarting),
        PaperDownloading(:final progress) => _DownloadingView(
            progress: progress,
            sizeLabel: widget.paper.formattedSize,
          ),
        PaperDownloadError(:final error) => ErrorView(
            error: error,
            onRetry:
                ref.read(paperDownloadProvider(widget.paper).notifier).start,
          ),
        PaperDownloaded(:final file) => _viewer(file),
      },
    );
  }

  Widget _viewer(File file) {
    final l10n = AppLocalizations.of(context);

    return SfPdfViewer.file(
      file,
      controller: _pdfController,
      // Papers are read page by page rather than scrolled continuously, and
      // paginated layout keeps only the visible page rasterised — noticeably
      // lighter on a low-RAM phone with a 100-page document.
      pageLayoutMode: PdfPageLayoutMode.single,
      canShowScrollHead: true,
      canShowScrollStatus: false,
      enableDoubleTapZooming: true,
      onDocumentLoaded: (details) {
        if (!mounted) return;
        setState(() => _pageCount = details.document.pages.count);
      },
      onPageChanged: (details) {
        if (!mounted) return;
        setState(() => _page = details.newPageNumber);
      },
      onDocumentLoadFailed: (details) {
        if (!mounted) return;
        // A file that fails to parse is worse than a missing one: it will fail
        // again on every open. Drop the cached copy so the retry re-downloads
        // rather than re-reading the same broken bytes.
        ref.read(paperDownloadProvider(widget.paper).notifier).removeFromPhone();

        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(
            content: Text('${l10n.pdfOpenFailed}\n${details.description}'),
          ),
        );
      },
    );
  }
}

class _DownloadingView extends StatelessWidget {
  const _DownloadingView({required this.progress, required this.sizeLabel});

  final double? progress;
  final String? sizeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 14),
            Text(
              progress == null
                  ? l10n.downloadStarting
                  : l10n.downloadProgress((progress! * 100).round()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (sizeLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                sizeLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

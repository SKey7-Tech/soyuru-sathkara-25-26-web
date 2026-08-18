import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_language.dart';
import '../core/env.dart';
import '../core/supabase_client.dart';
import '../models/download_record.dart';
import '../models/paper.dart';
import '../services/auth_service.dart';

/// The set of filters the Papers screen can apply. A value of null means
/// "don't filter on this".
class PaperFilter {
  const PaperFilter({this.subjectId, this.medium, this.year, this.type});

  final String? subjectId;
  final AppLanguage? medium;
  final int? year;
  final PaperType? type;

  bool get isEmpty => medium == null && year == null && type == null;

  PaperFilter copyWith({
    String? subjectId,
    AppLanguage? medium,
    int? year,
    PaperType? type,
    bool clearMedium = false,
    bool clearYear = false,
    bool clearType = false,
  }) =>
      PaperFilter(
        subjectId: subjectId ?? this.subjectId,
        medium: clearMedium ? null : (medium ?? this.medium),
        year: clearYear ? null : (year ?? this.year),
        type: clearType ? null : (type ?? this.type),
      );

  PaperFilter cleared() => PaperFilter(subjectId: subjectId);

  @override
  bool operator ==(Object other) =>
      other is PaperFilter &&
      other.subjectId == subjectId &&
      other.medium == medium &&
      other.year == year &&
      other.type == type;

  @override
  int get hashCode => Object.hash(subjectId, medium, year, type);
}

/// DEV B — papers queries, Storage URLs and the downloads log.
///
/// The actual file transfer and on-device caching live in
/// features/pdf_viewer/pdf_cache_service.dart; this class only decides *where*
/// a PDF is and records that it was fetched.
class PaperRepository {
  PaperRepository(this._client, this._auth);

  final SupabaseClient _client;
  final AuthService _auth;

  static const _columns =
      'id, subject_id, year, paper_type, medium, title, title_si, title_ta, '
      'storage_path, size_bytes, has_answers';

  // ------------------------------------------------------------------
  // Queries
  // ------------------------------------------------------------------

  Future<List<Paper>> getPapers([PaperFilter filter = const PaperFilter()]) async {
    var query = _client.from('papers').select(_columns);

    if (filter.subjectId != null) {
      query = query.eq('subject_id', filter.subjectId!);
    }
    if (filter.medium != null) query = query.eq('medium', filter.medium!.code);
    if (filter.year != null) query = query.eq('year', filter.year!);
    if (filter.type != null) query = query.eq('paper_type', filter.type!.value);

    // Newest year first, then a stable alphabetical order so the list does not
    // reshuffle between loads (Postgres gives no order guarantee otherwise).
    final rows = await query
        .order('year', ascending: false, nullsFirst: false)
        // ascending: true — supabase-dart's .order() defaults to
        // descending, which would put Z-A as the tiebreaker.
        .order('title', ascending: true);

    return rows.map(Paper.fromMap).toList();
  }

  Future<Paper?> getPaper(String paperId) async {
    final row = await _client
        .from('papers')
        .select(_columns)
        .eq('id', paperId)
        .maybeSingle();

    return row == null ? null : Paper.fromMap(row);
  }

  // ------------------------------------------------------------------
  // Storage
  // ------------------------------------------------------------------

  /// A downloadable URL for the paper's PDF.
  ///
  /// Two branches, switched by [Env.bucketIsPublic] — see the long rationale in
  /// supabase/migrations/004_storage.sql. Public is the current setup and needs
  /// no network call at all; the signed branch is kept working so flipping the
  /// bucket to private is a one-constant change rather than a rewrite.
  Future<String> pdfUrl(Paper paper) async {
    final bucket = _client.storage.from(Env.resourcesBucket);

    if (Env.bucketIsPublic) {
      return bucket.getPublicUrl(paper.storagePath);
    }
    return bucket.createSignedUrl(paper.storagePath, Env.signedUrlTtlSeconds);
  }

  // ------------------------------------------------------------------
  // Downloads log
  // ------------------------------------------------------------------

  /// Records that this student downloaded this paper.
  ///
  /// Best effort by design: the PDF is already on the phone by the time this
  /// runs, so failing to write a log row must not be reported as a failed
  /// download. Returns whether the row was written.
  Future<bool> logDownload(String paperId) async {
    final userId = _auth.userId;
    if (userId == null) return false;

    try {
      await _client.from('downloads').upsert(
        {'user_id': userId, 'paper_id': paperId},
        onConflict: 'user_id,paper_id',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// The student's downloads, newest first, with the paper row joined in.
  Future<List<DownloadRecord>> getDownloads() async {
    final userId = _auth.userId;
    if (userId == null) return [];

    final rows = await _client
        .from('downloads')
        .select('user_id, paper_id, downloaded_at, papers!inner($_columns)')
        .eq('user_id', userId)
        .order('downloaded_at', ascending: false);

    return rows.map(DownloadRecord.fromMap).toList();
  }

  Future<void> removeDownloadLog(String paperId) async {
    final userId = _auth.userId;
    if (userId == null) return;

    await _client
        .from('downloads')
        .delete()
        .eq('user_id', userId)
        .eq('paper_id', paperId);
  }
}

// ----------------------------------------------------------------------
// Providers — DEV B
// ----------------------------------------------------------------------

final paperRepositoryProvider = Provider<PaperRepository>((ref) {
  return PaperRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(authServiceProvider),
  );
});

/// All papers, unfiltered. Filtering happens client-side in
/// [filteredPapersProvider] — with six rows today and a few dozen at most
/// after content entry, one cached fetch beats a network round trip per chip
/// tap, especially on the connections this app has to work on.
final allPapersProvider = FutureProvider<List<Paper>>((ref) {
  return ref.watch(paperRepositoryProvider).getPapers();
});

final paperProvider = FutureProvider.family<Paper?, String>((ref, paperId) {
  return ref.watch(paperRepositoryProvider).getPaper(paperId);
});

/// The selected filters, keyed by *scope*: null for the global Papers tab, or a
/// subject id for the Papers tab inside a subject.
///
/// Family-keyed rather than a single global notifier on purpose. The same list
/// widget is mounted twice — once per scope — and with shared state, choosing
/// "Tamil" inside Mathematics would silently filter the global tab too, and
/// clearing it in one place would empty the other. Each scope owns its chips.
final paperFilterProvider =
    NotifierProvider.family<PaperFilterController, PaperFilter, String?>(
  PaperFilterController.new,
);

class PaperFilterController extends FamilyNotifier<PaperFilter, String?> {
  @override
  PaperFilter build(String? arg) => PaperFilter(subjectId: arg);

  void setMedium(AppLanguage? medium) => state = medium == null
      ? state.copyWith(clearMedium: true)
      : state.copyWith(medium: medium);

  void setYear(int? year) => state =
      year == null ? state.copyWith(clearYear: true) : state.copyWith(year: year);

  void setType(PaperType? type) =>
      state = type == null ? state.copyWith(clearType: true) : state.copyWith(type: type);

  void clear() => state = state.cleared();
}

final filteredPapersProvider =
    Provider.family<AsyncValue<List<Paper>>, String?>((ref, scope) {
  final filter = ref.watch(paperFilterProvider(scope));

  return ref.watch(allPapersProvider).whenData((papers) {
    return papers.where((p) {
      if (filter.subjectId != null && p.subjectId != filter.subjectId) {
        return false;
      }
      if (filter.medium != null && p.medium != filter.medium) return false;
      if (filter.year != null && p.year != filter.year) return false;
      if (filter.type != null && p.paperType != filter.type) return false;
      return true;
    }).toList();
  });
});

/// Filter chip options, derived from the data that actually exists. Building
/// these from the rows rather than hardcoding them means a chip is never shown
/// for a year or medium with zero papers behind it.
final paperFilterOptionsProvider =
    Provider.family<PaperFilterOptions, String?>((ref, scope) {
  final papers = ref.watch(allPapersProvider).valueOrNull ?? const [];

  final relevant = scope == null
      ? papers
      : papers.where((p) => p.subjectId == scope).toList();

  final years = relevant.map((p) => p.year).whereType<int>().toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  return PaperFilterOptions(
    years: years,
    mediums: relevant.map((p) => p.medium).toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index)),
    types: relevant.map((p) => p.paperType).toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index)),
  );
});

class PaperFilterOptions {
  const PaperFilterOptions({
    required this.years,
    required this.mediums,
    required this.types,
  });

  final List<int> years;
  final List<AppLanguage> mediums;
  final List<PaperType> types;
}

final downloadsProvider = FutureProvider<List<DownloadRecord>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(paperRepositoryProvider).getDownloads();
});

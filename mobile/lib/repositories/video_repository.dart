import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/subject.dart';
import '../models/unit.dart';
import '../models/video.dart';
import '../models/watch_progress.dart';
import '../services/auth_service.dart';

/// DEV A — subjects / units / videos / watch progress.
///
/// Method signatures were agreed in Phase 0. Adding a method is fine; changing
/// an existing signature is not, without telling Dev B.
class VideoRepository {
  VideoRepository(this._client, this._auth);

  final SupabaseClient _client;
  final AuthService _auth;

  // ------------------------------------------------------------------
  // Content (public, readable with no session)
  // ------------------------------------------------------------------

  Future<List<Subject>> getSubjects() async {
    final rows = await _client
        .from('subjects')
        .select('id, name_en, name_si, name_ta, icon, color_hex, order_index')
        // ascending: true is NOT redundant — supabase-dart's .order()
        // defaults to DESCENDING (unlike supabase-js). Without it the
        // list comes back reversed: Discussion Part 20 before Part 1.
        .order('order_index', ascending: true);

    return rows.map(Subject.fromMap).toList();
  }

  /// Units for a subject, each carrying its video count and — when there is a
  /// session — how many of those the student has completed.
  ///
  /// Two queries total, not one per unit: on a 2G connection the difference
  /// between 2 round trips and 1+N is the difference between a usable screen
  /// and a hung one.
  Future<List<Unit>> getUnits(String subjectId) async {
    final rows = await _client
        .from('units')
        // videos(count) is a PostgREST aggregate; it arrives as
        // videos: [{count: n}] and Unit.fromMap unwraps it.
        .select(
          'id, subject_id, title_en, title_si, title_ta, order_index, videos(count)',
        )
        .eq('subject_id', subjectId)
        // ascending: true is NOT redundant — supabase-dart's .order()
        // defaults to DESCENDING (unlike supabase-js). Without it the
        // list comes back reversed: Discussion Part 20 before Part 1.
        .order('order_index', ascending: true);

    final units = rows.map(Unit.fromMap).toList();

    final completed = await _completedCountsByUnit();
    if (completed.isEmpty) return units;

    return units
        .map((u) => u.copyWith(completedCount: completed[u.id] ?? 0))
        .toList();
  }

  /// A single unit, fetched directly by id.
  ///
  /// Needed because the playlist screen is reachable by deep link, where the
  /// subject's unit list has never been loaded and there is nothing cached to
  /// look the title up in.
  Future<Unit?> getUnit(String unitId) async {
    final row = await _client
        .from('units')
        .select(
          'id, subject_id, title_en, title_si, title_ta, order_index, videos(count)',
        )
        .eq('id', unitId)
        .maybeSingle();

    return row == null ? null : Unit.fromMap(row);
  }

  Future<List<Video>> getVideos(String unitId) async {
    final rows = await _client
        .from('videos')
        .select(
          'id, unit_id, paper_id, youtube_video_id, title, duration_sec, '
          'thumbnail_url, order_index',
        )
        .eq('unit_id', unitId)
        // ascending: true is NOT redundant — supabase-dart's .order()
        // defaults to DESCENDING (unlike supabase-js). Without it the
        // list comes back reversed: Discussion Part 20 before Part 1.
        .order('order_index', ascending: true);

    return rows.map(Video.fromMap).toList();
  }

  Future<Video?> getVideo(String videoId) async {
    final row = await _client
        .from('videos')
        .select(
          'id, unit_id, paper_id, youtube_video_id, title, duration_sec, '
          'thumbnail_url, order_index',
        )
        .eq('id', videoId)
        .maybeSingle();

    return row == null ? null : Video.fromMap(row);
  }

  /// Discussion videos for a paper, ordered.
  ///
  /// Lives here rather than in PaperRepository because it is a `videos` query
  /// and this file owns that table — Dev B calls this instead of writing a
  /// second, differently-shaped videos query. Relies on videos.paper_id (see
  /// the DEVIATION note in 001_init_schema.sql).
  Future<List<Video>> getVideosForPaper(String paperId) async {
    final rows = await _client
        .from('videos')
        .select(
          'id, unit_id, paper_id, youtube_video_id, title, duration_sec, '
          'thumbnail_url, order_index',
        )
        .eq('paper_id', paperId)
        // ascending: true is NOT redundant — supabase-dart's .order()
        // defaults to DESCENDING (unlike supabase-js). Without it the
        // list comes back reversed: Discussion Part 20 before Part 1.
        .order('order_index', ascending: true);

    return rows.map(Video.fromMap).toList();
  }

  /// How many discussion videos each paper has, for the badge on the Papers
  /// screen. One query for every paper rather than one per card.
  Future<Map<String, int>> getVideoCountsByPaper() async {
    final rows = await _client
        .from('videos')
        .select('paper_id')
        .not('paper_id', 'is', null);

    final counts = <String, int>{};
    for (final row in rows) {
      final id = row['paper_id'] as String?;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  // ------------------------------------------------------------------
  // Watch progress (per user, requires a session)
  // ------------------------------------------------------------------

  /// Progress rows for one unit's videos, keyed by video id.
  Future<Map<String, WatchProgress>> getProgressForUnit(String unitId) async {
    final userId = _auth.userId;
    if (userId == null) return {};

    // !inner turns the embedded videos row into a join filter, so this returns
    // only progress rows belonging to this unit.
    final rows = await _client
        .from('watch_progress')
        .select('user_id, video_id, seconds_watched, completed, updated_at, '
            'videos!inner(unit_id)')
        .eq('user_id', userId)
        .eq('videos.unit_id', unitId);

    return {
      for (final row in rows)
        row['video_id'] as String: WatchProgress.fromMap(row),
    };
  }

  Future<WatchProgress?> getProgress(String videoId) async {
    final userId = _auth.userId;
    if (userId == null) return null;

    final row = await _client
        .from('watch_progress')
        .select('user_id, video_id, seconds_watched, completed, updated_at')
        .eq('user_id', userId)
        .eq('video_id', videoId)
        .maybeSingle();

    return row == null ? null : WatchProgress.fromMap(row);
  }

  /// Writes progress for a video.
  ///
  /// Silently does nothing when there is no session (anonymous sign-in
  /// disabled, or it failed while offline). That is intentional: a student
  /// watching a lesson must not be shown an error because a bookkeeping write
  /// could not happen. Returns whether the write actually went through.
  Future<bool> saveProgress(
    String videoId,
    int seconds,
    bool completed,
  ) async {
    final userId = _auth.userId;
    if (userId == null) return false;

    // Never let a bad player callback move progress backwards or negative.
    final safeSeconds = seconds < 0 ? 0 : seconds;

    await _client.from('watch_progress').upsert(
          WatchProgress(
            userId: userId,
            videoId: videoId,
            secondsWatched: safeSeconds,
            completed: completed,
          ).toUpsertMap(),
          // Matches the (user_id, video_id) primary key.
          onConflict: 'user_id,video_id',
        );
    return true;
  }

  /// Videos the student started but has not finished, newest first — the
  /// "Continue watching" row on Home.
  Future<List<ContinueWatchingItem>> getContinueWatching({
    int limit = 10,
  }) async {
    final userId = _auth.userId;
    if (userId == null) return [];

    final rows = await _client
        .from('watch_progress')
        .select(
          'user_id, video_id, seconds_watched, completed, updated_at, '
          'videos!inner(id, unit_id, paper_id, youtube_video_id, title, '
          'duration_sec, thumbnail_url, order_index)',
        )
        .eq('user_id', userId)
        .eq('completed', false)
        .gt('seconds_watched', 0)
        .order('updated_at', ascending: false)
        .limit(limit);

    return rows
        .map(
          (row) => ContinueWatchingItem(
            video: Video.fromMap(row['videos'] as Map<String, dynamic>),
            progress: WatchProgress.fromMap(row),
          ),
        )
        .toList();
  }

  /// unit_id -> number of completed videos, for the whole signed-in user.
  Future<Map<String, int>> _completedCountsByUnit() async {
    final userId = _auth.userId;
    if (userId == null) return {};

    final rows = await _client
        .from('watch_progress')
        .select('video_id, videos!inner(unit_id)')
        .eq('user_id', userId)
        .eq('completed', true);

    final counts = <String, int>{};
    for (final row in rows) {
      final unitId =
          (row['videos'] as Map<String, dynamic>)['unit_id'] as String;
      counts[unitId] = (counts[unitId] ?? 0) + 1;
    }
    return counts;
  }
}

/// A video plus the student's progress in it.
class ContinueWatchingItem {
  const ContinueWatchingItem({required this.video, required this.progress});

  final Video video;
  final WatchProgress progress;
}

// ----------------------------------------------------------------------
// Providers — DEV A
// ----------------------------------------------------------------------

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(authServiceProvider),
  );
});

final subjectsProvider = FutureProvider<List<Subject>>((ref) {
  return ref.watch(videoRepositoryProvider).getSubjects();
});

/// One subject, read out of the already-cached [subjectsProvider] list rather
/// than fetched again — the subject screen is always reached from Home, so the
/// list is warm and a second round trip would only add latency.
final subjectProvider = Provider.family<Subject?, String>((ref, subjectId) {
  final subjects = ref.watch(subjectsProvider).valueOrNull;
  if (subjects == null) return null;
  for (final subject in subjects) {
    if (subject.id == subjectId) return subject;
  }
  return null;
});

final unitsProvider =
    FutureProvider.family<List<Unit>, String>((ref, subjectId) {
  // Rebuilds after sign-in/out so the progress rings are for the right user.
  ref.watch(authStateProvider);
  return ref.watch(videoRepositoryProvider).getUnits(subjectId);
});

final unitProvider = FutureProvider.family<Unit?, String>((ref, unitId) {
  return ref.watch(videoRepositoryProvider).getUnit(unitId);
});

final videosProvider =
    FutureProvider.family<List<Video>, String>((ref, unitId) {
  return ref.watch(videoRepositoryProvider).getVideos(unitId);
});

final videoProvider = FutureProvider.family<Video?, String>((ref, videoId) {
  return ref.watch(videoRepositoryProvider).getVideo(videoId);
});

final unitProgressProvider =
    FutureProvider.family<Map<String, WatchProgress>, String>((ref, unitId) {
  ref.watch(authStateProvider);
  return ref.watch(videoRepositoryProvider).getProgressForUnit(unitId);
});

final continueWatchingProvider =
    FutureProvider<List<ContinueWatchingItem>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(videoRepositoryProvider).getContinueWatching();
});

/// Used by Dev B's Papers screen for the "N discussions" badge.
final paperVideoCountsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(videoRepositoryProvider).getVideoCountsByPaper();
});

/// Discussion videos for one paper — Dev B's paper detail sheet.
final paperVideosProvider =
    FutureProvider.family<List<Video>, String>((ref, paperId) {
  return ref.watch(videoRepositoryProvider).getVideosForPaper(paperId);
});

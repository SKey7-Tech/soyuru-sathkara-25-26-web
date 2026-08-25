/// SHARED — frozen after Phase 0. Mirrors the `watch_progress` table.
///
/// Primary key is (user_id, video_id), so writes are upserts, never inserts.
class WatchProgress {
  const WatchProgress({
    required this.userId,
    required this.videoId,
    this.secondsWatched = 0,
    this.completed = false,
    this.updatedAt,
  });

  final String userId;
  final String videoId;
  final int secondsWatched;
  final bool completed;
  final DateTime? updatedAt;

  factory WatchProgress.fromMap(Map<String, dynamic> map) => WatchProgress(
        userId: map['user_id'] as String,
        videoId: map['video_id'] as String,
        secondsWatched: (map['seconds_watched'] as int?) ?? 0,
        completed: (map['completed'] as bool?) ?? false,
        updatedAt: map['updated_at'] == null
            ? null
            : DateTime.parse(map['updated_at'] as String).toLocal(),
      );

  /// updated_at is deliberately omitted: the watch_progress_touch trigger sets
  /// it server-side. A phone with a wrong clock — common on cheap devices that
  /// have been factory reset — would otherwise poison "continue watching"
  /// ordering with timestamps from 1970 or 2035.
  Map<String, dynamic> toUpsertMap() => {
        'user_id': userId,
        'video_id': videoId,
        'seconds_watched': secondsWatched,
        'completed': completed,
      };

  /// Fraction watched, when the video's duration is known.
  ///
  /// Returns 1.0 for a completed video regardless of duration, because
  /// duration_sec is null for every seeded row and a finished video must still
  /// render a full ring.
  double progressFraction(int? durationSec) {
    if (completed) return 1.0;
    if (durationSec == null || durationSec <= 0) return 0.0;
    return (secondsWatched / durationSec).clamp(0.0, 1.0);
  }

  bool get hasStarted => secondsWatched > 0 || completed;

  WatchProgress copyWith({int? secondsWatched, bool? completed}) =>
      WatchProgress(
        userId: userId,
        videoId: videoId,
        secondsWatched: secondsWatched ?? this.secondsWatched,
        completed: completed ?? this.completed,
        updatedAt: updatedAt,
      );
}

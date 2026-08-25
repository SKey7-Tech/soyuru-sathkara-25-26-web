/// SHARED — frozen after Phase 0. Mirrors the `videos` table.
class Video {
  const Video({
    required this.id,
    required this.unitId,
    required this.youtubeVideoId,
    required this.title,
    this.paperId,
    this.durationSec,
    this.thumbnailUrl,
    this.orderIndex = 0,
  });

  final String id;
  final String unitId;

  /// The 11-char YouTube ID, not a URL. The website stores full watch URLs
  /// (app/data/papers.ts) and the seed script strips them down to this, because
  /// youtube_player_iframe wants the bare ID and parsing a URL on every build
  /// is wasted work.
  final String youtubeVideoId;

  final String title;

  /// The paper this video discusses. Nullable — see the DEVIATION note in
  /// supabase/migrations/001_init_schema.sql.
  final String? paperId;

  /// Null for every seeded row: durations need the YouTube Data API, which v1
  /// deliberately avoids. The UI must not assume this is present.
  final int? durationSec;

  final String? thumbnailUrl;
  final int orderIndex;

  factory Video.fromMap(Map<String, dynamic> map) => Video(
        id: map['id'] as String,
        unitId: map['unit_id'] as String,
        youtubeVideoId: map['youtube_video_id'] as String,
        title: map['title'] as String,
        paperId: map['paper_id'] as String?,
        durationSec: map['duration_sec'] as int?,
        thumbnailUrl: map['thumbnail_url'] as String?,
        orderIndex: (map['order_index'] as int?) ?? 0,
      );

  /// Derived, so a row with a null thumbnail_url still renders an image.
  /// i.ytimg.com paths are stable and need no API key.
  String get effectiveThumbnailUrl =>
      thumbnailUrl ?? 'https://i.ytimg.com/vi/$youtubeVideoId/hqdefault.jpg';

  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeVideoId';

  /// 'm:ss' / 'h:mm:ss', or null when the duration is unknown.
  String? get formattedDuration {
    final total = durationSec;
    if (total == null || total <= 0) return null;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
  }

  @override
  bool operator ==(Object other) => other is Video && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

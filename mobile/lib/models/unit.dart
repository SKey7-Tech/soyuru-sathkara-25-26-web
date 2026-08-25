import '../core/app_language.dart';

/// SHARED — frozen after Phase 0. Mirrors the `units` table.
class Unit {
  const Unit({
    required this.id,
    required this.subjectId,
    required this.titleEn,
    required this.titleSi,
    required this.titleTa,
    this.orderIndex = 0,
    this.videoCount = 0,
    this.completedCount = 0,
  });

  final String id;
  final String subjectId;
  final String titleEn;
  final String titleSi;
  final String titleTa;
  final int orderIndex;

  /// Not columns — filled in by VideoRepository.getUnits() from an aggregate
  /// count and the caller's watch_progress rows, so the unit list can draw a
  /// progress ring without a second query per row.
  final int videoCount;
  final int completedCount;

  factory Unit.fromMap(Map<String, dynamic> map) {
    // PostgREST returns an embedded aggregate as videos: [{count: n}].
    var count = 0;
    final embedded = map['videos'];
    if (embedded is List && embedded.isNotEmpty) {
      count = (embedded.first as Map)['count'] as int? ?? 0;
    } else if (embedded is Map) {
      count = embedded['count'] as int? ?? 0;
    }

    return Unit(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      titleEn: map['title_en'] as String,
      titleSi: map['title_si'] as String,
      titleTa: map['title_ta'] as String,
      orderIndex: (map['order_index'] as int?) ?? 0,
      videoCount: count,
    );
  }

  String titleFor(AppLanguage language) => switch (language) {
        AppLanguage.en => titleEn,
        AppLanguage.si => titleSi,
        AppLanguage.ta => titleTa,
      };

  /// 0.0–1.0. Returns 0 for an empty unit rather than dividing by zero — Hard
  /// Level and Medium Level (Tamil) have no videos yet, so this path is live.
  double get progress =>
      videoCount == 0 ? 0 : (completedCount / videoCount).clamp(0.0, 1.0);

  bool get isComplete => videoCount > 0 && completedCount >= videoCount;

  Unit copyWith({int? videoCount, int? completedCount}) => Unit(
        id: id,
        subjectId: subjectId,
        titleEn: titleEn,
        titleSi: titleSi,
        titleTa: titleTa,
        orderIndex: orderIndex,
        videoCount: videoCount ?? this.videoCount,
        completedCount: completedCount ?? this.completedCount,
      );

  @override
  bool operator ==(Object other) => other is Unit && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

import '../core/app_language.dart';

/// Values allowed by the `paper_type` check constraint.
enum PaperType {
  past('past'),
  model('model'),
  term('term'),
  notes('notes');

  const PaperType(this.value);
  final String value;

  static PaperType fromValue(String? value) {
    for (final t in values) {
      if (t.value == value) return t;
    }
    return PaperType.past; // matches the column default
  }
}

/// SHARED — frozen after Phase 0. Mirrors the `papers` table.
class Paper {
  const Paper({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.medium,
    required this.storagePath,
    this.titleSi,
    this.titleTa,
    this.year,
    this.paperType = PaperType.past,
    this.sizeBytes,
    this.hasAnswers = false,
  });

  final String id;
  final String subjectId;

  /// English title. Always present.
  final String title;

  /// Nullable translations — see the SECOND DEVIATION note in
  /// supabase/migrations/001_init_schema.sql.
  final String? titleSi;
  final String? titleTa;

  /// The language the PDF itself is written in. Distinct from the UI language:
  /// a student reading the app in English may still want the Tamil-medium
  /// paper. This is what the Papers screen filters on.
  final AppLanguage medium;

  /// Path inside the 'resources' bucket, e.g. 'papers/Easy-Level.pdf'.
  final String storagePath;

  final int? year;
  final PaperType paperType;
  final int? sizeBytes;
  final bool hasAnswers;

  factory Paper.fromMap(Map<String, dynamic> map) => Paper(
        id: map['id'] as String,
        subjectId: map['subject_id'] as String,
        title: map['title'] as String,
        titleSi: map['title_si'] as String?,
        titleTa: map['title_ta'] as String?,
        medium: AppLanguage.fromCode(map['medium'] as String?),
        storagePath: map['storage_path'] as String,
        year: map['year'] as int?,
        paperType: PaperType.fromValue(map['paper_type'] as String?),
        sizeBytes: (map['size_bytes'] as num?)?.toInt(),
        hasAnswers: (map['has_answers'] as bool?) ?? false,
      );

  /// Falls back to the English title when a translation has not been entered,
  /// which is strictly better than showing an empty row.
  String titleFor(AppLanguage language) => switch (language) {
        AppLanguage.en => title,
        AppLanguage.si => _orFallback(titleSi),
        AppLanguage.ta => _orFallback(titleTa),
      };

  String _orFallback(String? value) =>
      (value == null || value.trim().isEmpty) ? title : value;

  /// Local filename used by the PDF cache. The storage path is unique
  /// (papers_storage_path_key), so flattening it cannot collide, and keeping
  /// the .pdf suffix lets Android's viewer intent recognise the file.
  String get cacheFileName => storagePath.replaceAll('/', '_');

  /// Human-readable size, shown next to the download button so a student on a
  /// metered connection knows what an 8 MB tap will cost them.
  String? get formattedSize {
    final bytes = sizeBytes;
    if (bytes == null || bytes <= 0) return null;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  bool operator ==(Object other) => other is Paper && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

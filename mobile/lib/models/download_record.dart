import 'paper.dart';

/// SHARED — frozen after Phase 0. Mirrors the `downloads` table.
class DownloadRecord {
  const DownloadRecord({
    required this.userId,
    required this.paperId,
    required this.downloadedAt,
    this.paper,
  });

  final String userId;
  final String paperId;
  final DateTime downloadedAt;

  /// Joined `papers` row, when the query embedded it. The Downloads screen
  /// needs the title and size, and one join beats N follow-up queries on a
  /// slow connection.
  final Paper? paper;

  factory DownloadRecord.fromMap(Map<String, dynamic> map) {
    final embedded = map['papers'];
    return DownloadRecord(
      userId: map['user_id'] as String,
      paperId: map['paper_id'] as String,
      downloadedAt:
          DateTime.parse(map['downloaded_at'] as String).toLocal(),
      paper: embedded is Map<String, dynamic>
          ? Paper.fromMap(embedded)
          : null,
    );
  }
}

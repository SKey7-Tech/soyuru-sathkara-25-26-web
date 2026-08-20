import '../core/app_language.dart';

/// SHARED — added in Phase 0 alongside the other models. Mirrors `profiles`.
///
/// Created server-side by the on_auth_user_created trigger
/// (supabase/migrations/003_profile_trigger.sql), so the app only ever reads
/// and updates this row — it never inserts one.
class Profile {
  const Profile({
    required this.id,
    this.displayName,
    this.medium = AppLanguage.en,
    this.createdAt,
  });

  final String id;

  /// Null for anonymous students, who have no email to derive a name from.
  final String? displayName;

  /// Preferred language, synced with the on-device setting so it follows a
  /// student to a new phone once they sign in.
  final AppLanguage medium;

  final DateTime? createdAt;

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        displayName: map['display_name'] as String?,
        medium: AppLanguage.fromCode(map['medium'] as String?),
        createdAt: map['created_at'] == null
            ? null
            : DateTime.parse(map['created_at'] as String).toLocal(),
      );

  Profile copyWith({String? displayName, AppLanguage? medium}) => Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        medium: medium ?? this.medium,
        createdAt: createdAt,
      );
}

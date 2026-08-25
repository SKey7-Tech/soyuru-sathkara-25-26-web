/// Build-time configuration. SHARED — do not edit without telling the other dev.
///
/// ## About the key
///
/// [supabasePublishableKey] is bundled in the app, and that is correct — a
/// publishable key is *designed* to ship inside client code. It grants nothing
/// on its own: everything it can reach is decided by the RLS policies in
/// supabase/migrations/002_rls_policies.sql, which is why that file is the one
/// worth reviewing carefully.
///
/// It is NOT the service_role key. That one bypasses RLS entirely, must never
/// appear in this app, and is only ever used by scripts/upload_pdfs.mjs from a
/// shell.
///
/// To point a build at a different project (a staging branch, say) without
/// editing this file:
///
///   flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=your-key \
///               --dart-define=SUPABASE_URL=https://your-ref.supabase.co
///
/// The older `SUPABASE_ANON_KEY` define is still honoured, so existing scripts
/// and launch configs keep working.
library;

class Env {
  const Env._();

  /// Project ref atvpbxxzpnhjtsuuzmfu — matches the server in .mcp.json.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://atvpbxxzpnhjtsuuzmfu.supabase.co',
  );

  /// Resolution order: SUPABASE_PUBLISHABLE_KEY, then the legacy
  /// SUPABASE_ANON_KEY, then the bundled default.
  ///
  /// `bool.hasEnvironment` rather than checking the string for emptiness,
  /// because `String.isNotEmpty` is not a constant expression and this has to
  /// stay const to be usable as a default.
  static const String supabasePublishableKey =
      bool.hasEnvironment('SUPABASE_PUBLISHABLE_KEY')
          ? String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY')
          : String.fromEnvironment(
              'SUPABASE_ANON_KEY',
              defaultValue: _bundledPublishableKey,
            );

  static const String _bundledPublishableKey =
      'sb_publishable_Mklmm32xGBNWc5Agdjph9g_PGqh56s4';

  /// Storage bucket holding every PDF. Matches 004_storage.sql.
  static const String resourcesBucket = 'resources';

  /// Whether the bucket is public. See the long comment in 004_storage.sql —
  /// flip this to false if you make the bucket private, and PaperRepository
  /// will switch to signed URLs. Nothing else needs to change.
  static const bool bucketIsPublic = true;

  /// How long a signed URL stays valid, if [bucketIsPublic] is false.
  /// Generous on purpose: students on 2G may take a while to finish an 8 MB
  /// download, and a URL expiring mid-transfer is a miserable bug to debug.
  static const int signedUrlTtlSeconds = 60 * 60 * 6;

  /// False only if someone passes an explicitly empty --dart-define, which
  /// overrides the bundled default with nothing and would otherwise fail deep
  /// inside the SDK with an unhelpful message.
  static bool get isConfigured => supabasePublishableKey.isNotEmpty;

  static const String missingKeyMessage = '''
The Supabase key resolved to an empty string.

This happens when a --dart-define is passed with no value, e.g.
  --dart-define=SUPABASE_ANON_KEY=
(often because the environment variable behind it is unset).

Either drop the define entirely to use the bundled key, or give it a real
value from the Supabase dashboard:
  Project Settings > API keys > Publishable key
''';
}

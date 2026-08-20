import 'dart:ui';

/// SHARED — frozen after Phase 0.
///
/// The three languages, in one place. The string values are exactly the values
/// allowed by the `medium` check constraint in the database
/// (`check (medium in ('si','en','ta'))`), which is why this doubles as both
/// "UI language" and "paper medium". Changing a code here without changing the
/// constraint will produce runtime insert failures on profiles.medium.
enum AppLanguage {
  si('si', 'සිංහල'),
  en('en', 'English'),
  ta('ta', 'தமிழ்');

  const AppLanguage(this.code, this.nativeName);

  /// Matches profiles.medium and papers.medium.
  final String code;

  /// Always shown in its own script — a student who cannot read the current UI
  /// language still has to be able to find their own in the language picker.
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code, {AppLanguage fallback = en}) {
    for (final l in values) {
      if (l.code == code) return l;
    }
    return fallback;
  }

  /// Picks a starting language from the device locale, so a phone set to
  /// Sinhala opens in Sinhala rather than making the student hunt for it.
  static AppLanguage fromLocale(Locale locale) =>
      fromCode(locale.languageCode);
}

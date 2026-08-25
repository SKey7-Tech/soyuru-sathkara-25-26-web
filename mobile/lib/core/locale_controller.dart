import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'app_language.dart';

/// Overridden in main() with the already-loaded instance, so no screen has to
/// await SharedPreferences and the first frame can be built synchronously.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('sharedPrefsProvider was not overridden in main()'),
);

/// SHARED — the app's current language.
///
/// Stored in two places, deliberately:
///   * SharedPreferences — survives restarts and works with no network and no
///     session, so the app opens in the right language offline.
///   * profiles.medium — follows the student to a new phone once signed in.
///
/// The device copy wins on read. The server copy is only adopted when the
/// device has no stored choice ([adoptFromProfile]), which is exactly the
/// "signed in on a new phone" case. Doing it the other way round would let a
/// stale server value silently override a choice the student just made.
class LocaleController extends Notifier<AppLanguage> {
  static const _prefsKey = 'app_language';

  @override
  AppLanguage build() {
    final stored = ref.read(sharedPrefsProvider).getString(_prefsKey);
    if (stored != null) return AppLanguage.fromCode(stored);

    // No stored choice: follow the phone. A device set to Sinhala should not
    // open in English and make the student hunt through Settings.
    return AppLanguage.fromLocale(
      PlatformDispatcher.instance.locale,
    );
  }

  bool get hasExplicitChoice =>
      ref.read(sharedPrefsProvider).getString(_prefsKey) != null;

  /// Called when the student picks a language.
  Future<void> setLanguage(AppLanguage language) async {
    if (language == state) return;
    state = language;

    await ref.read(sharedPrefsProvider).setString(_prefsKey, language.code);

    // Best effort. A failed sync must not undo the language change the student
    // can already see on screen, so this swallows its error.
    try {
      await ref.read(authServiceProvider).updateProfile(medium: language);
    } catch (_) {
      /* offline or no session — the device copy is still correct */
    }
  }

  /// Adopts the server-side preference, but only when this device has no
  /// explicit choice of its own. Safe to call repeatedly.
  void adoptFromProfile(AppLanguage language) {
    if (hasExplicitChoice) return;
    if (language == state) return;
    state = language;
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, AppLanguage>(LocaleController.new);

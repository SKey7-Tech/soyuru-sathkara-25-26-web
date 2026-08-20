import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/env.dart';
import 'core/locale_controller.dart';
import 'core/supabase_client.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail with an explanation rather than a crash when the anon key is missing.
  if (!Env.isConfigured) {
    runApp(const ConfigErrorApp(message: Env.missingKeyMessage));
    return;
  }

  // Loaded before runApp so LocaleController.build() is synchronous and the
  // very first frame is already in the right language — no English flash for a
  // Sinhala or Tamil student.
  final prefs = await SharedPreferences.getInstance();

  await initSupabase();

  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );

  // Anonymous session, so watch progress works without a signup screen.
  // Never throws — see AuthService.ensureSession.
  await container.read(authServiceProvider).ensureSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SoyuruSathkaraApp(),
    ),
  );
}

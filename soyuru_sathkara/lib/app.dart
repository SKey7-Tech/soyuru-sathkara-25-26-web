import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_language.dart';
import 'core/locale_controller.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'services/auth_service.dart';

/// SHARED.
class SoyuruSathkaraApp extends ConsumerStatefulWidget {
  const SoyuruSathkaraApp({super.key});

  @override
  ConsumerState<SoyuruSathkaraApp> createState() => _SoyuruSathkaraAppState();
}

class _SoyuruSathkaraAppState extends ConsumerState<SoyuruSathkaraApp> {
  // Built once. Rebuilding the router on every app rebuild would reset the
  // navigation stack, so it must not live in build().
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeControllerProvider);

    // When a student signs in on a new phone, take the language they chose on
    // their old one — but only if this device has no choice of its own.
    // See LocaleController.adoptFromProfile.
    ref.listen(profileProvider, (previous, next) {
      final profile = next.valueOrNull;
      if (profile == null) return;
      ref.read(localeControllerProvider.notifier).adoptFromProfile(
            profile.medium,
          );
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Follows the phone. globals.css on the website does the same thing with
      // prefers-color-scheme, so the two stay consistent.
      themeMode: ThemeMode.system,

      locale: language.locale,
      supportedLocales: AppLanguage.values.map((l) => l.locale).toList(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routerConfig: _router,
    );
  }
}

/// Shown instead of the app when SUPABASE_ANON_KEY was not passed at build
/// time. A blank screen or a raw exception would send these two devs hunting
/// through Supabase for a problem that is entirely in their run command.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.build_circle_outlined, size: 44),
                  const SizedBox(height: 16),
                  const Text(
                    'Soyuru Sathkara is not configured',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

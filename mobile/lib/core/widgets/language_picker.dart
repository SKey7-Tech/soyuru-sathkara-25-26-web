import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_language.dart';
import '../locale_controller.dart';

/// SHARED. Opens the language chooser.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider);

    return SafeArea(
      // RadioGroup owns the selection for its subtree. RadioListTile's own
      // groupValue/onChanged were deprecated after Flutter 3.32.
      child: RadioGroup<AppLanguage>(
        groupValue: current,
        onChanged: (value) async {
          if (value == null) return;
          await ref.read(localeControllerProvider.notifier).setLanguage(value);
          if (context.mounted) Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final language in AppLanguage.values)
              RadioListTile<AppLanguage>(
                value: language,
                // Every option is labelled in its own script, never translated
                // into the language currently on screen. A Tamil student who
                // opens the app in Sinhala by accident has to be able to find
                // "தமிழ்" — "දෙමළ" would be no help at all.
                title: Text(language.nativeName),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// App-bar button that opens the picker.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.translate_rounded),
      tooltip: 'Language / භාෂාව / மொழி',
      onPressed: () => showLanguagePicker(context),
    );
  }
}

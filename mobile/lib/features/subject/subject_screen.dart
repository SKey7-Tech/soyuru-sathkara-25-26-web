import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/video_repository.dart';
import '../papers/papers_screen.dart';
import '../units/unit_list_screen.dart';

/// DEV A owns this shell. The two tab bodies are owned separately:
///   * Videos tab -> UnitListView          (Dev A, features/units/)
///   * Papers tab -> PapersListView        (Dev B, features/papers/)
///
/// Neither dev needs to edit this file to work on their tab.
class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final subject = ref.watch(subjectProvider(subjectId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Null while the subjects list is still loading, or on a deep link
          // straight into this route. Falling back to the app name beats a
          // flash of "null" or an empty bar.
          title: Text(subject?.nameFor(language) ?? l10n.appTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.subjectTabVideos),
              Tab(text: l10n.subjectTabPapers),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UnitListView(subjectId: subjectId),
            PapersListView(subjectId: subjectId),
          ],
        ),
      ),
    );
  }
}

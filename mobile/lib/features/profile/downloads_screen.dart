import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paper.dart';
import '../../repositories/paper_repository.dart';
import '../../router.dart';
import '../pdf_viewer/pdf_cache_service.dart';

/// DEV B. Papers this student has downloaded before.
///
/// Two different facts are shown, and keeping them apart matters:
///   * the `downloads` table row — "you downloaded this", which survives a
///     reinstall and follows a signed-in student to a new phone;
///   * the cached file — "it is on THIS phone", which does not.
///
/// So a row can be listed here and still need re-downloading, and the tile says
/// which case it is instead of offering an Open button that would fail.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final downloads = ref.watch(downloadsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(downloadsProvider);
          await ref.read(downloadsProvider.future);
        },
        child: AsyncView(
          value: downloads,
          onRetry: () => ref.invalidate(downloadsProvider),
          builder: (list) {
            final papers = [
              for (final record in list)
                if (record.paper != null) record.paper!,
            ];

            if (papers.isEmpty) {
              return EmptyState(
                icon: Icons.download_outlined,
                title: l10n.downloadsEmptyTitle,
                message: l10n.downloadsEmptyMessage,
                action: FilledButton.tonalIcon(
                  onPressed: () => context.goNamed(Routes.papers),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: Text(l10n.navPapers),
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: papers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _DownloadTile(paper: papers[index]),
            );
          },
        ),
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.paper});

  final Paper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final language = ref.watch(localeControllerProvider);

    final state = ref.watch(paperDownloadProvider(paper));
    final controller = ref.read(paperDownloadProvider(paper).notifier);
    final value = state.valueOrNull;

    final onPhone = value is PaperDownloaded;
    final downloading = value is PaperDownloading;

    return ListTile(
      leading: Icon(
        onPhone
            ? Icons.offline_pin_rounded
            : Icons.cloud_download_outlined,
        color: onPhone ? colors.tertiary : colors.onSurfaceVariant,
      ),
      title: Text(
        paper.titleFor(language),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (onPhone) l10n.downloadsOnThisPhone else l10n.downloadsNotOnThisPhone,
          if (paper.formattedSize != null) paper.formattedSize!,
        ].join(' · '),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: downloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<_DownloadAction>(
              onSelected: (action) async {
                switch (action) {
                  case _DownloadAction.open:
                    context.pushNamed(
                      Routes.pdfViewer,
                      pathParameters: {'paperId': paper.id},
                    );
                  case _DownloadAction.download:
                    await controller.start();
                  case _DownloadAction.remove:
                    await controller.removeFromPhone();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.downloadsRemoved)),
                    );
                }
              },
              itemBuilder: (context) => [
                if (onPhone)
                  PopupMenuItem(
                    value: _DownloadAction.open,
                    child: Text(l10n.actionOpen),
                  )
                else
                  PopupMenuItem(
                    value: _DownloadAction.download,
                    child: Text(l10n.actionDownload),
                  ),
                if (onPhone)
                  PopupMenuItem(
                    value: _DownloadAction.remove,
                    child: Text(l10n.downloadsRemove),
                  ),
              ],
            ),
      // Tapping the row opens the viewer, which downloads first if needed —
      // so the row is never a dead end even when the file is gone.
      onTap: downloading
          ? null
          : () => context.pushNamed(
                Routes.pdfViewer,
                pathParameters: {'paperId': paper.id},
              ),
    );
  }
}

enum _DownloadAction { open, download, remove }

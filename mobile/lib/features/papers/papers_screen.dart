import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/language_picker.dart';
import '../../core/widgets/loading_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paper.dart';
import '../../repositories/paper_repository.dart';
import '../../repositories/video_repository.dart';
import '../../router.dart';
import '../pdf_viewer/pdf_cache_service.dart';
import 'widgets/filter_chips.dart';

/// DEV B. Tab 2 — every subject's papers.
class PapersScreen extends ConsumerWidget {
  const PapersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.navPapers),
            Text(
              l10n.papersSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        toolbarHeight: 68,
        actions: const [LanguageButton()],
      ),
      body: const PapersListView(),
    );
  }
}

/// DEV B. The list body, reused in two places: the global Papers tab
/// ([subjectId] null) and a subject's Papers tab ([subjectId] set).
class PapersListView extends ConsumerWidget {
  const PapersListView({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final papers = ref.watch(filteredPapersProvider(subjectId));
    final filter = ref.watch(paperFilterProvider(subjectId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allPapersProvider);
        ref.invalidate(paperVideoCountsProvider);
        await ref.read(allPapersProvider.future);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: PaperFilterChips(scope: subjectId),
          ),
          Expanded(
            child: AsyncView(
              value: papers,
              onRetry: () => ref.invalidate(allPapersProvider),
              loading: const _PapersSkeleton(),
              builder: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.description_outlined,
                    title: l10n.emptyNoPapersTitle,
                    message: l10n.emptyNoPapersMessage,
                    action: filter.isEmpty
                        ? null
                        : OutlinedButton.icon(
                            onPressed: ref
                                .read(paperFilterProvider(subjectId).notifier)
                                .clear,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(l10n.filterClear),
                          ),
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _PaperCard(paper: list[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperCard extends ConsumerWidget {
  const _PaperCard({required this.paper});

  final Paper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final colors = Theme.of(context).colorScheme;

    final download = ref.watch(paperDownloadProvider(paper));
    final videoCount =
        ref.watch(paperVideoCountsProvider).valueOrNull?[paper.id] ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    paper.paperType == PaperType.notes
                        ? Icons.sticky_note_2_outlined
                        : Icons.description_outlined,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.titleFor(language),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Badge(text: paperTypeLabel(l10n, paper.paperType)),
                          _Badge(text: mediumLabel(l10n, paper.medium)),
                          if (paper.year != null)
                            _Badge(text: '${paper.year}'),
                          if (paper.formattedSize != null)
                            _Badge(text: paper.formattedSize!),
                          if (paper.hasAnswers)
                            _Badge(text: l10n.paperWithAnswers),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DownloadRow(paper: paper, state: download),
            if (videoCount > 0) ...[
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _showDiscussions(context, ref),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                  // Reuses the website's own wording ("See videos" /
                  // "වීඩියෝ බලන්න" / "வீடியோக்களைக் காண்க") so a student who
                  // used the site recognises the control.
                  label: Text(
                    '${l10n.paperSeeVideos} · '
                    '${l10n.paperDiscussionCount(videoCount)}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDiscussions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _DiscussionsSheet(paper: paper),
    );
  }
}

/// The download / open control, driven entirely by [PaperDownloadState].
class _DownloadRow extends ConsumerWidget {
  const _DownloadRow({required this.paper, required this.state});

  final Paper paper;
  final AsyncValue<PaperDownloadState> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(paperDownloadProvider(paper).notifier);

    // The initial cache check. Showing a disabled button beats letting the
    // student tap "Download" for a file that is already on the phone.
    if (state.isLoading) {
      return const SizedBox(
        height: 48,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SkeletonBox(width: 130, height: 36, borderRadius: 12),
        ),
      );
    }

    final value = state.valueOrNull ?? const PaperNotDownloaded();

    return switch (value) {
      PaperDownloading(:final progress) => Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progress == null
                  ? l10n.downloadStarting
                  : l10n.downloadProgress((progress * 100).round()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      PaperDownloaded() => Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.pushNamed(
                  Routes.pdfViewer,
                  pathParameters: {'paperId': paper.id},
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(l10n.actionOpen),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: controller.removeFromPhone,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.downloadsRemove,
            ),
          ],
        ),
      PaperDownloadError(:final error) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ErrorView.isOffline(error)
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ErrorView.isOffline(error)
                        ? l10n.downloadNeedsConnection
                        : l10n.downloadFailed,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.start,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      PaperNotDownloaded() => Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: controller.start,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(
              paper.formattedSize == null
                  ? l10n.actionDownload
                  : '${l10n.actionDownload} · ${paper.formattedSize}',
            ),
          ),
        ),
    };
  }
}

/// Discussion videos for one paper. Uses videos.paper_id, and reaches Dev A's
/// provider rather than writing a second videos query.
class _DiscussionsSheet extends ConsumerWidget {
  const _DiscussionsSheet({required this.paper});

  final Paper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final videos = ref.watch(paperVideosProvider(paper.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.playerRelatedVideos,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paper.titleFor(language),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: AsyncView(
                value: videos,
                onRetry: () => ref.invalidate(paperVideosProvider(paper.id)),
                builder: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      icon: Icons.play_circle_outline_rounded,
                      title: l10n.emptyNoVideosTitle,
                      message: l10n.emptyNoVideosMessage,
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final video = list[index];
                      return ListTile(
                        leading: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing:
                            const Icon(Icons.play_arrow_rounded, size: 20),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.pushNamed(
                            Routes.player,
                            pathParameters: {
                              'unitId': video.unitId,
                              'videoId': video.id,
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _PapersSkeleton extends StatelessWidget {
  const _PapersSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 38, height: 38, borderRadius: 10),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 170, height: 14),
                        SizedBox(height: 8),
                        SkeletonBox(width: 120, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              SkeletonBox(width: 140, height: 36, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/language_picker.dart';
import '../../core/widgets/loading_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/subject.dart';
import '../../repositories/video_repository.dart';
import '../../router.dart';

/// DEV A. Subject grid plus the continue-watching row.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.appTitle),
            Text(
              l10n.homeSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        toolbarHeight: 68,
        actions: const [LanguageButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subjectsProvider);
          ref.invalidate(continueWatchingProvider);
          await ref.read(subjectsProvider.future);
        },
        child: AsyncView(
          value: subjects,
          onRetry: () => ref.invalidate(subjectsProvider),
          loading: const _HomeSkeleton(),
          builder: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.school_outlined,
                title: l10n.emptyNoSubjectsTitle,
                message: l10n.emptyNoSubjectsMessage,
              );
            }

            return CustomScrollView(
              // Always scrollable so pull-to-refresh works even when the grid
              // is short enough not to overflow — with one seeded subject, it
              // is.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _ContinueWatchingRow()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.homeSubjects,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      // Extent rather than a fixed count: two columns on a
                      // 5-inch phone, three on a tablet, without a breakpoint.
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: list.length,
                      (context, index) => _SubjectCard(subject: list[index]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localeControllerProvider);
    final color = subject.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          Routes.subject,
          pathParameters: {'subjectId': subject.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subject.iconData, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                subject.nameFor(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of part-watched videos.
///
/// Renders nothing at all — not an empty state — when there is no progress:
/// on a first launch, a "nothing here yet" block above the subject grid would
/// be noise in the most important spot on the screen.
class _ContinueWatchingRow extends ConsumerWidget {
  const _ContinueWatchingRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(continueWatchingProvider);

    return items.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Text(
                l10n.homeContinueWatching,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _ContinueCard(
                    title: item.video.title,
                    thumbnailUrl: item.video.effectiveThumbnailUrl,
                    progress: item.progress
                        .progressFraction(item.video.durationSec),
                    onTap: () => context.pushNamed(
                      Routes.player,
                      pathParameters: {
                        'unitId': item.video.unitId,
                        'videoId': item.video.id,
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.thumbnailUrl,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String thumbnailUrl;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Thumbnail(url: thumbnailUrl),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    if (progress > 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Network thumbnail with a graceful failure.
///
/// Thumbnails come from i.ytimg.com, so they need the network. On a dead
/// connection Image.network's default is an ugly broken-image exception in the
/// console plus a blank box; this shows a play glyph instead.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : ColoredBox(color: placeholderColor),
      errorBuilder: (context, error, stack) => ColoredBox(
        color: placeholderColor,
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: List.generate(
        4,
        (_) => const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 46, height: 46, borderRadius: 12),
                Spacer(),
                SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/unit.dart';
import '../../repositories/video_repository.dart';
import '../../router.dart';
import '../player/widgets/progress_ring.dart';

/// DEV A. The Videos tab of a subject: its units, each with a progress ring.
///
/// A body widget, not a Scaffold — it is mounted inside SubjectScreen's
/// TabBarView, which already supplies the app bar.
class UnitListView extends ConsumerWidget {
  const UnitListView({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final units = ref.watch(unitsProvider(subjectId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unitsProvider(subjectId));
        await ref.read(unitsProvider(subjectId).future);
      },
      child: AsyncView(
        value: units,
        onRetry: () => ref.invalidate(unitsProvider(subjectId)),
        loading: const _UnitSkeleton(),
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.play_circle_outline_rounded,
              title: l10n.emptyNoVideosTitle,
              message: l10n.emptyNoVideosMessage,
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _UnitCard(unit: list[index]),
          );
        },
      ),
    );
  }
}

class _UnitCard extends ConsumerWidget {
  const _UnitCard({required this.unit});

  final Unit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final isEmpty = unit.videoCount == 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Not tappable when there is nothing behind it. Medium Level (Tamil)
        // and Hard Level genuinely have no discussion videos yet, and opening
        // an empty playlist would look like a bug.
        onTap: isEmpty
            ? null
            : () => context.pushNamed(
                  Routes.playlist,
                  pathParameters: {
                    'subjectId': unit.subjectId,
                    'unitId': unit.id,
                  },
                ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ProgressRing(progress: unit.progress),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.titleFor(language),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEmpty
                          ? l10n.unitVideoCount(0)
                          : '${l10n.unitVideoCount(unit.videoCount)} · '
                              '${l10n.unitCompletedOf(unit.completedCount, unit.videoCount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (!isEmpty)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitSkeleton extends StatelessWidget {
  const _UnitSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              SkeletonBox(width: 36, height: 36, borderRadius: 18),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

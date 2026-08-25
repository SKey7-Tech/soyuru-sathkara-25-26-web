import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/video.dart';
import '../../models/watch_progress.dart';
import '../../repositories/video_repository.dart';
import '../../router.dart';

/// DEV A. The videos inside one unit, with each one's watch state.
class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeControllerProvider);
    final unit = ref.watch(unitProvider(unitId)).valueOrNull;
    final videos = ref.watch(videosProvider(unitId));

    return Scaffold(
      appBar: AppBar(title: Text(unit?.titleFor(language) ?? l10n.unitsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(videosProvider(unitId));
          ref.invalidate(unitProgressProvider(unitId));
          await ref.read(videosProvider(unitId).future);
        },
        child: AsyncView(
          value: videos,
          onRetry: () => ref.invalidate(videosProvider(unitId)),
          builder: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.play_circle_outline_rounded,
                title: l10n.emptyNoVideosTitle,
                message: l10n.emptyNoVideosMessage,
              );
            }

            // Progress is a separate query and may still be in flight, or be
            // empty when anonymous sign-in is unavailable. Either way the list
            // renders — it just shows nothing watched.
            final progress =
                ref.watch(unitProgressProvider(unitId)).valueOrNull ?? const {};

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final video = list[index];
                return _VideoTile(
                  video: video,
                  index: index + 1,
                  progress: progress[video.id],
                  onTap: () => context.pushNamed(
                    Routes.player,
                    pathParameters: {
                      'unitId': unitId,
                      'videoId': video.id,
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.video,
    required this.index,
    required this.progress,
    required this.onTap,
  });

  final Video video;
  final int index;
  final WatchProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final completed = progress?.completed ?? false;
    final started = progress?.hasStarted ?? false;

    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 82,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  video.effectiveThumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Center(
                      child: Text(
                        '$index',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                if (completed)
                  ColoredBox(
                    color: Colors.black45,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colors.tertiary,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        video.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          // De-emphasise finished videos so the next unwatched one is the
          // thing the eye lands on.
          color: completed ? colors.onSurfaceVariant : null,
        ),
      ),
      subtitle: () {
        if (completed) return Text(l10n.playerMarkedComplete);
        final duration = video.formattedDuration;
        if (started) {
          return Text(
            duration == null
                ? l10n.homeContinueWatching
                : '${l10n.homeContinueWatching} · $duration',
          );
        }
        return duration == null ? null : Text(duration);
      }(),
      trailing: Icon(Icons.play_arrow_rounded, color: colors.onSurfaceVariant),
    );
  }
}

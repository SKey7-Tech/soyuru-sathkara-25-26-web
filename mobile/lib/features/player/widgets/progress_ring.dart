import 'package:flutter/material.dart';

/// DEV A. A small circular progress indicator with a tick when complete.
///
/// Used on the unit list (fraction of videos watched) and in playlists
/// (per-video state).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 36,
    this.strokeWidth = 3.5,
    this.showPercentage = true,
    this.color,
  });

  /// 0.0–1.0. Values outside that range are clamped rather than throwing.
  final double progress;
  final double size;
  final double strokeWidth;

  /// When false, an in-progress ring shows no label. Turn this off where the
  /// ring is smaller than about 32px and the digits would be unreadable.
  final bool showPercentage;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = progress.clamp(0.0, 1.0);
    final ringColor = color ?? colors.primary;
    final isComplete = value >= 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                isComplete ? colors.tertiary : ringColor,
              ),
            ),
          ),
          if (isComplete)
            Icon(Icons.check_rounded, size: size * 0.5, color: colors.tertiary)
          else if (showPercentage && value > 0)
            Text(
              '${(value * 100).round()}',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// SHARED generic loading widget.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grey placeholder blocks, for list/grid skeletons.
///
/// Mirrors the website's app/components/LoadingSkeletons.tsx: on a slow
/// connection a shaped skeleton reads as "content is coming" where a bare
/// spinner reads as "stuck".
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF262626)
        : const Color(0xFFE5E7EB);

    // globals.css honours prefers-reduced-motion; do the same here rather than
    // pulsing at a user who has asked the OS for no animation.
    if (MediaQuery.disableAnimationsOf(context)) {
      return _box(base);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _box(
        Color.lerp(base, base.withValues(alpha: 0.35), _controller.value)!,
      ),
    );
  }

  Widget _box(Color color) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
}

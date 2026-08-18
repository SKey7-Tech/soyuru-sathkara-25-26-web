import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_view.dart';

/// SHARED. Renders an [AsyncValue] as loading / error / data so no screen has
/// to spell out that switch again.
///
/// [onRetry] should invalidate the provider, e.g.
///   onRetry: () => ref.invalidate(unitsProvider(subjectId))
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  /// Optional skeleton for this specific screen.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // skipLoadingOnRefresh keeps the old list on screen during a pull-to-
      // refresh instead of flashing a spinner over content that is still valid.
      skipLoadingOnRefresh: true,
      loading: () => loading ?? const LoadingView(),
      error: (error, _) => ErrorView(error: error, onRetry: onRetry),
      data: builder,
    );
  }
}

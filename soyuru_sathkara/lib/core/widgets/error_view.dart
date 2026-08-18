import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';

/// SHARED generic error widget with a retry affordance.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offline = isOffline(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              offline ? l10n.errorNoConnection : l10n.errorGeneric,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              describe(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// True when the failure is "no network" rather than "something is broken".
  ///
  /// Worth distinguishing: Step 4 of the plan requires testing on slow/no
  /// network, and a student on a dead connection who is told "something went
  /// wrong" will assume the app is broken and uninstall it.
  static bool isOffline(Object error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
    }
    // PostgrestException wraps transport failures with an empty/socket message.
    if (error is PostgrestException) {
      final m = error.message.toLowerCase();
      return m.contains('socket') ||
          m.contains('failed host lookup') ||
          m.contains('connection');
    }
    return false;
  }

  /// A short technical line, under the friendly headline. Kept visible on
  /// purpose — these two devs will be debugging on borrowed phones with no
  /// logcat attached, and "PostgrestException: permission denied for table
  /// videos" on screen is worth an hour of guessing at RLS.
  static String describe(Object error) {
    if (error is PostgrestException) {
      return 'PostgrestException ${error.code ?? ''}: ${error.message}'.trim();
    }
    if (error is AuthException) return 'AuthException: ${error.message}';
    if (error is StorageException) return 'StorageException: ${error.message}';
    if (error is DioException) {
      return 'Download failed: ${error.type.name}'
          '${error.response != null ? ' (${error.response!.statusCode})' : ''}';
    }
    if (error is SocketException) return error.osError?.message ?? error.message;
    return error.toString();
  }
}

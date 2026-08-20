import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// SHARED — the single Supabase client for the whole app. Built once, in
/// [initSupabase], called from main() before runApp.
///
/// Never call Supabase.initialize anywhere else, and never construct a second
/// SupabaseClient: the SDK keeps the auth session, the token-refresh timer and
/// the realtime socket on the instance. Two instances means two refresh timers
/// racing each other and a session that randomly reverts.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    // `publishableKey`, not the deprecated `anonKey`. The SDK takes whichever
    // is provided, so this accepts both a legacy anon JWT and the newer
    // sb_publishable_... format this project uses.
    publishableKey: Env.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      // Session survives app restarts, so a student stays signed in and keeps
      // their watch progress without ever seeing a login screen again.
      autoRefreshToken: true,
    ),
    // Content tables are read-only from the client and change maybe weekly.
    // Realtime would hold an open websocket for no benefit and cost battery
    // on the low-end phones this app targets.
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 1),
  );
}

/// Convenience accessor. Prefer the provider below inside widgets/repositories
/// so tests can override it.
SupabaseClient get supabase => Supabase.instance.client;

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

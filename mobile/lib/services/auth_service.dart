import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_language.dart';
import '../core/supabase_client.dart';
import '../models/profile.dart';

/// SHARED — built once in Phase 0. Announce before changing.
///
/// ## Why anonymous sign-in
///
/// Watch progress and the downloads log are keyed on auth.uid(), so *some*
/// session has to exist before a student can have progress at all. Forcing a
/// signup screen in front of an app whose entire point is free access to
/// underprivileged students is the wrong trade: many of them do not have an
/// email address, and every extra field loses users.
///
/// So the app signs in anonymously on first launch. The student gets a real
/// auth.uid(), progress works immediately, and email/password stays available
/// for anyone who wants their progress to survive changing phones.
///
/// ## Requires dashboard configuration
///
/// Authentication > Sign In / Providers > **Anonymous sign-ins: enabled**.
/// If it is off, [ensureSession] fails softly: content still browses fine
/// (every content table is readable by the anon role — see 002_rls_policies)
/// and only progress-writing goes quiet. It will not crash or block the UI.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;
  Session? get currentSession => _auth.currentSession;
  String? get userId => currentUser?.id;
  bool get isSignedIn => currentUser != null;

  /// True for a student who has never given us an email.
  ///
  /// Reads the is_anonymous claim Supabase puts on the JWT. It is non-nullable
  /// and defaults to false, so a session predating the claim reads as a normal
  /// account rather than throwing.
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// True when there is no real account behind the app — either an anonymous
  /// session, or no session at all.
  ///
  /// The distinction matters: [isAnonymous] is false when `currentUser` is
  /// null, so a screen that branches on it alone treats "signed out entirely"
  /// as "signed in with an account" and offers Sign out to someone who has
  /// nothing to sign out of. That state is reachable whenever
  /// [ensureSession] could not get a session — anonymous sign-ins disabled in
  /// the dashboard, or simply offline on first launch.
  bool get isGuest => !isSignedIn || isAnonymous;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Called once from main() before runApp.
  ///
  /// Deliberately never rethrows: a failure here must not stop the app from
  /// launching, because everything except progress-tracking works without a
  /// session.
  Future<void> ensureSession() async {
    if (currentSession != null) return;
    try {
      await _auth.signInAnonymously();
    } on AuthException catch (e) {
      dev.log(
        'Anonymous sign-in failed (${e.message}). Continuing without a '
        'session — content is readable but watch progress will not be saved. '
        'Enable Authentication > Providers > Anonymous sign-ins in the '
        'Supabase dashboard to fix this.',
        name: 'AuthService',
      );
    } catch (e) {
      dev.log('Anonymous sign-in failed: $e', name: 'AuthService');
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  /// Upgrades the current anonymous student into a real account, which is what
  /// keeps their existing watch progress: updateUser attaches the email to the
  /// *same* auth.uid(), where signUp would mint a brand new one and orphan
  /// every watch_progress row they already have.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final trimmed = email.trim();
    final metadata = (displayName == null || displayName.trim().isEmpty)
        ? null
        : {'display_name': displayName.trim()};

    if (isAnonymous) {
      await _auth.updateUser(
        UserAttributes(email: trimmed, password: password, data: metadata),
      );
      return;
    }

    await _auth.signUp(email: trimmed, password: password, data: metadata);
  }

  /// Signs out and immediately takes a fresh anonymous session, so the student
  /// lands back on a working app rather than a dead one where nothing saves.
  Future<void> signOut() async {
    await _auth.signOut();
    await ensureSession();
  }

  // ------------------------------------------------------------------
  // Profile
  // ------------------------------------------------------------------

  Future<Profile?> fetchProfile() async {
    final id = userId;
    if (id == null) return null;

    final row = await _client
        .from('profiles')
        .select('id, display_name, medium, created_at')
        .eq('id', id)
        // maybeSingle, not single: the row is created by a trigger, and on a
        // very first launch the read can land before that commit is visible.
        // single() would throw; this returns null and the caller retries.
        .maybeSingle();

    return row == null ? null : Profile.fromMap(row);
  }

  Future<void> updateProfile({String? displayName, AppLanguage? medium}) async {
    final id = userId;
    if (id == null) return;

    final patch = <String, dynamic>{
      if (displayName != null) 'display_name': displayName.trim(),
      if (medium != null) 'medium': medium.code,
    };
    if (patch.isEmpty) return;

    // upsert rather than update: covers the edge case where the trigger row is
    // genuinely absent (e.g. a project restored from a backup taken before
    // 003 ran) instead of silently updating zero rows.
    await _client.from('profiles').upsert({'id': id, ...patch});
  }
}

// ----------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

/// Emits on sign-in, sign-out and token refresh. Everything that depends on
/// "who am I" should watch this so it rebuilds when the answer changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).onAuthStateChange;
});

/// The current user id, or null. Rebuilds via [authStateProvider].
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authServiceProvider).userId;
});

final profileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(authServiceProvider).fetchProfile();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

/// DEV B (lives in the profile feature). Optional email sign-in.
///
/// A sheet rather than a route: signing in is never a gate in this app — the
/// entire catalogue works anonymously — so it must not look like one.
Future<void> showSignInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _SignInSheet(),
  );
}

class _SignInSheet extends ConsumerStatefulWidget {
  const _SignInSheet();

  @override
  ConsumerState<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<_SignInSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final auth = ref.read(authServiceProvider);

    try {
      if (_isSignUp) {
        await auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        // Whether a confirmation email is required depends on the project's
        // auth settings, so this says "check your email" rather than claiming
        // the account is already active.
        setState(() => _infoMessage = l10n.authCheckEmail);
      } else {
        await auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }
    } on AuthException catch (e) {
      // Supabase's message is the useful part here (wrong password, email
      // already registered, rate limited) and it is not worth translating a
      // dozen server strings for v1. Flagged for Step 5 if it matters.
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      // Keeps the fields above the keyboard.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? l10n.authSignUp : l10n.authSignIn,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.authWhySignIn,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.authEmail,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                // Deliberately loose. Strict email regexes reject valid
                // addresses, and the server is the real authority anyway.
                final looksValid = text.contains('@') &&
                    text.indexOf('@') > 0 &&
                    text.split('@').last.contains('.');
                return looksValid ? null : l10n.authInvalidEmail;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              enabled: !_busy,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _busy ? null : _submit(),
              decoration: InputDecoration(
                labelText: l10n.authPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => (value ?? '').length >= 6
                  ? null
                  : l10n.authPasswordTooShort,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _Message(text: _errorMessage!, color: colors.error),
            ],
            if (_infoMessage != null) ...[
              const SizedBox(height: 12),
              _Message(text: _infoMessage!, color: colors.tertiary),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isSignUp ? l10n.authSignUp : l10n.authSignIn),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                        _infoMessage = null;
                      }),
              child: Text(
                _isSignUp ? l10n.authHaveAccount : l10n.authNoAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

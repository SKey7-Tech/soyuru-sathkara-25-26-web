import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/widgets/language_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../services/auth_service.dart';
import 'sign_in_sheet.dart';

/// DEV B. Identity, language, downloads.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();

  /// The value last written, so the Save button can be disabled until the field
  /// actually differs from what is stored.
  String? _savedName;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      await ref
          .read(authServiceProvider)
          .updateProfile(displayName: _nameController.text);
      ref.invalidate(profileProvider);

      if (!mounted) return;
      setState(() => _savedName = _nameController.text.trim());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.profileSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(authServiceProvider).signOut();
    ref.invalidate(profileProvider);
    if (mounted) {
      _nameController.clear();
      setState(() => _savedName = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final language = ref.watch(localeControllerProvider);

    final auth = ref.watch(authServiceProvider);
    ref.watch(authStateProvider); // rebuild on sign-in/out
    final profile = ref.watch(profileProvider).valueOrNull;
    // isGuest, not isAnonymous: with no session at all isAnonymous is false,
    // which would show this student a Sign out button and no way in.
    final isGuest = auth.isGuest;

    // Seed the field from the server value once, and never overwrite what the
    // student is currently typing.
    //
    // The controller write is deferred to after the frame on purpose: assigning
    // to TextEditingController.text notifies its listeners, which marks the
    // TextField dirty. Doing that synchronously inside build() throws
    // "markNeedsBuild() called during build". Setting the plain _savedName
    // field here is fine and is what stops this running twice.
    final storedName = profile?.displayName ?? '';
    if (_savedName == null && storedName.isNotEmpty) {
      _savedName = storedName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _nameController.text = storedName;
        setState(() {});
      });
    }

    final nameChanged = _nameController.text.trim() != (_savedName ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ---- Identity ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storedName.isNotEmpty
                            ? storedName
                            : (isGuest
                                ? l10n.profileGuest
                                : l10n.profileStudent),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (!isGuest && auth.currentUser?.email != null)
                        Text(
                          l10n.profileSignedInAs(auth.currentUser!.email!),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Guest notice ----
          if (isGuest)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileGuestExplainer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.tonalIcon(
                        onPressed: () => showSignInSheet(context),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: Text(l10n.authSignIn),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(),

          // ---- Display name ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _nameController,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.profileDisplayName,
                prefixIcon: const Icon(Icons.badge_outlined),
                suffixIcon: nameChanged
                    ? IconButton(
                        onPressed: _saving ? null : _saveName,
                        icon: const Icon(Icons.check_rounded),
                        tooltip: l10n.commonSave,
                      )
                    : null,
              ),
            ),
          ),

          // ---- Language ----
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text(l10n.profileLanguage),
            subtitle: Text(language.nativeName),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLanguagePicker(context),
          ),

          // ---- Downloads ----
          ListTile(
            leading: const Icon(Icons.download_done_rounded),
            title: Text(l10n.profileMyDownloads),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(Routes.downloads),
          ),

          const Divider(),

          if (!isGuest)
            ListTile(
              leading: Icon(Icons.logout_rounded, color: colors.error),
              title: Text(
                l10n.profileSignOut,
                style: TextStyle(color: colors.error),
              ),
              onTap: _confirmSignOut,
            ),

          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  l10n.appTagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

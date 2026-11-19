import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'auth_repository.dart';

/// Small reminder shown to a signed-in user whose email is not verified yet
/// (VST-95). It never blocks the app: the user can ignore it and keep using
/// everything. When the user comes back from the mail app, the banner checks
/// again and disappears once the email is verified.
class EmailVerificationBanner extends ConsumerStatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  ConsumerState<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState
    extends ConsumerState<EmailVerificationBanner>
    with WidgetsBindingObserver {
  String? _verifiedUid;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _recheck();
  }

  Future<void> _recheck() async {
    final user = ref.read(authStateProvider).value;
    if (user == null || user.emailVerified) return;
    try {
      final verified =
          await ref.read(authRepositoryProvider).reloadEmailVerified();
      if (verified && mounted) setState(() => _verifiedUid = user.uid);
    } catch (_) {
      // No network: the banner stays, it is only a reminder.
    }
  }

  Future<void> _resend() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      messenger.showSnackBar(SnackBar(content: Text(l10n.verifyBannerSent)));
    } on AuthFailure catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(authErrorMessage(l10n, e.error))));
    } catch (_) {
      messenger.showSnackBar(
          SnackBar(content: Text(authErrorMessage(l10n, AuthError.unknown))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null || user.emailVerified || user.uid == _verifiedUid) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        child: Row(
          children: [
            Icon(Icons.mark_email_unread_outlined,
                size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.verifyBannerText,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
            TextButton(
              onPressed: _sending ? null : _resend,
              child: Text(l10n.verifyBannerResend),
            ),
          ],
        ),
      ),
    );
  }
}

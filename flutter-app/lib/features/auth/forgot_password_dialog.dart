import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/rtl_helpers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'auth_repository.dart';

/// "Forgot password?" on the login screen (VST-95): asks for the email and
/// sends the Firebase reset mail. The success message is the same whether or
/// not an account exists, so the dialog never reveals which emails are used.
Future<void> showForgotPasswordDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  late final _email = TextEditingController(text: widget.initialEmail);
  AuthError? _error;
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final invalid = validateEmail(_email.text);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.error);
    } catch (_) {
      if (mounted) setState(() => _error = AuthError.unknown);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.forgotPasswordTitle),
      content: _sent
          ? Text(l10n.forgotPasswordSent)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.forgotPasswordBody),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autofocus: true,
                  // An email reads left-to-right; in Arabic it starts on the right.
                  textDirection: TextDirection.ltr,
                  textAlign: isRtl(context) ? TextAlign.right : TextAlign.start,
                  decoration: InputDecoration(
                    labelText: l10n.authEmailLabel,
                    errorText: authErrorOrNull(l10n, _error),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ],
            ),
      actions: _sent
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ]
          : [
              TextButton(
                onPressed: _sending ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.forgotPasswordSend),
              ),
            ],
    );
  }
}

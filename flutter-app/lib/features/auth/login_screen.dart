import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/password_text_field.dart';
import '../../l10n/generated/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'forgot_password_dialog.dart';
import 'require_sign_in.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;
    final l10n = AppLocalizations.of(context);
    final emailError = authErrorOrNull(l10n, validateEmail(_email.text));
    final passwordError = authErrorOrNull(
      l10n,
      validatePassword(_password.text),
    );
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text, _password.text);
    // Back to the screen that asked for the account (see requireSignIn).
    if (ok && mounted) finishSignIn(context);
  }

  /// Guests can browse without an account: close the screen (or go home).
  void _continueAsGuest() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      context.go(AppRoutes.explore);
    }
  }

  Future<void> _goToSignUp() async {
    final signedUp = await context.push<bool>(AppRoutes.signup);
    if (signedUp == true && mounted) finishSignIn(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Round light-primary badge with the Vesta door icon.
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.sensor_door_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.authWelcomeTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.authWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: l10n.authEmailLabel,
                controller: _email,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                ltr: true,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordTextField(
                label: l10n.authPasswordLabel,
                controller: _password,
                errorText: _passwordError,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              if (auth.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  authErrorMessage(l10n, auth.error!),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => showForgotPasswordDialog(
                          context,
                          initialEmail: _email.text.trim(),
                        ),
                  child: Text(l10n.authForgotPassword),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: l10n.authLoginButton,
                loading: auth.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: auth.isLoading ? null : _goToSignUp,
                child: Text(l10n.authGoToSignUp),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: l10n.authContinueAsGuest,
                onPressed: auth.isLoading ? null : _continueAsGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

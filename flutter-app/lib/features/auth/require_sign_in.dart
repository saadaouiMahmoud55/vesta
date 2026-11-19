import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../l10n/generated/app_localizations.dart';
import 'auth_controller.dart';

enum _SignInChoice { login, signUp }

/// Guard for every action that needs an account (favorite, chat, publish,
/// contact numbers, requests). Guests can browse everything else (VST-72).
///
/// Returns `true` when the user is signed in, or signs in right now. The caller
/// then continues the action it started:
///
/// ```dart
/// if (await requireSignIn(context, ref)) {
///   if (context.mounted) context.push(AppRoutes.publish);
/// }
/// ```
///
/// A guest sees the "Sign in to continue" sheet. Login and Sign up are pushed
/// on top of the current screen, so after signing in the user is back on the
/// same screen and the action goes on. Returns `false` if the user gives up.
Future<bool> requireSignIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(authStateProvider).value != null) return true;

  final choice = await showModalBottomSheet<_SignInChoice>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _SignInSheet(),
  );
  if (choice == null || !context.mounted) return false;

  final route =
      choice == _SignInChoice.signUp ? AppRoutes.signup : AppRoutes.login;
  final signedIn = await context.push<bool>(route);
  return signedIn == true;
}

/// Called by Login and Sign up after a successful sign-in. Goes back to the
/// screen that asked for the account; if there is none (the page was opened
/// directly), goes to the home screen.
void finishSignIn(BuildContext context) {
  if (context.canPop()) {
    context.pop(true);
  } else {
    context.go(AppRoutes.explore);
  }
}

class _SignInSheet extends StatelessWidget {
  const _SignInSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.signInToContinueTitle,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInToContinueBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_SignInChoice.login),
              child: Text(l10n.authLoginButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(_SignInChoice.signUp),
              child: Text(l10n.authSignUpTitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Body of a tab that needs an account (for example Favorites) when the user
/// is a guest: explains why and opens the sign-in sheet.
class SignInPrompt extends ConsumerWidget {
  const SignInPrompt({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInToContinueBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => requireSignIn(context, ref),
              child: Text(l10n.authLoginButton),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// True when the account was created in the same session as this sign-in
/// (Firebase gives the same time for both on a new account). Used to choose
/// between "Welcome" and "Welcome back".
bool isFirstSignIn(DateTime? created, DateTime? lastSignIn) {
  if (created == null || lastSignIn == null) return false;
  return lastSignIn.difference(created).abs() < const Duration(minutes: 1);
}

/// Top of the Explore tab for a signed-in user: the Vesta logo on the left
/// (the right in Arabic) and a welcome message with the user's name.
class ExploreWelcome extends StatelessWidget {
  const ExploreWelcome({super.key, required this.name, required this.isNew});

  final String name;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trimmed = name.trim();
    final text = trimmed.isEmpty
        ? l10n.authWelcomeTitle
        : (isNew
              ? l10n.listingsWelcomeNew(trimmed)
              : l10n.listingsWelcomeBack(trimmed));

    return Row(
      key: const Key('explore-welcome'),
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 56,
          height: 56,
          semanticLabel: 'Vesta',
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

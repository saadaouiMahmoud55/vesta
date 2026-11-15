import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// A short Tunisian proverb under the title of the sign-up screen: a warm
/// sand card with a quote mark, to make the page feel welcoming.
class AuthProverb extends StatelessWidget {
  const AuthProverb({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('auth-proverb'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.terracotta,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.authSignUpProverb,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.navy,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

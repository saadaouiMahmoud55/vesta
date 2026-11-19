import 'package:flutter/material.dart';

import '../../features/listings/listing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Ribbon with the offer type, in the type color (docs/offer-types.md,
/// section 5): stay = blue, rent = navy, sale = terracotta, cream text.
class OfferTypeBadge extends StatelessWidget {
  const OfferTypeBadge({super.key, required this.type});

  final OfferType type;

  /// Color of an offer type. Also used by the map pins.
  static Color colorOf(OfferType type) {
    switch (type) {
      case OfferType.stay:
        return AppColors.primary;
      case OfferType.rent:
        return AppColors.navy;
      case OfferType.sale:
        return AppColors.terracotta;
    }
  }

  static String _label(AppLocalizations l10n, OfferType type) {
    switch (type) {
      case OfferType.stay:
        return l10n.offerStay;
      case OfferType.rent:
        return l10n.offerRent;
      case OfferType.sale:
        return l10n.offerSale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorOf(type),
        borderRadius: BorderRadius.circular(AppRadius.thumb),
      ),
      child: Text(
        _label(l10n, type),
        style: AppTextStyles.small.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

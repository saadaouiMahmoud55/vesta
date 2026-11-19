import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../listings/listing.dart';

/// Small card shown at the bottom of the map when a marker is tapped.
/// Tapping it opens the details (VST-42).
class MapListingPreview extends StatelessWidget {
  const MapListingPreview({
    super.key,
    required this.listing,
    required this.onOpen,
  });

  final Listing listing;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      color: AppColors.white,
      elevation: 2,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Photo placeholder: light primary tint with the door icon.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.thumb),
                ),
                child: const Icon(
                  Icons.sensor_door_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // The price always reads left to right, also in Arabic.
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        previewPriceText(l10n, listing),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: onOpen, child: Text(l10n.mapViewDetails)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Price with its unit. formatPrice formats the number, offerTypeOf decides
/// the offer type (the rule is not written here).
String previewPriceText(AppLocalizations l10n, Listing listing) {
  final price = formatPrice(listing.price, currency: listing.currency);
  switch (offerTypeOf(listing)) {
    case OfferType.sale:
      return price;
    case OfferType.stay:
      return '$price ${l10n.listingDetailPerNight}';
    case OfferType.rent:
      switch (listing.rentPeriod) {
        case 'year':
          return '$price ${l10n.listingDetailPerYear}';
        case 'month':
          return '$price ${l10n.listingDetailPerMonth}';
        default:
          return price;
      }
  }
}

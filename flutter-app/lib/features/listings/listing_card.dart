import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/key_facts_row.dart';
import '../../core/widgets/offer_type_badge.dart';
import '../../core/widgets/price_text.dart';
import '../favorites/favorite_button.dart';
import '../../l10n/generated/app_localizations.dart';
import 'listing.dart';
import 'listing_repository.dart';

/// Cover photo (base64) of a listing. Cached per listing id, so scrolling
/// back up does not read Firestore again.
final listingCoverPhotoProvider = FutureProvider.family<String?, String>(
  (ref, listingId) => ListingRepository().getCoverPhotoBase64(listingId),
);

String _plain(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// Key facts of a listing: bedrooms, bathrooms, area (only the ones filled).
List<KeyFact> keyFactsOf(Listing listing) {
  final facts = <KeyFact>[];
  final bedrooms = listing.bedrooms;
  final bathrooms = listing.bathrooms;
  final area = listing.areaSqm;
  if (bedrooms != null) {
    facts.add(KeyFact(icon: Icons.bed_outlined, value: _plain(bedrooms)));
  }
  if (bathrooms != null) {
    facts.add(KeyFact(icon: Icons.bathtub_outlined, value: _plain(bathrooms)));
  }
  if (area != null) {
    facts.add(
      KeyFact(
        icon: Icons.square_foot,
        value: '${_plain(area)} ${AppConfig.areaUnit}',
      ),
    );
  }
  return facts;
}

/// Card used in the favorites list, the home list and the search results.
/// Photo with the offer ribbon and the heart, title, city, key facts and the
/// price with its unit.
class ListingCard extends ConsumerWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.showFavorite = true,
  });

  final Listing listing;
  final VoidCallback? onTap;

  /// False only in the debug UI kit screen, so that a demo card never writes
  /// a favorite.
  final bool showFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final unavailable = listing.isUnavailable;
    final type = offerTypeOf(listing);
    final facts = keyFactsOf(listing);
    final cover = ref.watch(listingCoverPhotoProvider(listing.id)).value;

    ImageProvider? image;
    if (cover != null && cover.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(cover));
      } catch (_) {
        image = null; // bad base64: show the placeholder
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null)
                    Image(
                      image: image,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else
                    ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.home_work_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (unavailable) ...[
                    // Grey veil over the photo.
                    ColoredBox(color: AppColors.navy.withValues(alpha: 0.45)),
                    Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: Container(
                        margin: const EdgeInsets.all(AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(AppRadius.thumb),
                        ),
                        child: Text(
                          l10n.favoritesUnavailable,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: OfferTypeBadge(type: type),
                  ),
                  if (showFavorite)
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      end: AppSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: FavoriteButton(listingId: listing.id),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    listing.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (facts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    KeyFactsRow(facts: facts),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  PriceText(
                    price: listing.price,
                    currency: listing.currency,
                    period: type == OfferType.sale ? null : listing.rentPeriod,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

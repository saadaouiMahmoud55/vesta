import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/listings/listing.dart';
import '../../features/listings/listing_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../config/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_avatar.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_states.dart';
import 'app_text_field.dart';
import 'filter_tag.dart';
import 'key_facts_row.dart';
import 'offer_type_badge.dart';
import 'price_text.dart';
import 'rtl_helpers.dart';

/// Debug-only screen (route `/ui-kit`, opened from Settings in debug builds):
/// shows every shared widget, so it can be checked in English, French and
/// Arabic on a real phone. It is not reachable in a release build.
class UiKitScreen extends ConsumerStatefulWidget {
  const UiKitScreen({super.key});

  @override
  ConsumerState<UiKitScreen> createState() => _UiKitScreenState();
}

const _demoSale = Listing(
  id: 'ui-kit-sale',
  ownerId: 'ui-kit',
  title: 'Villa à Hammamet',
  description: '',
  price: 650000,
  currency: 'TND',
  listingType: 'sale',
  propertyType: 'villa',
  city: 'Hammamet',
  status: 'available',
  photoCount: 0,
  bedrooms: 4,
  bathrooms: 3,
  areaSqm: 220,
);

const _demoRent = Listing(
  id: 'ui-kit-rent',
  ownerId: 'ui-kit',
  title: 'Appartement S+2 à La Marsa',
  description: '',
  price: 1200,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'month',
  propertyType: 'apartment',
  city: 'La Marsa',
  status: 'available',
  photoCount: 0,
  bedrooms: 2,
  bathrooms: 1,
  areaSqm: 95,
);

const _demoStay = Listing(
  id: 'ui-kit-stay',
  ownerId: 'ui-kit',
  title: 'Riad à Tozeur',
  description: '',
  price: 120,
  currency: 'TND',
  listingType: 'rent',
  rentPeriod: 'night',
  propertyType: 'riad',
  city: 'Tozeur',
  status: 'unavailable',
  photoCount: 0,
  bedrooms: 3,
);

class _UiKitScreenState extends ConsumerState<UiKitScreen> {
  int _chip = 0;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    const languages = {'ar': 'العربية', 'fr': 'Français', 'en': 'English'};
    final chips = [
      l10n.favoritesFilterAll,
      l10n.favoritesFilterBuy,
      l10n.favoritesFilterRent,
      l10n.favoritesFilterStay,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('UI kit')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            'Language',
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final entry in languages.entries)
                  FilterTag(
                    label: entry.value,
                    selected: current == entry.key,
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(entry.key)),
                  ),
              ],
            ),
          ),
          _Section(
            'PrimaryButton, SecondaryButton',
            Column(
              children: [
                PrimaryButton(label: l10n.publishSubmit, onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  label: l10n.publishButton,
                  icon: Icons.add,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  label: l10n.publishSubmit,
                  onPressed: null,
                  loading: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(label: l10n.commonCancel, onPressed: () {}),
              ],
            ),
          ),
          _Section(
            'AppTextField',
            Column(
              children: [
                AppTextField(
                  label: l10n.authDisplayNameLabel,
                  controller: _nameController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.authEmailLabel,
                  errorText: l10n.authErrorInvalidEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: '+216',
                  hintText: '+216 20 123 456',
                  keyboardType: TextInputType.phone,
                  ltr: true,
                ),
              ],
            ),
          ),
          _Section(
            'FilterTag',
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < chips.length; i++)
                  FilterTag(
                    label: chips[i],
                    selected: _chip == i,
                    onTap: () => setState(() => _chip = i),
                  ),
              ],
            ),
          ),
          _Section(
            'OfferTypeBadge',
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final type in OfferType.values) OfferTypeBadge(type: type),
              ],
            ),
          ),
          const _Section(
            'PriceText',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PriceText(price: 650000, currency: 'TND'),
                SizedBox(height: AppSpacing.xs),
                PriceText(price: 1200, currency: 'TND', period: 'month'),
                SizedBox(height: AppSpacing.xs),
                PriceText(price: 120, currency: 'TND', period: 'night'),
                SizedBox(height: AppSpacing.xs),
                PriceText(price: 12000, currency: 'TND', period: 'year'),
              ],
            ),
          ),
          _Section('KeyFactsRow', KeyFactsRow(facts: keyFactsOf(_demoSale))),
          _Section(
            'ListingCard (sale, rent, stay unavailable)',
            ProviderScope(
              overrides: [
                for (final id in const [
                  'ui-kit-sale',
                  'ui-kit-rent',
                  'ui-kit-stay',
                ])
                  listingCoverPhotoProvider(id)
                      .overrideWith((ref) => Future<String?>.value(null)),
              ],
              child: const Column(
                children: [
                  ListingCard(listing: _demoSale, showFavorite: false),
                  SizedBox(height: AppSpacing.md),
                  ListingCard(listing: _demoRent, showFavorite: false),
                  SizedBox(height: AppSpacing.md),
                  ListingCard(listing: _demoStay, showFavorite: false),
                ],
              ),
            ),
          ),
          const _Section(
            'AppAvatar',
            Row(
              children: [
                AppAvatar(name: 'Sarra Trabelsi'),
                SizedBox(width: AppSpacing.md),
                AppAvatar(name: 'Mehdi'),
                SizedBox(width: AppSpacing.md),
                AppAvatar(),
              ],
            ),
          ),
          _Section(
            'EmptyState',
            SizedBox(
              height: 300,
              child: EmptyState(
                icon: Icons.favorite_border,
                title: l10n.favoritesEmptyTitle,
                message: l10n.favoritesEmptyBody,
                actionLabel: l10n.tabExplore,
                onAction: () {},
              ),
            ),
          ),
          _Section(
            'ErrorState',
            SizedBox(
              height: 220,
              child: ErrorState(
                message: l10n.favoritesErrorNoNetwork,
                onRetry: () {},
              ),
            ),
          ),
          const _Section(
            'LoadingView, OfflineBanner',
            Column(
              children: [
                SizedBox(height: 70, child: LoadingView()),
                OfflineBanner(),
              ],
            ),
          ),
          _Section(
            'DirectionalIcon, LtrText',
            Row(
              children: [
                const DirectionalIcon(Icons.arrow_back),
                const SizedBox(width: AppSpacing.md),
                const DirectionalIcon(Icons.chevron_right),
                const SizedBox(width: AppSpacing.lg),
                LtrText(
                  '+216 20 123 456',
                  style: AppTextStyles.body.copyWith(color: AppColors.navy),
                ),
              ],
            ),
          ),
          _Section(
            'Bottom sheet',
            SecondaryButton(
              label: l10n.signInToContinueTitle,
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                title: l10n.signInToContinueTitle,
                child: Text(l10n.signInToContinueBody),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.child);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

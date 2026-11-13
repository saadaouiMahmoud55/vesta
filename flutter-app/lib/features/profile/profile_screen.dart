import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/locale_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/filter_tag.dart';
import '../../core/widgets/price_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/require_sign_in.dart';
import '../listings/listing.dart';
import '../listings/listing_card.dart';
import 'listing_status_sheet.dart';
import 'profile_controller.dart';
import 'profile_messages.dart';

/// Language names are always written in their own language.
const _languages = {
  'ar': 'العربية التونسية',
  'fr': 'Français',
  'en': 'English',
};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Publishing needs an account: a guest gets the sign-in sheet first.
  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    if (!await requireSignIn(context, ref)) return;
    if (context.mounted) context.push(AppRoutes.publish);
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signOut();
    // Back to the guest home: nothing of the previous user stays on screen.
    context.go(AppRoutes.explore);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Listing listing,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteConfirmTitle),
        content: Text(l10n.profileDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.profileDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final controller = ref.read(profileControllerProvider.notifier);
    final ok = await controller.deleteListing(listing);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileListingDeleted)),
      );
    } else {
      final error = ref.read(profileControllerProvider).error;
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(profileErrorMessage(l10n, error))),
        );
        controller.clearError();
      }
    }
  }

  /// One tap on the status chip: choose a status, then save it (VST-96).
  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    Listing listing,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showListingStatusSheet(context, listing);
    if (chosen == null || chosen == listing.status) return;
    if (!context.mounted) return;

    final controller = ref.read(profileControllerProvider.notifier);
    final ok = await controller.setStatus(listing, chosen);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileStatusUpdated)),
      );
    } else {
      final error = ref.read(profileControllerProvider).error;
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(profileErrorMessage(l10n, error))),
        );
        controller.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final signedIn = user != null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (signedIn) ...[
          _ProfileHeader(email: user.email),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: l10n.profileEditTitle,
            icon: Icons.edit_outlined,
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        PrimaryButton(
          label: l10n.publishButton,
          icon: Icons.add_home_work_outlined,
          onPressed: () => _publish(context, ref),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _LanguageSwitch(),
        if (signedIn) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.profileMyListings,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MyListings(
            onDelete: (listing) => _confirmDelete(context, ref, listing),
            onChangeStatus: (listing) => _changeStatus(context, ref, listing),
            onPublish: () => _publish(context, ref),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SecondaryButton(
          label: l10n.settingsTitle,
          icon: Icons.settings_outlined,
          onPressed: () => context.push(AppRoutes.settings),
        ),
        const SizedBox(height: AppSpacing.md),
        if (signedIn)
          TextButton.icon(
            onPressed: () => _signOut(context, ref),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.logout),
            label: Text(l10n.authLogoutButton),
          )
        else
          PrimaryButton(
            label: l10n.authLoginButton,
            onPressed: () => requireSignIn(context, ref),
          ),
      ],
    );
  }
}

/// Three pills: Arabic, French, English. Same provider as the settings.
class _LanguageSwitch extends ConsumerWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.languageLabel,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in _languages.entries)
              FilterTag(
                label: entry.value,
                selected: current == entry.key,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(Locale(entry.key)),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).value;
    return Column(
      children: [
        AppAvatar(
          photoBase64: profile?.photoBase64,
          name: profile?.displayName,
          radius: 48,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile?.displayName ?? '',
          style: AppTextStyles.title.copyWith(color: AppColors.navy),
        ),
        if (email != null && email!.isNotEmpty)
          Text(
            email!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }
}

class _MyListings extends ConsumerWidget {
  const _MyListings({
    required this.onDelete,
    required this.onChangeStatus,
    required this.onPublish,
  });

  final void Function(Listing listing) onDelete;
  final void Function(Listing listing) onChangeStatus;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(myListingsProvider);
    final busy = ref.watch(profileControllerProvider).isLoading;

    return listings.when(
      loading: () => const LoadingView(),
      error: (e, s) => ErrorState(
        message: l10n.profileListingsLoadError,
        onRetry: () => ref.invalidate(myListingsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.home_work_outlined,
            title: l10n.profileNoListings,
            actionLabel: l10n.profilePublishFirst,
            onAction: onPublish,
          );
        }
        return Column(
          children: [
            for (final listing in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MyListingCard(
                  listing: listing,
                  busy: busy,
                  onDelete: () => onDelete(listing),
                  onChangeStatus: () => onChangeStatus(listing),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MyListingCard extends ConsumerWidget {
  const _MyListingCard({
    required this.listing,
    required this.busy,
    required this.onDelete,
    required this.onChangeStatus,
  });

  final Listing listing;
  final bool busy;
  final VoidCallback onDelete;
  final VoidCallback onChangeStatus;

  Color _chipColor() {
    switch (listing.status) {
      case 'available':
        return AppColors.primary.withValues(alpha: 0.15);
      case 'reserved':
        return AppColors.sand;
      case 'hidden':
        return AppColors.border;
      default:
        return AppColors.error.withValues(alpha: 0.15);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = offerTypeOf(listing);
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
        // Opens the details, like any listing of the Explore tab.
        onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.thumb),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: image != null
                      ? Image(image: image, fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      listing.city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PriceText(
                      price: listing.price,
                      currency: listing.currency,
                      period: type == OfferType.sale
                          ? null
                          : listing.rentPeriod,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ActionChip(
                      backgroundColor: _chipColor(),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      label: Text(
                        statusLabel(l10n, listing.status),
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      onPressed: busy ? null : onChangeStatus,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.profileDeleteListing,
                icon: const Icon(Icons.delete_outline, color: AppColors.grey),
                onPressed: busy ? null : onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/require_sign_in.dart';
import '../listings/listing.dart';
import '../listings/listing_card.dart';
import 'listing_status_sheet.dart';
import 'profile_avatar.dart';
import 'profile_controller.dart';
import 'profile_messages.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Publishing needs an account: a guest gets the sign-in sheet first.
  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    if (!await requireSignIn(context, ref)) return;
    if (context.mounted) context.push(AppRoutes.publish);
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
      padding: const EdgeInsets.all(24),
      children: [
        if (signedIn) ...[
          _ProfileHeader(email: user.email),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.profileEditTitle),
          ),
          const SizedBox(height: 24),
        ],
        FilledButton.icon(
          onPressed: () => _publish(context, ref),
          icon: const Icon(Icons.add_home_work_outlined),
          label: Text(l10n.publishButton),
        ),
        if (signedIn) ...[
          const SizedBox(height: 24),
          Text(
            l10n.profileMyListings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _MyListings(
            onEdit: (listing) =>
                context.push(AppRoutes.editListingPath(listing.id)),
            onDelete: (listing) => _confirmDelete(context, ref, listing),
            onChangeStatus: (listing) => _changeStatus(context, ref, listing),
            onPublish: () => _publish(context, ref),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
          label: Text(l10n.settingsTitle),
        ),
        if (!signedIn) ...[
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => requireSignIn(context, ref),
            child: Text(l10n.authLoginButton),
          ),
        ],
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
        ProfileAvatar(photoBase64: profile?.photoBase64),
        const SizedBox(height: 12),
        Text(
          profile?.displayName ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (email != null && email!.isNotEmpty)
          Text(
            email!,
            style: Theme.of(context).textTheme.bodyMedium,
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }
}

class _MyListings extends ConsumerWidget {
  const _MyListings({
    required this.onEdit,
    required this.onDelete,
    required this.onChangeStatus,
    required this.onPublish,
  });

  final void Function(Listing listing) onEdit;
  final void Function(Listing listing) onDelete;
  final void Function(Listing listing) onChangeStatus;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(myListingsProvider);
    final busy = ref.watch(profileControllerProvider).isLoading;

    return listings.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.profileListingsLoadError),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(l10n.profileNoListings, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onPublish,
                  child: Text(l10n.profilePublishFirst),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            for (final listing in items)
              _MyListingCard(
                listing: listing,
                busy: busy,
                onEdit: () => onEdit(listing),
                onDelete: () => onDelete(listing),
                onChangeStatus: () => onChangeStatus(listing),
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
    required this.onEdit,
    required this.onDelete,
    required this.onChangeStatus,
  });

  final Listing listing;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChangeStatus;

  String _priceText(AppLocalizations l10n) {
    final price = formatPrice(listing.price, currency: listing.currency);
    switch (offerTypeOf(listing)) {
      case OfferType.sale:
        return price;
      case OfferType.stay:
        return '$price ${l10n.listingDetailPerNight}';
      case OfferType.rent:
        return listing.rentPeriod == 'year'
            ? '$price ${l10n.listingDetailPerYear}'
            : '$price ${l10n.listingDetailPerMonth}';
    }
  }

  Color _chipColor(ColorScheme scheme) {
    switch (listing.status) {
      case 'available':
        return scheme.primaryContainer;
      case 'reserved':
        return scheme.tertiaryContainer;
      case 'hidden':
        return scheme.surfaceContainerHighest;
      default:
        return scheme.errorContainer;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
      child: InkWell(
        // Opens the details, like any listing of the Explore tab.
        onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: image != null
                      ? Image(image: image, fit: BoxFit.cover)
                      : ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      listing.city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _priceText(l10n),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ActionChip(
                      backgroundColor: _chipColor(theme.colorScheme),
                      label: Text(statusLabel(l10n, listing.status)),
                      onPressed: busy ? null : onChangeStatus,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.profileEditListing,
                icon: const Icon(Icons.edit_outlined),
                onPressed: busy ? null : onEdit,
              ),
              IconButton(
                tooltip: l10n.profileDeleteListing,
                icon: const Icon(Icons.delete_outline),
                onPressed: busy ? null : onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

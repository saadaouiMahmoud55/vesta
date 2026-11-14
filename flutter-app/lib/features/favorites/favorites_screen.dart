import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/filter_tag.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/require_sign_in.dart';
import '../listings/listing.dart';
import '../listings/listing_card.dart';
import '../listings/listing_repository.dart';
import 'favorites_controller.dart';
import 'favorites_repository.dart';

/// One listing read by id. Cached per id, so adding or removing one favorite
/// does not read all the other listings again.
/// The value is null when the listing no longer exists (deleted by its owner).
final favoriteListingProvider = FutureProvider.family<Listing?, String>((
  ref,
  listingId,
) async {
  final results = await ListingRepository().getListingsByIds([listingId]);
  return results.first;
});

/// Selected filter tag: null = All, otherwise one offer type.
class FavoritesFilterController extends Notifier<OfferType?> {
  @override
  OfferType? build() => null;

  void select(OfferType? type) => state = type;
}

final favoritesFilterProvider =
    NotifierProvider<FavoritesFilterController, OfferType?>(
      FavoritesFilterController.new,
    );

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).value != null;

    // A heart tap that failed (and was undone): tell the user once.
    ref.listen(favoritesControllerProvider.select((s) => s.error), (_, error) {
      if (error == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_favoritesErrorText(l10n, error))));
      ref.read(favoritesControllerProvider.notifier).clearError();
    });

    // Favorites belong to an account: a guest is asked to sign in.
    if (!signedIn) {
      return SignInPrompt(
        icon: Icons.favorite_border,
        title: l10n.tabFavorites,
      );
    }

    final ids = ref.watch(favoriteIdsProvider);
    return ids.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorState(
        message: _errorText(l10n, error),
        onRetry: () => ref.invalidate(favoriteIdsProvider),
      ),
      data: (listingIds) {
        if (listingIds.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border,
            title: l10n.favoritesEmptyTitle,
            message: l10n.favoritesEmptyBody,
            actionLabel: l10n.favoritesEmptyAction,
            // Explorer is a tab of the StatefulShellRoute: go, not push.
            onAction: () => context.go(AppRoutes.explore),
          );
        }

        final filter = ref.watch(favoritesFilterProvider);
        // Keep ids matching the tag. Deleted listings appear only under All;
        // listings still loading remain visible until their type is known.
        final shown = listingIds.where((id) {
          if (filter == null) return true;
          final listing = ref.watch(favoriteListingProvider(id));
          return listing.when(
            data: (data) => data != null && offerTypeOf(data) == filter,
            loading: () => true,
            error: (_, _) => true,
          );
        }).toList();

        return Column(
          children: [
            const _FilterTags(),
            Expanded(
              child: shown.isEmpty
                  ? EmptyState(
                      icon: Icons.filter_list_off,
                      title: l10n.favoritesFilterEmpty,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: shown.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, index) =>
                          _FavoriteItem(listingId: shown[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// The four tags on top of the list: All / Buy / Rent / Stay.
class _FilterTags extends ConsumerWidget {
  const _FilterTags();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(favoritesFilterProvider);

    final options = <(OfferType?, String)>[
      (null, l10n.favoritesFilterAll),
      (OfferType.sale, l10n.favoritesFilterBuy),
      (OfferType.rent, l10n.favoritesFilterRent),
      (OfferType.stay, l10n.favoritesFilterStay),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (type, label) in options) ...[
            FilterTag(
              label: label,
              selected: selected == type,
              onTap: () =>
                  ref.read(favoritesFilterProvider.notifier).select(type),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// One row of the list: loads its listing, then shows the card, or a
/// "no longer available" row if the listing was deleted.
class _FavoriteItem extends ConsumerWidget {
  const _FavoriteItem({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listing = ref.watch(favoriteListingProvider(listingId));

    return listing.when(
      loading: () => const Card(
        margin: EdgeInsets.zero,
        child: SizedBox(height: 120, child: LoadingView()),
      ),
      error: (error, _) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: Text(_errorText(l10n, error)),
          trailing: TextButton(
            onPressed: () => ref.invalidate(favoriteListingProvider(listingId)),
            child: Text(l10n.favoritesRetry),
          ),
        ),
      ),
      data: (data) {
        if (data == null) {
          // Deleted by its owner: no crash, and the user can clean the list.
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: Text(l10n.favoritesUnavailable),
              trailing: TextButton(
                onPressed: () => ref
                    .read(favoritesControllerProvider.notifier)
                    .toggle(listingId),
                child: Text(l10n.favoritesRemove),
              ),
            ),
          );
        }
        return ListingCard(
          listing: data,
          onTap: () => context.push(AppRoutes.listingDetailPath(data.id)),
        );
      },
    );
  }
}

/// Error enum -> translated text.
String _favoritesErrorText(AppLocalizations l10n, FavoritesError error) {
  switch (error) {
    case FavoritesError.noNetwork:
      return l10n.favoritesErrorNoNetwork;
    case FavoritesError.permissionDenied:
      return l10n.favoritesErrorPermission;
    case FavoritesError.notSignedIn:
      return l10n.favoritesErrorNotSignedIn;
    case FavoritesError.unknown:
      return l10n.favoritesErrorUnknown;
  }
}

/// Any error coming from a repository -> translated text.
String _errorText(AppLocalizations l10n, Object error) {
  if (error is FavoritesFailure) {
    return _favoritesErrorText(l10n, error.error);
  }
  if (error is ListingFailure && error.error == ListingError.noNetwork) {
    return l10n.favoritesErrorNoNetwork;
  }
  return l10n.favoritesErrorUnknown;
}

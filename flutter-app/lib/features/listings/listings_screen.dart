import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import 'explore_welcome.dart';
import 'listing.dart';
import 'listing_card.dart';
import 'listing_repository.dart';

/// Newest listings for the Explore tab. Pull down to read them again.
final latestListingsProvider = FutureProvider<List<Listing>>(
  (ref) => ListingRepository().getLatestListings(),
);

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(latestListingsProvider);

    return listings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorText(l10n, error), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(latestListingsProvider),
                child: Text(l10n.favoritesRetry),
              ),
            ],
          ),
        ),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () => ref.refresh(latestListingsProvider.future),
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    child: Center(child: Text(l10n.listingsEmpty)),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                // Item 0 is the welcome header (signed-in users only).
                itemCount: items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  if (index == 0) return const _WelcomeHeader();
                  final listing = items[index - 1];
                  return ListingCard(
                    listing: listing,
                    onTap: () => context.push(
                      AppRoutes.listingDetailPath(listing.id),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _errorText(AppLocalizations l10n, Object error) {
    if (error is ListingFailure && error.error == ListingError.noNetwork) {
      return l10n.favoritesErrorNoNetwork;
    }
    return l10n.favoritesErrorUnknown;
  }
}

/// Logo and "Welcome back, name" for a signed-in user; nothing for a guest.
class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();
    final profile = ref.watch(myProfileProvider).value;
    final name = (profile?.displayName ?? '').trim().isNotEmpty
        ? profile!.displayName
        : (user.displayName ?? '');
    return ExploreWelcome(
      name: name,
      isNew: isFirstSignIn(
        user.metadata.creationTime,
        user.metadata.lastSignInTime,
      ),
    );
  }
}

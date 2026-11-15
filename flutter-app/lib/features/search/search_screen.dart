import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

import '../../core/router/app_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../listings/listing_card.dart';
import '../listings/listing_repository.dart';
import 'search_filters_notifier.dart';
import 'search_filters_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authStateProvider.select((a) => a.value?.uid),
      (_, _) => _controller.clear(),
    );
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(searchResultsProvider);
    final filters = ref.watch(searchFiltersProvider);
    // The city has its own text field: the badge counts the panel filters only.
    final panelCount =
        filters.activeCount - (filters.city.trim().isNotEmpty ? 1 : 0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  // The notifier waits 400 ms after the last keystroke.
                  onChanged: ref.read(searchFiltersProvider.notifier).setCity,
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: panelCount > 0,
                label: Text('$panelCount'),
                child: IconButton.filledTonal(
                  tooltip: l10n.searchFilters,
                  icon: const Icon(Icons.tune),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const SearchFiltersSheet(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: results.when(
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
                      onPressed: () =>
                          ref.invalidate(searchableListingsProvider),
                      child: Text(l10n.favoritesRetry),
                    ),
                  ],
                ),
              ),
            ),
            data: (items) => RefreshIndicator(
              onRefresh: () => ref.refresh(searchableListingsProvider.future),
              child: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: Center(child: Text(l10n.searchNoResults)),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => ListingCard(
                        listing: items[index],
                        onTap: () => context.push(
                          AppRoutes.listingDetailPath(items[index].id),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _errorText(AppLocalizations l10n, Object error) {
    if (error is ListingFailure && error.error == ListingError.noNetwork) {
      return l10n.favoritesErrorNoNetwork;
    }
    return l10n.favoritesErrorUnknown;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../listings/listing.dart';
import '../listings/listing_repository.dart';
import 'search_filters_notifier.dart';

/// Bottom sheet with the price, offer type and property type filters.
/// The values are applied only when the user taps "Apply".
class SearchFiltersSheet extends ConsumerStatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  ConsumerState<SearchFiltersSheet> createState() =>
      _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late final TextEditingController _min;
  late final TextEditingController _max;
  OfferType? _offerType;
  String? _propertyType;

  @override
  void initState() {
    super.initState();
    final f = ref.read(searchFiltersProvider);
    _min = TextEditingController(text: f.minPrice?.toString() ?? '');
    _max = TextEditingController(text: f.maxPrice?.toString() ?? '');
    _offerType = f.offerType;
    _propertyType = f.propertyType;
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _apply() {
    final notifier = ref.read(searchFiltersProvider.notifier);
    notifier.setPriceRange(
      min: num.tryParse(_min.text.trim()),
      max: num.tryParse(_max.text.trim()),
    );
    notifier.setOfferType(_offerType);
    notifier.setPropertyType(_propertyType);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _min.clear();
      _max.clear();
      _offerType = null;
      _propertyType = null;
    });
  }

  String _propertyLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'apartment':
        return l10n.searchPropApartment;
      case 'house':
        return l10n.searchPropHouse;
      case 'villa':
        return l10n.searchPropVilla;
      case 'studio':
        return l10n.searchPropStudio;
      case 'riad':
        return l10n.searchPropRiad;
      case 'guest_house':
        return l10n.searchPropGuestHouse;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.searchFilters, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _priceField(_min, l10n.searchPriceMin)),
                const SizedBox(width: 12),
                Expanded(child: _priceField(_max, l10n.searchPriceMax)),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.searchOfferType, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _chip(l10n.searchAll, _offerType == null,
                    () => setState(() => _offerType = null)),
                _chip(l10n.searchTypeSale, _offerType == OfferType.sale,
                    () => setState(() => _offerType = OfferType.sale)),
                _chip(l10n.searchTypeRent, _offerType == OfferType.rent,
                    () => setState(() => _offerType = OfferType.rent)),
                _chip(l10n.searchTypeStay, _offerType == OfferType.stay,
                    () => setState(() => _offerType = OfferType.stay)),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.searchPropertyType, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _chip(l10n.searchAll, _propertyType == null,
                    () => setState(() => _propertyType = null)),
                for (final type in propertyTypes)
                  _chip(_propertyLabel(l10n, type), _propertyType == type,
                      () => setState(() => _propertyType = type)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: Text(l10n.searchReset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(l10n.searchApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
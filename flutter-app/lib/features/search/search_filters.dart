import '../listings/listing.dart';

/// Accented letters and the plain letter that replaces each of them.
const String _accentsFrom = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const String _accentsTo = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Lower case, no accents, no spaces around: "  Gabès " becomes "gabes".
/// Arabic text is kept as it is (it has no case and no accents to remove).
String normalizeSearchText(String input) {
  final lower = input.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = _accentsFrom.indexOf(char);
    buffer.write(index == -1 ? char : _accentsTo[index]);
  }
  return buffer.toString();
}

/// Filters of the search screen. Pure data and logic: no Firebase here,
/// so it is easy to test.
///
/// WHY THE FILTERING IS DONE IN THE APP (VST-40, point 3):
/// Firestore needs one composite index per filter combination, and a price
/// range forces the first sort on `price` (so no "newest first"). The
/// repository only reads the newest listings (no index needed) and this
/// class filters that small list. If the app grows to thousands of
/// listings, move the main filters into the Firestore query.
class SearchFilters {
  const SearchFilters({
    this.minPrice,
    this.maxPrice,
    this.city = '',
    this.offerType,
    this.propertyType,
  });

  final num? minPrice;
  final num? maxPrice;
  final String city; // free text, matched with "contains"
  // The rule is offerTypeOf (docs/offer-types.md), never listingType alone:
  // a stay (rent per night) is not a rent.
  final OfferType? offerType; // null = all
  final String? propertyType; // null = all

  static const Object _keep = Object();

  /// Pass an explicit null to clear a field; omit it to keep the value.
  SearchFilters copyWith({
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    String? city,
    Object? offerType = _keep,
    Object? propertyType = _keep,
  }) {
    return SearchFilters(
      minPrice: identical(minPrice, _keep) ? this.minPrice : minPrice as num?,
      maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as num?,
      city: city ?? this.city,
      offerType: identical(offerType, _keep)
          ? this.offerType
          : offerType as OfferType?,
      propertyType: identical(propertyType, _keep)
          ? this.propertyType
          : propertyType as String?,
    );
  }

  /// Number of active filters (for a badge on the filter button).
  int get activeCount =>
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (city.trim().isNotEmpty ? 1 : 0) +
      (offerType != null ? 1 : 0) +
      (propertyType != null ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  bool matches(Listing listing) {
    if (minPrice != null && listing.price < minPrice!) return false;
    if (maxPrice != null && listing.price > maxPrice!) return false;
    if (offerType != null && offerTypeOf(listing) != offerType) return false;
    if (propertyType != null && listing.propertyType != propertyType) {
      return false;
    }
    final query = normalizeSearchText(city);
    // The text matches the city or the title of the listing.
    if (query.isNotEmpty &&
        !normalizeSearchText(listing.city).contains(query) &&
        !normalizeSearchText(listing.title).contains(query)) {
      return false;
    }
    return true;
  }

  /// Keeps the order of [listings] (already newest first).
  /// A sold, rented, unavailable or hidden listing stays visible in the
  /// favorites but is not offered by the search.
  List<Listing> apply(List<Listing> listings) =>
      listings.where((l) => !l.isUnavailable && matches(l)).toList();
}
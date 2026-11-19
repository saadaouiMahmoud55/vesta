import 'package:cloud_firestore/cloud_firestore.dart';

/// One listing, as read from the `listings` collection.
/// Photos are NOT here: they live in `listings/{id}/photos` and are read
/// separately (see ListingRepository.getCoverPhotoBase64).
class Listing {
  const Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.listingType,
    required this.propertyType,
    required this.city,
    required this.status,
    required this.photoCount,
    this.rentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.areaSqm,
    this.latitude,
    this.longitude,
    this.maxGuests,
    this.amenities = const [],
    this.checkIn,
    this.checkOut,
    this.houseRules = const [],
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final num price;
  final String currency;
  final String listingType; // 'sale' or 'rent'
  final String? rentPeriod; // 'night', 'month' or 'year' (rent only)
  final String propertyType;
  final String city;
  final String status;
  final int photoCount;
  final num? bedrooms;
  final num? bathrooms;
  final num? areaSqm;
  final double? latitude;
  final double? longitude;

  /// True when the owner gave a usable position (shown on the map, VST-42).
  bool get hasLocation {
    final lat = latitude;
    final lng = longitude;
    return lat != null &&
        lng != null &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  final num? maxGuests;
  final List<String> amenities; // keys of amenityKeys
  final String? checkIn; // 'HH:mm'
  final String? checkOut; // 'HH:mm'
  final List<String> houseRules; // keys of houseRuleKeys

  factory Listing.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Listing(
      id: doc.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      price: (data['price'] as num?) ?? 0,
      currency: (data['currency'] as String?) ?? '',
      listingType: (data['listingType'] as String?) ?? 'sale',
      rentPeriod: data['rentPeriod'] as String?,
      propertyType: (data['propertyType'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      // A missing status means "available" (see docs/data-model.md).
      status: (data['status'] as String?) ?? 'available',
      photoCount: (data['photoCount'] as num?)?.toInt() ?? 0,
      bedrooms: data['bedrooms'] as num?,
      bathrooms: data['bathrooms'] as num?,
      areaSqm: data['areaSqm'] as num?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      maxGuests: data['maxGuests'] as num?,
      amenities: _stringList(data['amenities']),
      checkIn: data['checkIn'] as String?,
      checkOut: data['checkOut'] as String?,
      houseRules: _stringList(data['houseRules']),
    );
  }
}

/// A list of strings from Firestore. Anything else gives an empty list.
List<String> _stringList(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is String) e,
      ]
    : const [];

/// The three offer types of Vesta (docs/offer-types.md). A product view on
/// `listingType` and `rentPeriod`: no `offerType` field is stored.
enum OfferType { sale, rent, stay }

/// Single place that decides the offer type. Screens never re-implement it.
OfferType offerTypeOf(Listing listing) {
  if (listing.listingType == 'sale') return OfferType.sale;
  // listingType == 'rent': per night is a stay, per month or year is a rent.
  return listing.rentPeriod == 'night' ? OfferType.stay : OfferType.rent;
}

/// Statuses that mean "nobody can take this listing now".
/// `reserved` is not here: the listing is still shown normally.
const Set<String> _unavailableStatuses = {
  'sold',
  'rented',
  'unavailable',
  'hidden',
};

extension ListingAvailability on Listing {
  /// A favorite that is unavailable stays in the list with a grey label.
  bool get isUnavailable => _unavailableStatuses.contains(status);
}

/// Statuses an owner can choose, by offer type (docs/data-model.md and the
/// Firestore rules). The order is the order of the choices in the sheet.
List<String> allowedStatuses(OfferType type) {
  switch (type) {
    case OfferType.sale:
      return const ['available', 'reserved', 'sold', 'hidden'];
    case OfferType.rent:
      return const ['available', 'reserved', 'rented', 'hidden'];
    case OfferType.stay:
      return const ['available', 'unavailable', 'hidden'];
  }
}

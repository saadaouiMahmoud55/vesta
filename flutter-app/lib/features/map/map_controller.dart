import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../listings/listing.dart';
import '../listings/listing_controller.dart';
import 'location_service.dart';
import 'tunisia_places.dart';

/// How many of the newest listings the map reads. Same idea as the search:
/// one small read, no index (see search_filters.dart).
const int mapListLimit = 100;

/// One pin of the map: the listing and where to draw it.
class MapPin {
  const MapPin({required this.listing, required this.point, required this.exact});

  final Listing listing;
  final LatLng point;

  /// true: the owner placed the pin. false: the position is the center of the
  /// listing's city (the owner gave no exact position).
  final bool exact;
}

/// The pins to draw: every available listing, at its exact position when it
/// has one, otherwise at the center of its city when the city is a known
/// place (listings without a known place are left out). Approximate pins of
/// the same city are spread on a small spiral so they do not hide each other.
/// Pure function, easy to test.
List<MapPin> pinsFor(Iterable<Listing> listings) {
  final pins = <MapPin>[];
  final countByCity = <String, int>{};
  for (final listing in listings) {
    if (listing.isUnavailable) continue;
    if (listing.hasLocation) {
      pins.add(
        MapPin(
          listing: listing,
          point: LatLng(listing.latitude!, listing.longitude!),
          exact: true,
        ),
      );
      continue;
    }
    final place = placeByName(listing.city);
    if (place == null) continue;
    final k = countByCity.update(place.name, (n) => n + 1, ifAbsent: () => 0);
    pins.add(MapPin(listing: listing, point: _spiral(place.point, k), exact: false));
  }
  return pins;
}

/// The [k]-th point around [center]: 0 is the center itself, then about
/// 450 m * sqrt(k) away, turning by the golden angle.
LatLng _spiral(LatLng center, int k) {
  if (k == 0) return center;
  const goldenAngle = 2.399963;
  final radius = 0.004 * math.sqrt(k);
  final angle = k * goldenAngle;
  return LatLng(
    center.latitude + radius * math.sin(angle),
    center.longitude + radius * math.cos(angle) / math.cos(center.latitude * math.pi / 180),
  );
}

final mapListingsProvider = FutureProvider.autoDispose<List<MapPin>>((
  ref,
) async {
  final all = await ref
      .watch(listingRepositoryProvider)
      .getLatestListings(limit: mapListLimit);
  return pinsFor(all);
});

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

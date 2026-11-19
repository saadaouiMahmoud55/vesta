import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/map/map_controller.dart';
import 'package:flutterapp/features/map/map_listing_preview.dart';
import 'package:flutterapp/features/map/tunisia_places.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

Listing _listing({
  String id = 'a',
  double? latitude = 36.8,
  double? longitude = 10.18,
  String status = 'available',
  String listingType = 'sale',
  String? rentPeriod,
}) {
  return Listing(
    id: id,
    ownerId: 'owner',
    title: 'Riad à Tozeur',
    description: '',
    price: 120,
    currency: 'TND',
    listingType: listingType,
    rentPeriod: rentPeriod,
    propertyType: 'riad',
    city: 'Tozeur',
    status: status,
    photoCount: 0,
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('hasLocation', () {
    test('needs both numbers', () {
      expect(_listing().hasLocation, isTrue);
      expect(_listing(latitude: null).hasLocation, isFalse);
      expect(_listing(longitude: null).hasLocation, isFalse);
    });

    test('refuses values outside the globe', () {
      expect(_listing(latitude: 91).hasLocation, isFalse);
      expect(_listing(longitude: -181).hasLocation, isFalse);
      expect(_listing(latitude: 0, longitude: 0).hasLocation, isTrue);
    });
  });

  group('pinsFor', () {
    test('an exact position is used as it is', () {
      final pins = pinsFor([_listing(id: 'a', latitude: 33.9, longitude: 8.1)]);
      expect(pins, hasLength(1));
      expect(pins.single.exact, isTrue);
      expect(pins.single.point, const LatLng(33.9, 8.1));
    });

    test('no exact position: the listing is placed at the center of its city',
        () {
      final pins = pinsFor([_listing(latitude: null, longitude: null)]);
      expect(pins, hasLength(1));
      expect(pins.single.exact, isFalse);
      expect(pins.single.point, placeByName('Tozeur')!.point);
    });

    test('unknown city and no position: no pin', () {
      final listing = Listing(
        id: 'x',
        ownerId: 'o',
        title: 't',
        description: '',
        price: 1,
        currency: 'TND',
        listingType: 'sale',
        propertyType: 'house',
        city: 'Atlantis',
        status: 'available',
        photoCount: 0,
      );
      expect(pinsFor([listing]), isEmpty);
    });

    test('sold, rented and hidden listings are not drawn', () {
      final pins = pinsFor([
        _listing(id: 'ok'),
        _listing(id: 'sold', status: 'sold'),
        _listing(id: 'rented', status: 'rented'),
        _listing(id: 'hidden', status: 'hidden'),
        _listing(id: 'reserved', status: 'reserved'),
      ]);
      expect(pins.map((p) => p.listing.id), ['ok', 'reserved']);
    });

    test('several listings of one city do not hide each other', () {
      final pins = pinsFor([
        for (var i = 0; i < 4; i++)
          _listing(id: 'l$i', latitude: null, longitude: null),
      ]);
      final points = pins.map((p) => p.point).toSet();
      expect(points, hasLength(4));
      // The first one is on the city center, the others stay close (< 2 km).
      expect(pins.first.point, placeByName('Tozeur')!.point);
      for (final pin in pins) {
        expect((pin.point.latitude - 33.9197).abs(), lessThan(0.02));
        expect((pin.point.longitude - 8.1335).abs(), lessThan(0.02));
      }
    });
  });

  group('preview card', () {
    Future<void> pump(
      WidgetTester tester,
      Listing listing, {
      VoidCallback? onOpen,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MapListingPreview(listing: listing, onOpen: onOpen ?? () {}),
          ),
        ),
      );
    }

    testWidgets('shows title, city and a sale price without unit',
        (tester) async {
      await pump(tester, _listing());
      expect(find.text('Riad à Tozeur'), findsOneWidget);
      expect(find.text('Tozeur'), findsOneWidget);
      expect(find.text('TND 120'), findsOneWidget);
    });

    testWidgets('shows the unit for a stay and for a monthly rent',
        (tester) async {
      await pump(tester, _listing(listingType: 'rent', rentPeriod: 'night'));
      expect(find.text('TND 120 / night'), findsOneWidget);

      await pump(tester, _listing(listingType: 'rent', rentPeriod: 'month'));
      expect(find.text('TND 120 / month'), findsOneWidget);
    });

    testWidgets('a tap on the card opens the details', (tester) async {
      var opened = 0;
      await pump(tester, _listing(), onOpen: () => opened++);
      await tester.tap(find.text('Riad à Tozeur'));
      expect(opened, 1);
      await tester.tap(find.text('View details'));
      expect(opened, 2);
    });
  });
}

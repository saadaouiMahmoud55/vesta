import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing.dart';
import 'package:flutterapp/features/search/search_filters.dart';
import 'package:flutterapp/features/search/search_filters_notifier.dart';
import 'package:flutterapp/features/auth/auth_controller.dart';

Listing _listing({
  required String id,
  num price = 100,
  String listingType = 'sale',
  String? rentPeriod,
  String propertyType = 'apartment',
  String city = 'Tunis',
  String status = 'available',
}) {
  return Listing(
    id: id,
    ownerId: 'owner',
    title: 't$id',
    description: '',
    price: price,
    currency: 'TND',
    listingType: listingType,
    rentPeriod: rentPeriod ?? (listingType == 'rent' ? 'month' : null),
    propertyType: propertyType,
    city: city,
    status: status,
    photoCount: 1,
  );
}

void main() {
  final all = [
    _listing(id: 'a', price: 500, listingType: 'rent', city: 'Sousse'),
    _listing(id: 'b', price: 900000, propertyType: 'villa', city: 'Tunis'),
    _listing(id: 'c', price: 300, listingType: 'rent', city: 'Sousse'),
    _listing(id: 'd', price: 250000, propertyType: 'house', city: 'Sfax'),
    // A stay: rent per night.
    _listing(
      id: 'e',
      price: 150,
      listingType: 'rent',
      rentPeriod: 'night',
      propertyType: 'guest_house',
      city: 'Hammamet',
    ),
    // Sold: never offered by the search.
    _listing(id: 'f', price: 400000, city: 'Tunis', status: 'sold'),
    _listing(id: 'g', price: 180000, city: 'Gabès'),
    _listing(id: 'h', price: 700, listingType: 'rent', city: 'Médenine'),
    _listing(id: 'i', price: 120000, city: 'تونس'),
  ];

  List<String> ids(SearchFilters f) => f.apply(all).map((l) => l.id).toList();

  test('no filter keeps the available listings, in the same order', () {
    expect(ids(const SearchFilters()), [
      'a',
      'b',
      'c',
      'd',
      'e',
      'g',
      'h',
      'i',
    ]);
  });

  test('price range', () {
    expect(ids(const SearchFilters(minPrice: 300, maxPrice: 500)), ['a', 'c']);
    // f (900000 is b, 400000 is f but sold): only b is left.
    expect(ids(const SearchFilters(minPrice: 400000)), ['b']);
  });

  test('city: contains, case-insensitive', () {
    expect(ids(const SearchFilters(city: 'sou')), ['a', 'c']);
    // The text also matches the title ('td' is the title of listing d).
    expect(ids(const SearchFilters(city: 'td')), ['d']);
    expect(ids(const SearchFilters(city: '  TUN ')), ['b']);
  });

  test('city: accents are ignored on both sides', () {
    expect(ids(const SearchFilters(city: 'gabes')), ['g']);
    expect(ids(const SearchFilters(city: 'GABÈS')), ['g']);
    expect(ids(const SearchFilters(city: 'medenine')), ['h']);
    expect(ids(const SearchFilters(city: 'Médenine')), ['h']);
  });

  test('city: Arabic text is matched as it is', () {
    expect(ids(const SearchFilters(city: 'تونس')), ['i']);
  });

  test('offer type: a stay is not a rent', () {
    expect(ids(const SearchFilters(offerType: OfferType.rent)), [
      'a',
      'c',
      'h',
    ]);
    expect(ids(const SearchFilters(offerType: OfferType.stay)), ['e']);
    expect(ids(const SearchFilters(offerType: OfferType.sale)), [
      'b',
      'd',
      'g',
      'i',
    ]);
  });

  test('property type', () {
    expect(ids(const SearchFilters(propertyType: 'villa')), ['b']);
  });

  test('combination of 3 filters', () {
    const f = SearchFilters(
      city: 'sousse',
      offerType: OfferType.rent,
      maxPrice: 400,
    );
    expect(ids(f), ['c']);
    expect(f.activeCount, 3);
  });

  test('sold, rented, unavailable and hidden listings are skipped', () {
    final list = [
      _listing(id: 'x', status: 'sold'),
      _listing(id: 'y', listingType: 'rent', status: 'rented'),
      _listing(id: 'z', status: 'unavailable'),
      _listing(id: 'w', status: 'hidden'),
      _listing(id: 'r', status: 'reserved'),
    ];
    final result = const SearchFilters().apply(list).map((l) => l.id).toList();
    expect(result, ['r']);
  });

  test('normalizeSearchText removes case, accents and outer spaces', () {
    expect(normalizeSearchText('  Gabès '), 'gabes');
    expect(normalizeSearchText('Médenine'), 'medenine');
    expect(normalizeSearchText('Sousse'), 'sousse');
  });

  test('copyWith clears a field with null and keeps it when omitted', () {
    const f = SearchFilters(minPrice: 10, offerType: OfferType.rent);
    expect(f.copyWith(minPrice: null).minPrice, isNull);
    expect(f.copyWith(offerType: null).offerType, isNull);
    expect(f.copyWith(city: 'x').minPrice, 10);
    expect(f.copyWith(city: 'x').offerType, OfferType.rent);
  });

  test('city is applied only 400 ms after the last keystroke', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(searchFiltersProvider.notifier);

    notifier.setCity('s');
    notifier.setCity('so');
    notifier.setCity('sou');
    expect(container.read(searchFiltersProvider).city, '');

    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(container.read(searchFiltersProvider).city, 'sou');
  });

  test('filters reset when the signed-in user changes', () async {
    final auth = StreamController<User?>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [authStateProvider.overrideWith((ref) => auth.stream)],
    );
    addTearDown(container.dispose);

    container.listen(searchFiltersProvider, (_, _) {});
    auth.add(_FakeUser('a'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.read(searchFiltersProvider.notifier).setOfferType(OfferType.rent);
    expect(container.read(searchFiltersProvider).offerType, OfferType.rent);

    auth.add(_FakeUser('b'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(searchFiltersProvider).offerType, isNull);
  });
}

class _FakeUser extends Fake implements User {
  _FakeUser(this.uid);
  @override
  final String uid;
}

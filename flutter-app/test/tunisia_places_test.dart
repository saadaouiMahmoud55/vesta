import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/map/tunisia_places.dart';

void main() {
  test('every place is inside Tunisia and has both names', () {
    for (final place in tunisiaPlaces) {
      expect(place.name, isNotEmpty);
      expect(place.nameAr, isNotEmpty);
      expect(place.latitude, inInclusiveRange(30.2, 37.6), reason: place.name);
      expect(place.longitude, inInclusiveRange(7.5, 11.6), reason: place.name);
    }
    final names = tunisiaPlaces.map((p) => p.name).toList();
    expect(names.toSet(), hasLength(names.length), reason: 'duplicate name');
  });

  test('the 24 governorate capitals are there', () {
    for (final name in [
      'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Zaghouan',
      'Bizerte', 'Béja', 'Jendouba', 'Le Kef', 'Siliana', 'Sousse',
      'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid',
      'Gabès', 'Médenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kébili',
    ]) {
      expect(placeByName(name), isNotNull, reason: name);
    }
  });

  group('placeByName', () {
    test('ignores case and accents, understands Arabic', () {
      expect(placeByName('gabes')?.name, 'Gabès');
      expect(placeByName('  MEDENINE ')?.name, 'Médenine');
      expect(placeByName('توزر')?.name, 'Tozeur');
    });

    test('unknown or empty text gives null', () {
      expect(placeByName('Atlantis'), isNull);
      expect(placeByName(''), isNull);
      expect(placeByName(null), isNull);
    });
  });

  group('searchPlaces', () {
    test('finds by the start of the name, Latin or Arabic', () {
      expect(searchPlaces('toz').map((p) => p.name), ['Tozeur']);
      expect(searchPlaces('تو').map((p) => p.name), contains('Tozeur'));
    });

    test('names that start with the text come before those that contain it',
        () {
      final names = searchPlaces('sou').map((p) => p.name).toList();
      expect(names.first, 'Sousse');
      expect(names, contains('Hammam Sousse'));
      expect(names.indexOf('Sousse'), lessThan(names.indexOf('Hammam Sousse')));
    });

    test('accents do not matter and the result is limited', () {
      expect(searchPlaces('gabes').map((p) => p.name), ['Gabès']);
      expect(searchPlaces('a', limit: 3), hasLength(3));
    });

    test('an empty query gives nothing', () {
      expect(searchPlaces(''), isEmpty);
      expect(searchPlaces('   '), isEmpty);
    });
  });
}

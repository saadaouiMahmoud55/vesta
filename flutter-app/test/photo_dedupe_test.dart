import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_repository.dart';
import 'package:flutterapp/features/listings/photo_service.dart';

void main() {
  test('the maximum is 10 (ids p0 to p9)', () {
    expect(maxListingPhotos, 10);
  });

  test('new photos are added after the existing ones', () {
    final r = addUniquePhotos(['a'], ['b', 'c'], max: 10);
    expect(r.photos, ['a', 'b', 'c']);
    expect(r.duplicates, isFalse);
    expect(r.overLimit, isFalse);
  });

  test('a photo already in the list is not added again', () {
    final r = addUniquePhotos(['a', 'b'], ['b', 'c'], max: 10);
    expect(r.photos, ['a', 'b', 'c']);
    expect(r.duplicates, isTrue);
  });

  test('the same photo twice in one pick is added once', () {
    final r = addUniquePhotos([], ['a', 'a', 'b'], max: 10);
    expect(r.photos, ['a', 'b']);
    expect(r.duplicates, isTrue);
  });

  test('the list never goes above the maximum', () {
    final current = [for (var i = 0; i < 8; i++) 'p$i'];
    final r = addUniquePhotos(current, ['x', 'y', 'z'], max: 10);
    expect(r.photos.length, 10);
    expect(r.photos.last, 'y');
    expect(r.overLimit, isTrue);
    expect(r.duplicates, isFalse);
  });

  test('a full list refuses new photos and keeps the order', () {
    final current = [for (var i = 0; i < 10; i++) 'p$i'];
    final r = addUniquePhotos(current, ['x'], max: 10);
    expect(r.photos, current);
    expect(r.overLimit, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_repository.dart';

void main() {
  test('stalePhotoIds lists every id after the new photos', () {
    expect(stalePhotoIds(3), ['p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9']);
    expect(stalePhotoIds(10), isEmpty);
  });
}

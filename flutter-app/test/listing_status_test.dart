import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing.dart';

void main() {
  test('allowed statuses depend on the offer type', () {
    expect(allowedStatuses(OfferType.sale), [
      'available',
      'reserved',
      'sold',
      'hidden',
    ]);
    expect(allowedStatuses(OfferType.rent), [
      'available',
      'reserved',
      'rented',
      'hidden',
    ]);
    expect(allowedStatuses(OfferType.stay), [
      'available',
      'unavailable',
      'hidden',
    ]);
  });

  test('a stay can not be sold or rented, a sale can not be unavailable', () {
    expect(allowedStatuses(OfferType.stay), isNot(contains('sold')));
    expect(allowedStatuses(OfferType.stay), isNot(contains('rented')));
    expect(allowedStatuses(OfferType.sale), isNot(contains('unavailable')));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';

void main() {
  test('guests: empty is fine, 1 to 30 only, whole numbers', () {
    expect(validateGuests(''), isNull);
    expect(validateGuests('1'), isNull);
    expect(validateGuests('30'), isNull);
    expect(validateGuests('0'), ListingFieldError.guestsInvalid);
    expect(validateGuests('31'), ListingFieldError.guestsInvalid);
    expect(validateGuests('2.5'), ListingFieldError.guestsInvalid);
    expect(validateGuests('abc'), ListingFieldError.guestsInvalid);
  });

  test('rooms: empty is fine, 0 to 20 only, whole numbers', () {
    expect(validateRooms(''), isNull);
    expect(validateRooms('0'), isNull);
    expect(validateRooms('20'), isNull);
    expect(validateRooms('21'), ListingFieldError.roomsInvalid);
    expect(validateRooms('-1'), ListingFieldError.roomsInvalid);
    expect(validateRooms('1.5'), ListingFieldError.roomsInvalid);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_controller.dart';

void main() {
  group('validatePrice (VST-104)', () {
    test('accepts normal prices and the maximum', () {
      expect(validatePrice('1'), isNull);
      expect(validatePrice('150000'), isNull);
      expect(validatePrice(' 900.5 '), isNull);
      expect(validatePrice('50000000'), isNull);
    });

    test('rejects 0, negative and above the maximum', () {
      expect(validatePrice('0'), ListingFieldError.priceInvalid);
      expect(validatePrice('-5'), ListingFieldError.priceInvalid);
      expect(validatePrice('50000001'), ListingFieldError.priceInvalid);
      expect(
        validatePrice('9223372036854775807'),
        ListingFieldError.priceInvalid,
      );
    });

    test('rejects empty, text, NaN and Infinity', () {
      expect(validatePrice(null), ListingFieldError.priceInvalid);
      expect(validatePrice(''), ListingFieldError.priceInvalid);
      expect(validatePrice('abc'), ListingFieldError.priceInvalid);
      expect(validatePrice('NaN'), ListingFieldError.priceInvalid);
      expect(validatePrice('Infinity'), ListingFieldError.priceInvalid);
      expect(validatePrice('-Infinity'), ListingFieldError.priceInvalid);
    });
  });
}

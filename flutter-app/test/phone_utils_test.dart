import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/core/utils/phone_utils.dart';

void main() {
  group('normalizeTunisianPhone', () {
    test('accepts a local 8-digit number', () {
      expect(normalizeTunisianPhone('92816836'), '+21692816836');
    });

    test('accepts +216 prefix', () {
      expect(normalizeTunisianPhone('+21692816836'), '+21692816836');
    });

    test('accepts 00216 prefix', () {
      expect(normalizeTunisianPhone('0021692816836'), '+21692816836');
    });

    test('accepts 216 prefix', () {
      expect(normalizeTunisianPhone('21692816836'), '+21692816836');
    });

    test('ignores spaces and dashes', () {
      expect(normalizeTunisianPhone('92 816 836'), '+21692816836');
      expect(normalizeTunisianPhone('+216 92-816-836'), '+21692816836');
    });

    test('refuses a first digit of 1, 0, 6 or 8', () {
      expect(normalizeTunisianPhone('12345678'), isNull);
      expect(normalizeTunisianPhone('62816836'), isNull);
    });

    test('refuses wrong length', () {
      expect(normalizeTunisianPhone('9281683'), isNull);
      expect(normalizeTunisianPhone('928168360'), isNull);
    });

    test('refuses letters and empty input', () {
      expect(normalizeTunisianPhone('9281683a'), isNull);
      expect(normalizeTunisianPhone(''), isNull);
    });
  });

  group('isValidTunisianPhone', () {
    test('true for a valid number', () {
      expect(isValidTunisianPhone('+216 92 816 836'), isTrue);
    });

    test('false for an invalid number', () {
      expect(isValidTunisianPhone('12345678'), isFalse);
    });
  });

  group('formatPhone', () {
    test('formats an E.164 number', () {
      expect(formatPhone('+21692816836'), '+216 92 816 836');
    });

    test('returns the input if invalid', () {
      expect(formatPhone('abc'), 'abc');
    });
  });
}

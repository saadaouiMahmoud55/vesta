import 'package:flutter_test/flutter_test.dart';

import '../lib/features/profile/profile_controller.dart';
import '../lib/features/profile/profile_messages.dart';
import '../lib/features/profile/user_repository.dart';
import '../lib/l10n/generated/app_localizations_en.dart';

void main() {
  group('validatePhone', () {
    test('empty is allowed (phone is optional)', () {
      expect(validatePhone(null), isNull);
      expect(validatePhone('   '), isNull);
    });

    test('valid Tunisian numbers pass', () {
      expect(validatePhone('20 123 456'), isNull);
      expect(validatePhone('+216 92 816 836'), isNull);
    });

    test('invalid numbers are rejected', () {
      expect(validatePhone('123'), ProfileError.phoneInvalid);
      expect(validatePhone('+33 6 12 34 56 78'), ProfileError.phoneInvalid);
    });
  });

  test('phoneInvalid has a translated message', () {
    final l10n = AppLocalizationsEn();
    expect(
      profileErrorMessage(l10n, ProfileError.phoneInvalid),
      l10n.profileErrorPhoneInvalid,
    );
  });
}
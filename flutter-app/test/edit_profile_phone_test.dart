import 'package:flutter_test/flutter_test.dart';

import 'package:flutterapp/features/profile/profile_controller.dart';
import 'package:flutterapp/features/profile/profile_messages.dart';
import 'package:flutterapp/features/profile/user_repository.dart';
import 'package:flutterapp/l10n/generated/app_localizations_en.dart';

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

  group('email change validation', () {
    test('invalid emails are rejected', () {
      expect(validateEmail(''), ProfileError.emailInvalid);
      expect(validateEmail('abc'), ProfileError.emailInvalid);
      expect(validateEmail('a@b'), ProfileError.emailInvalid);
    });

    test('a valid email passes', () {
      expect(validateEmail('nom@exemple.com'), isNull);
    });

    test('an empty password is rejected', () {
      expect(validatePassword(''), ProfileError.passwordRequired);
      expect(validatePassword('secret1'), isNull);
    });

    test('email errors have translated messages', () {
      final l10n = AppLocalizationsEn();
      for (final e in [
        ProfileError.emailInvalid,
        ProfileError.emailInUse,
        ProfileError.wrongPassword,
        ProfileError.passwordRequired,
      ]) {
        expect(profileErrorMessage(l10n, e), isNotEmpty);
      }
    });
  });
}

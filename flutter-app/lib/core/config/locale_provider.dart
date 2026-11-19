import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages the app is translated into.
const supportedLanguageCodes = ['ar', 'fr', 'en'];

const _localeKey = 'app_language';

/// Selected app language. `null` means "follow the phone language": the app
/// uses it when it is ar, fr or en, and falls back to Arabic otherwise.
///
/// The choice is saved on the phone and restored at the next launch.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey);
      if (code != null && supportedLanguageCodes.contains(code)) {
        state = Locale(code);
      }
    } catch (_) {
      // Storage not available: keep following the phone language.
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_localeKey);
      } else {
        await prefs.setString(_localeKey, locale.languageCode);
      }
    } catch (_) {
      // The language still changes for this session.
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

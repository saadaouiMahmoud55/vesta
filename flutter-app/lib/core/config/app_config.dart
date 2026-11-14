import 'package:intl/intl.dart';

/// Single place for market settings. Never hard-code these values elsewhere.
class AppConfig {
  AppConfig._();

  /// Currency code stored with every listing price (3 letters).
  static const String currency = 'TND';

  /// Area unit shown in the UI (the database field is `areaSqm`).
  static const String areaUnit = 'm²';

  /// Default map center: Tunis.
  static const double mapCenterLatitude = 36.8065;
  static const double mapCenterLongitude = 10.1815;
  static const double mapDefaultZoom = 11;

  /// Whole country, for the location picker when no city is known yet.
  static const double mapCountryLatitude = 33.9;
  static const double mapCountryLongitude = 9.6;
  static const double mapCountryZoom = 6;
}

/// Formats a price the same way in every screen, e.g. "TND 450,000".
String formatPrice(num amount, {String? currency}) {
  final formatter = NumberFormat('#,##0', 'en');
  return '${currency ?? AppConfig.currency} ${formatter.format(amount)}';
}

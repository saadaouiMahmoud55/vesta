/// Spacing scale in dp. A screen uses these names, not numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radius, measured on the mockups (VST-66 and VST-67).
class AppRadius {
  AppRadius._();

  /// Cards and chat bubbles.
  static const double card = 16;

  /// List rows.
  static const double row = 14;

  /// Thumbnails and small badges.
  static const double thumb = 12;

  /// Text fields.
  static const double field = 10;

  /// Buttons, chips and the search bar are pills.
  static const double pill = 999;
}

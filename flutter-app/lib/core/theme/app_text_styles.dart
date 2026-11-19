import 'package:flutter/material.dart';

/// Text sizes measured on the mockups (VST-66 and VST-67). Font: the system
/// font (Roboto for Latin, Noto Sans Arabic for Arabic), so no family is set.
/// No color here: the widget adds a color from `AppColors`.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle body = TextStyle(fontSize: 15);
  static const TextStyle bodySmall = TextStyle(fontSize: 14);
  static const TextStyle caption = TextStyle(fontSize: 13);
  static const TextStyle small = TextStyle(fontSize: 12);
  static const TextStyle tiny = TextStyle(fontSize: 11);
}

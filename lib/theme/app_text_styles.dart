import 'package:flutter/material.dart';

/// Centralized type scale for BLOOM. Uses the platform default font family
/// (kept dependency-free / offline-safe) with deliberate weight & spacing.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Roboto';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.3,
  );

  static const TextStyle numericLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

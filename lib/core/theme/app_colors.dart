import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF4B2E83);
  static const primaryDark = Color(0xFF34205F);
  static const primaryLight = Color(0xFFF0EBF8);
  static const primaryFaint = Color(0xFFF7F4FB);

  static const secondary = Color(0xFF204F78);
  static const secondaryLight = Color(0xFFE8F1F8);

  static const white = Color(0xFFFFFFFF);

  // Soft lavender canvas. Cards stay pure white so hierarchy is clear.
  static const background = Color(0xFFF5F1FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF5F1FA);
  static const surfaceMuted = Color(0xFFEDE7F4);

  static const textPrimary = Color(0xFF182230);
  static const textSecondary = Color(0xFF4B5565);
  static const textMuted = Color(0xFF6B7280);

  static const border = Color(0xFFE0D8EB);
  static const borderStrong = Color(0xFFCDBFDB);

  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const error = Color(0xFFB42318);
  static const info = Color(0xFF0369A1);
}

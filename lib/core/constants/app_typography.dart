import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get _baseFont => GoogleFonts.poppins();

  // Display
  static TextStyle displayLarge = _baseFont.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = _baseFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static TextStyle displaySmall = _baseFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Headline
  static TextStyle headlineLarge = _baseFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineMedium = _baseFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineSmall = _baseFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title
  static TextStyle titleLarge = _baseFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle titleMedium = _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle titleSmall = _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Body
  static TextStyle bodyLarge = _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle bodyMedium = _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle bodySmall = _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // Label
  static TextStyle labelLarge = _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium = _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelSmall = _baseFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Score display
  static TextStyle scoreDisplay = _baseFont.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static TextStyle scoreMedium = _baseFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
}

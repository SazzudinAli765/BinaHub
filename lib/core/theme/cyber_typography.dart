import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_colors.dart';

/// Cyber Precision Typography Hierarchy
/// Fuses Inter (UI & Navigation) with JetBrains Mono (Temporal & Hardware Telemetry).
class CyberTypography {
  // Display & Headlines (Inter)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: CyberColors.textPrimary,
    letterSpacing: -0.02,
    height: 1.2,
  );

  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: CyberColors.textPrimary,
    letterSpacing: -0.02,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CyberColors.textPrimary,
    letterSpacing: -0.01,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CyberColors.textPrimary,
    height: 1.3,
  );

  // Body Text (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: CyberColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: CyberColors.textSecondary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: CyberColors.textMuted,
    height: 1.4,
  );

  // Action & Button Labels (Inter)
  static TextStyle buttonAction = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.04,
    color: CyberColors.bgPureBlack,
  );

  static TextStyle buttonGhost = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02,
    color: CyberColors.textPrimary,
  );

  // Telemetry & Numeric Readouts (JetBrains Mono)
  static TextStyle telemetryTimecodeLarge = GoogleFonts.jetbrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CyberColors.textPrimary,
    letterSpacing: 0.04,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle telemetryTimecode = GoogleFonts.jetbrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: CyberColors.textSecondary,
    letterSpacing: 0.04,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle telemetryBadge = GoogleFonts.jetbrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: CyberColors.primaryCyan,
    letterSpacing: 0.08,
  );

  static TextStyle telemetryVioletBadge = GoogleFonts.jetbrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: CyberColors.secondaryViolet,
    letterSpacing: 0.08,
  );

  static TextStyle telemetryMicro = GoogleFonts.jetbrainsMono(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: CyberColors.textMuted,
    letterSpacing: 0.04,
  );
}

import 'package:flutter/material.dart';

/// Cyber Precision Color Palette
/// Strict functional strata designed for zero-emissive OLED mobile displays.
class CyberColors {
  // Canvas & Substrates
  static const Color bgPureBlack = Color(0xFF000000);
  static const Color surfaceCarbon = Color(0xFF111115);
  static const Color surfaceCarbonRaised = Color(0xFF16161C);
  static const Color surfaceElevated = Color(0xFF192029);
  static const Color surfaceContainerLow = Color(0xFF151C25);
  static const Color surfaceContainerHigh = Color(0xFF232A34);

  // Technical Hairlines & Borders
  static const Color borderStructural = Color(0xFF22222A);
  static const Color borderSubtle = Color(0xFF2E353F);
  static const Color borderActive = Color(0x6600F0FF); // rgba(0, 240, 255, 0.4)
  static const Color borderViolet = Color(0x4D8B5CF6); // rgba(139, 92, 246, 0.3)

  // Chromatic Signal Accents
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color primaryPressed = Color(0xFF00D2E0);
  static const Color primaryContainer = Color(0xFF00363A);
  
  static const Color secondaryViolet = Color(0xFF8B5CF6);
  static const Color neuralVioletLight = Color(0xFFA855F7);
  static const Color secondaryContainer = Color(0xFF3C0091);
  
  static const Color signalGreen = Color(0xFF22C55E);
  static const Color signalGreenLight = Color(0xFF34D399);
  
  static const Color thermalRed = Color(0xFFEF4444);
  static const Color thermalRedLight = Color(0xFFF43F5E);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Content & Textures
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textCyan = Color(0xFF00F0FF);

  // Scrubber & Progress
  static const Color scrubberRail = Color(0xFF22222A);
  static const Color scrubberBuffered = Color(0x40FFFFFF);
  static const Color scrubberActive = Color(0xFF00F0FF);

  // Glow Halo
  static const BoxShadow cyanGlow = BoxShadow(
    color: Color(0x5900F0FF),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow violetGlow = BoxShadow(
    color: Color(0x4D8B5CF6),
    blurRadius: 8,
    spreadRadius: 0,
  );
}

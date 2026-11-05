import 'package:flutter/material.dart';

/// Cyber Precision Geometry, Radii & Spacing Specifications
class CyberShapes {
  // Radii
  static const double radiusSharp = 0.0;
  static const double radiusMicro = 4.0;
  static const double radiusPanel = 8.0;
  static const double radiusPill = 999.0;

  // Border Radii
  static const BorderRadius roundedSharp = BorderRadius.zero;
  static const BorderRadius roundedMicro = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius roundedPanel = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(999.0));

  // Spacing
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;

  // Common Paddings
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets paddingCard = EdgeInsets.all(12.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0);
}

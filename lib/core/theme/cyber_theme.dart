import 'package:flutter/material.dart';
import 'cyber_colors.dart';
import 'cyber_typography.dart';
import 'cyber_shapes.dart';

class CyberTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberColors.bgPureBlack,
      primaryColor: CyberColors.primaryCyan,
      canvasColor: CyberColors.bgPureBlack,
      cardColor: CyberColors.surfaceCarbon,
      dividerColor: CyberColors.borderStructural,

      colorScheme: const ColorScheme.dark(
        primary: CyberColors.primaryCyan,
        onPrimary: CyberColors.bgPureBlack,
        secondary: CyberColors.secondaryViolet,
        onSecondary: CyberColors.textPrimary,
        surface: CyberColors.surfaceCarbon,
        onSurface: CyberColors.textPrimary,
        error: CyberColors.thermalRed,
        onError: CyberColors.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: CyberColors.bgPureBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CyberTypography.headlineMedium,
        iconTheme: const IconThemeData(color: CyberColors.textPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: CyberColors.textSecondary, size: 22),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CyberColors.surfaceCarbon,
        selectedItemColor: CyberColors.primaryCyan,
        unselectedItemColor: CyberColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      cardTheme: CardTheme(
        color: CyberColors.surfaceCarbon,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CyberShapes.roundedMicro,
          side: const BorderSide(color: CyberColors.borderStructural, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: CyberColors.surfaceCarbonRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CyberShapes.roundedPanel,
          side: const BorderSide(color: CyberColors.borderStructural, width: 1),
        ),
        titleTextStyle: CyberTypography.headlineMedium,
        contentTextStyle: CyberTypography.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CyberColors.surfaceCarbonRaised,
        modalBackgroundColor: CyberColors.surfaceCarbonRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(CyberShapes.radiusPanel)),
          side: BorderSide(color: CyberColors.borderStructural, width: 1),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: CyberColors.primaryCyan,
        inactiveTrackColor: CyberColors.scrubberRail,
        thumbColor: CyberColors.primaryCyan,
        overlayColor: CyberColors.borderActive,
        trackHeight: 2.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return CyberColors.primaryCyan;
          }
          return CyberColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return CyberColors.primaryContainer;
          }
          return CyberColors.surfaceElevated;
        }),
        trackOutlineColor: MaterialStateProperty.all(CyberColors.borderStructural),
      ),
    );
  }
}

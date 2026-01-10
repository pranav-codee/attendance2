import 'package:flutter/material.dart';

class AppTheme {
  // Enhanced color palette for professional look
  static const Color primaryColor = Color(0xFF007AFF); // Blue accent color
  static const Color primaryColorLight = Color(0xFF4DA6FF); // Lighter blue
  static const Color primaryColorDark = Color(0xFF0056CC); // Darker blue

  static const Color backgroundColor =
      Color(0xFF000000); // Pure black background
  static const Color surfaceColor =
      Color(0xFF1C1C1E); // Dark gray for cards/surfaces
  static const Color surfaceColorElevated =
      Color(0xFF2C2C2E); // Slightly lighter for elevated surfaces
  static const Color surfaceColorHighlight =
      Color(0xFF3A3A3C); // For hover/pressed states

  static const Color textPrimaryColor = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryColor = Color(0xFF8E8E93); // Gray text
  static const Color textTertiaryColor = Color(0xFF636366); // Darker gray text

  static const Color redColor =
      Color(0xFFFF3B30); // Red for destructive actions
  static const Color greenColor =
      Color(0xFF30D158); // Green for success/positive
  static const Color orangeColor =
      Color(0xFFFF9500); // Orange for warnings/ongoing
  static const Color yellowColor = Color(0xFFFFD60A); // Yellow for attention

  // Gradient colors for premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryColorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [greenColor, Color(0xFF32D74B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          side: const BorderSide(color: surfaceColorHighlight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(
          color: textSecondaryColor,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.6,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textTertiaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.3,
        ),
        labelMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.3,
        ),
        labelSmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.2,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: surfaceColorHighlight,
        thumbColor: textPrimaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textPrimaryColor;
          }
          return textSecondaryColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return surfaceColorHighlight;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColorHighlight,
      ),
    );
  }

  // Custom box shadows for elevated elements
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // Custom border radius values
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mediumRadius =
      BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius extraLargeRadius =
      BorderRadius.all(Radius.circular(20));

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

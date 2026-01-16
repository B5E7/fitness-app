import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
/// 
/// Defines the visual styling for the entire application
/// using a modern, premium dark theme with vibrant accents.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============== Color Palette ==============
  
  // Primary colors - Vibrant orange/coral gradient
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F65);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  // Secondary colors - Electric blue
  static const Color secondaryColor = Color(0xFF00D4FF);
  static const Color secondaryLight = Color(0xFF5DDFFF);
  static const Color secondaryDark = Color(0xFF00A8CC);
  
  // Accent colors
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentPurple = Color(0xFFBB86FC);
  static const Color accentYellow = Color(0xFFFFD600);
  
  // Background colors (dark theme)
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF242424);
  static const Color elevatedDark = Color(0xFF2D2D2D);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  
  // Status colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  
  // Muscle group colors
  static const Map<String, Color> muscleGroupColors = {
    'Chest': Color(0xFFFF6B35),
    'Back': Color(0xFF00D4FF),
    'Legs': Color(0xFF00E676),
    'Shoulders': Color(0xFFBB86FC),
    'Arms': Color(0xFFFFD600),
    'Core': Color(0xFFFF4081),
  };

  // ============== Gradients ==============
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardDark, Color(0xFF1E1E28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============== Text Styles ==============
  
  static TextStyle get headingLarge => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingMedium => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static TextStyle get headingSmall => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textTertiary,
  );
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle get numberLarge => GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle get numberMedium => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // ============== Box Decorations ==============
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.05),
      width: 1,
    ),
  );
  
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: cardDark.withOpacity(0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  static BoxDecoration get elevatedDecoration => BoxDecoration(
    color: elevatedDark,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ============== Theme Data ==============
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceDark,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge,
        ),
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: elevatedDark,
        selectedColor: primaryColor,
        disabledColor: surfaceDark,
        labelStyle: bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        titleLarge: headingSmall,
        titleMedium: labelLarge,
        titleSmall: bodyMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: bodyMedium,
        labelSmall: bodySmall,
      ),
    );
  }
}

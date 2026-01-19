// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark }

class AppTheme {
  static AppThemeMode currentMode = AppThemeMode.dark;
  
  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF6A1B9A);
  static const Color darkSecondaryColor = Color(0xFFFF6F00);
  static const Color darkAccentColor = Color(0xFF7B1FA2);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  
  // Light theme colors
  static const Color lightPrimaryColor = Color(0xFF6A1B9A);
  static const Color lightSecondaryColor = Color(0xFFFF9100);
  static const Color lightAccentColor = Color(0xFF651FFF);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightCardGrey = Color(0xFFF9F9F9);

  // Getters for dynamic colors
  static Color get primaryColor => isDarkMode ? darkPrimaryColor : lightPrimaryColor;
  static Color get secondaryColor => isDarkMode ? darkSecondaryColor : lightSecondaryColor;
  static Color get accentColor => isDarkMode ? darkAccentColor : lightAccentColor;
  static Color get backgroundColor => isDarkMode ? darkBackgroundColor : lightBackgroundColor;
  static Color get surfaceColor => isDarkMode ? darkSurfaceColor : lightSurfaceColor;
  
  // Text colors
  static Color get textColor => isDarkMode ? Colors.white : Colors.black87;
  static Color get hintTextColor => isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  
  // For backward compatibility
  static Color get lightColor => surfaceColor;
  static Color get darkColor => isDarkMode ? Colors.white : Colors.black87;
  
  // Change from private (_isDarkMode) to public (isDarkMode)
  static bool get isDarkMode => currentMode == AppThemeMode.dark;

  static void toggleTheme() {
    currentMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
  }

  // Glass morphism gradients - UPDATE to use isDarkMode instead of _isDarkMode
  static LinearGradient get glassBackgroundGradient {
    return LinearGradient(
      colors: isDarkMode
          ? [
              backgroundColor.withOpacity(0.95),
              backgroundColor.withOpacity(0.98),
              
            ]
          : [
              backgroundColor.withOpacity(0.92),
              backgroundColor.withOpacity(0.96),
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient get primaryGradient {
    return LinearGradient(
      colors: isDarkMode
          ? [
              primaryColor.withOpacity(0.6),
              secondaryColor.withOpacity(0.6),
            ]
          : [
              primaryColor.withOpacity(0.4),
              secondaryColor.withOpacity(0.4),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cardGradient {
    return LinearGradient(
      colors: isDarkMode
          ? [

               Colors.white.withOpacity(0.18), // Increased from 0.12
            Colors.white.withOpacity(0.08),
            ]
          : [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Glass effect box decoration
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Theme data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode 
            ? primaryColor.withOpacity(0.15)
            : primaryColor.withOpacity(0.08),
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: secondaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: isDarkMode 
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFFF6F2F9),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode 
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: hintTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      textTheme: const TextTheme().copyWith(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
      ),
    );
  }
}
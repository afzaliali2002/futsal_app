// lib/core/constants/dark_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart' as colors;

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Standard Material dark background
    cardColor: const Color(0xFF1E1E1E),     // Slightly lighter for cards
    canvasColor: const Color(0xFF1E1E1E),

    colorScheme: const ColorScheme.dark(
      primary: colors.AppColors.primaryGreen,     // Primary Green #4CAF50
      secondary: colors.AppColors.secondaryBlue,  // Secondary Blue #2196F3
      surface: Color(0xFF1E1E1E),
      error: colors.AppColors.accentRed,          // Accent Red #F44336

      onPrimary: Colors.white, // Text on Green
      onSecondary: Colors.white, // Text on Blue
      onSurface: Colors.white,     // Text on Cards
      onError: Colors.white,
    ),

    fontFamily: 'BYekan',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE0E0E0), // Slightly off-white for body text
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFBDBDBD), // Lighter grey for less important text
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.AppColors.primaryGreen, // Primary Green
        foregroundColor: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: colors.AppColors.primaryGreen,
          width: 2,
        ),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.white70),
    ),

    iconTheme: const IconThemeData(
      color: colors.AppColors.secondaryBlue, // Icons stand out with the secondary color
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212), // Matching scaffold background
      foregroundColor: Colors.white,      // Ensuring text and icons are white
      elevation: 0,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.AppColors.secondaryBlue, // Secondary Blue
      ),
    ),
    
    dividerColor: const Color(0xFF424242),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

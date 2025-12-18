// lib/core/constants/light_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart' as colors;

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: colors.AppColors.backgroundWhite, 
    cardColor: colors.AppColors.backgroundWhite, 
    canvasColor: colors.AppColors.backgroundWhite,

    colorScheme: const ColorScheme.light(
      primary: colors.AppColors.primaryGreen,
      secondary: colors.AppColors.secondaryBlue,
      surface: colors.AppColors.backgroundWhite,
      error: colors.AppColors.accentRed,
      
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: colors.AppColors.textIconsDark,
      onError: Colors.white,
    ),

    fontFamily: 'BYekan',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colors.AppColors.textIconsDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.AppColors.textIconsDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.AppColors.textIconsDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.AppColors.textIconsDark,
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
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: colors.AppColors.primaryGreen,
          width: 2,
        ),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: colors.AppColors.textIconsDark),
    ),

    iconTheme: const IconThemeData(
      color: colors.AppColors.secondaryBlue, 
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: colors.AppColors.backgroundWhite, 
      foregroundColor: colors.AppColors.textIconsDark, 
      elevation: 0,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.AppColors.secondaryBlue, // Secondary Blue
      ),
    ),
    
    dividerColor: const Color(0xFFEEEEEE),

    cardTheme: CardThemeData(
      color: colors.AppColors.backgroundWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

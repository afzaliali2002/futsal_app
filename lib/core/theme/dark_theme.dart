// lib/core/constants/dark_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart' as colors;

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.AppColors.darkBackground,
    cardColor: colors.AppColors.darkCard,
    canvasColor: colors.AppColors.darkSurface,

    // ✅ Material 3: Use colorScheme instead of primaryColor/accentColor
    colorScheme: ColorScheme.dark(
      primary: colors.AppColors.accentOrange,
      secondary: colors.AppColors.accentOrange,
      background: colors.AppColors.darkBackground,
      surface: colors.AppColors.darkCard,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: colors.AppColors.darkTextPrimary,
      onBackground: colors.AppColors.darkTextPrimary,
      outline: colors.AppColors.borderGray,
      error: Colors.red,
    ),

    fontFamily: 'BYekan',

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colors.AppColors.darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.AppColors.darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.AppColors.darkTextSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.AppColors.darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.AppColors.darkTextPrimary,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.AppColors.accentOrange,
        foregroundColor: Colors.black, // text/icon color on button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.AppColors.borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.AppColors.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.AppColors.accentOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: TextStyle(color: colors.AppColors.darkTextSecondary),
      labelStyle: TextStyle(color: colors.AppColors.darkTextSecondary),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: colors.AppColors.darkTextPrimary,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: colors.AppColors.darkBackground,
      titleTextStyle: TextStyle(
        color: colors.AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: colors.AppColors.darkTextPrimary,
      ),
    ),

    // Text Button (for "Forgot password?", links, etc.)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.AppColors.accentOrange,
      ),
    ),

    // Divider & borders
    dividerColor: colors.AppColors.borderGray,

    // ✅ Fixed: CardTheme → CardThemeData
    cardTheme: CardThemeData(
      color: colors.AppColors.darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
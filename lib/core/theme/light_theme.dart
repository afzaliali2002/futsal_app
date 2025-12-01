// lib/core/constants/light_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart' as colors;
ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: colors.AppColors.lightBackground,
    cardColor: colors.AppColors.lightCard,
    canvasColor: colors.AppColors.lightSurface,

    // ✅ Replace primaryColor & accentColor with colorScheme
    colorScheme: ColorScheme.light(
      primary: colors.AppColors.lightAccentOrange,
      secondary: colors.AppColors.lightAccentOrange,
      background: colors.AppColors.lightBackground,
      surface: colors.AppColors.lightCard,
      onPrimary: Colors.black,
      onSurface: colors.AppColors.lightTextPrimary,
      onBackground: colors.AppColors.lightTextPrimary,
      outline: colors.AppColors.lightBorderGray, // for borders
    ),

    fontFamily: 'BYekan',

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colors.AppColors.lightTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.AppColors.lightTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.AppColors.lightTextSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.AppColors.lightTextSecondary,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.AppColors.lightAccentOrange,
        foregroundColor: Colors.black, // text/icon color on button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.AppColors.lightBorderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.AppColors.lightBorderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.AppColors.lightAccentOrange,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(color: colors.AppColors.lightTextSecondary),
      labelStyle: TextStyle(color: colors.AppColors.lightTextSecondary),
    ),

    iconTheme: IconThemeData(
      color: colors.AppColors.lightTextPrimary,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: colors.AppColors.lightBackground,
      titleTextStyle: TextStyle(
        color: colors.AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: colors.AppColors.lightTextPrimary,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.AppColors.lightAccentOrange,
      ),
    ),

    dividerColor: colors.AppColors.lightBorderGray,

    // ✅ Fixed: CardTheme → CardThemeData
    cardTheme: CardThemeData(
      color: colors.AppColors.lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textIconsDark = Color(0xFF212121);
  static const Color accentRed = Color(0xFFF44336);
  
  // Legacy support or new harmonized names (optional, based on your previous usage)
  // 🔹 Dark Theme Colors
  static const Color darkBackground = Color(0xFF212121); // Using dark text color as background for dark mode? Or closer to Material Dark
  static const Color darkCard = Color(0xFF303030);
  static const Color darkSurface = Color(0xFF424242);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // You can alias your main colors to standard names if you prefer using AppColors.primary
  static const Color primary = primaryGreen;
  static const Color secondary = secondaryBlue;
  static const Color error = accentRed;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brand,
        secondary: AppColors.brandSoft,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.warning,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: AppColors.surfaceAlt, elevation: 0),
      dividerColor: AppColors.outline,
    );
  }
}

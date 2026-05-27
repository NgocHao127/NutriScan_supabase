import 'package:flutter/material.dart';

class AppColors {
  // Xanh lá chủ đạo
  static const Color primary = Color(0xFF3B6D11);
  static const Color primaryDark = Color(0xFF27500A);
  static const Color primaryLight = Color(0xFFEAF3DE);
  static const Color primaryMid = Color(0xFF639922);
  static const Color primaryAccent = Color(0xFF97C459);
  static const Color onPrimary = Color(0xFFC0DD97);

  // nền
  static const Color bgPage = Color(0xFFF5F7F2);
  static const Color bgCard = Color(0xFFFFFFFF);

  // Chữ
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textHint = Color(0xFFBBBBBB);

  // Macro
  static const Color protein = Color(0xFF7F77DD);
  static const Color carb = Color(0xFFEF9F27);
  static const Color fat = Color(0xFFD85A30);

  // Semantic
  static const Color danger = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFBA7517);

  // FORM / INPUT:
  static const Color inputBorder = Color(0xFFC8DAB8);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color linkText = Color(0xFF3B6D11);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bgPage,
    ),

    scaffoldBackgroundColor: AppColors.bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: AppColors.carb,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.textPrimary),
      bodySmall: TextStyle(fontSize: 11, color: AppColors.textSecondary),
      labelSmall: TextStyle(fontSize: 10, color: AppColors.textHint),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

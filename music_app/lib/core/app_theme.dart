import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Afacad',
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 57),
        displayMedium: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 45),
        displaySmall: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 36),
        headlineLarge: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 32),
        headlineMedium: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 28),
        headlineSmall: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 24),
        titleLarge: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 22),
        titleMedium: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 16),
        titleSmall: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 14),
        bodyLarge: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 14),
        bodySmall: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 12),
        labelLarge: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 14),
        labelMedium: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 12),
        labelSmall: TextStyle(
            fontFamily: 'Afacad', color: AppColors.textPrimary, fontSize: 11),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.backgroundSecondary,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.only(right: 0, left: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.cardLight,
      dividerColor: Colors.grey[300],
      fontFamily: GoogleFonts.poppins().fontFamily,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary, // Legacy mapping
        surface: AppColors.cardLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textMainLight,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
        titleTextStyle: TextStyle(
          color: AppColors.textMainLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: AppColors.textMainLight, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: AppColors.textMainLight, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.textMainLight, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSubLight, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.cardDark,
      dividerColor: Colors.grey[800],
      fontFamily: GoogleFonts.poppins().fontFamily,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryDark,
        surface: AppColors.cardDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textMainDark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textMainDark),
        titleTextStyle: TextStyle(
          color: AppColors.textMainDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: AppColors.textMainDark, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: AppColors.textMainDark, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.textMainDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSubDark, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
         hintStyle: TextStyle(color: Colors.grey[600]), 
      ),
    );
  }
}

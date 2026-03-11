import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark background palette
  static const bg = Color(0xFF0A0E1A);
  static const bgCard = Color(0xFF111827);
  static const bgSurface = Color(0xFF1A2235);
  static const bgElevated = Color(0xFF1F2D42);

  // Accent colors
  static const accentGreen = Color(0xFF00FFB2);
  static const accentBlue = Color(0xFF4D9FFF);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentOrange = Color(0xFFFF7A00);
  static const accentRed = Color(0xFFFF4757);

  // Text
  static const textPrimary = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8B9DC3);
  static const textMuted = Color(0xFF4A5568);

  // Difficulty colors
  static const diffEasy = Color(0xFF00C896);
  static const diffMedium = Color(0xFFFFB800);
  static const diffHard = Color(0xFFFF4757);

  // Border
  static const border = Color(0xFF1E2D45);
  static const borderActive = Color(0xFF2D4A6E);

  // Gradients
  static const gradientGreen = [Color(0xFF00FFB2), Color(0xFF00C896)];
  static const gradientBlue = [Color(0xFF4D9FFF), Color(0xFF1A65CC)];
  static const gradientCard = [Color(0xFF111827), Color(0xFF1A2235)];
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentGreen,
        secondary: AppColors.accentBlue,
        surface: AppColors.bgCard,
        error: AppColors.accentRed,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        indicatorColor: AppColors.accentGreen.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentGreen, size: 22);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGreen,
            );
          }
          return GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}

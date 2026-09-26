import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Shared design tokens.
class AppRadius {
  AppRadius._();
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Theme-aware surface palette used by [_buildTheme].
class _SurfacePalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceHighlight;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onSurfaceMuted;
  final Color outline;
  final Color outlineStrong;
  final Color shadow;

  const _SurfacePalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceHighlight,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.outline,
    required this.outlineStrong,
    required this.shadow,
  });
}

class AppTheme {
  AppTheme._();

  static const _darkSurfaces = _SurfacePalette(
    background: Color(0xFF0A0C10),
    surface: Color(0xFF13161F),
    surfaceVariant: Color(0xFF1C2030),
    surfaceHighlight: Color(0xFF252A3D),
    onSurface: Color(0xFFFAFAF9),
    onSurfaceVariant: Color(0xFF9CA3AF),
    onSurfaceMuted: Color(0xFF6B7280),
    outline: Color(0xFF2A2F3D),
    outlineStrong: Color(0xFF3E4559),
    shadow: Colors.black,
  );

  static const _lightSurfaces = _SurfacePalette(
    background: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F2EF),
    surfaceHighlight: Color(0xFFEAE9E5),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFF6B7280),
    onSurfaceMuted: Color(0xFF9CA3AF),
    outline: Color(0xFFE5E5E0),
    outlineStrong: Color(0xFFD4D4CF),
    shadow: Colors.black,
  );

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, _darkSurfaces);

  static ThemeData get lightTheme => _buildTheme(Brightness.light, _lightSurfaces);

  static ThemeData _buildTheme(Brightness brightness, _SurfacePalette surface) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      isDark ? Typography.material2021().white : Typography.material2021().black,
    );

    final displayFont = GoogleFonts.playfairDisplay;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            secondary: AppColors.secondary,
            onSecondary: AppColors.white,
            tertiary: AppColors.tertiary,
            onTertiary: AppColors.white,
            surface: surface.surface,
            surfaceContainerHighest: surface.surfaceVariant,
            onSurface: surface.onSurface,
            onSurfaceVariant: surface.onSurfaceVariant,
            error: AppColors.error,
            onError: AppColors.white,
            outline: surface.outline,
            shadow: surface.shadow,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            secondary: AppColors.secondary,
            onSecondary: AppColors.white,
            tertiary: AppColors.tertiary,
            onTertiary: AppColors.white,
            surface: surface.surface,
            surfaceContainerHighest: surface.surfaceVariant,
            onSurface: surface.onSurface,
            onSurfaceVariant: surface.onSurfaceVariant,
            error: AppColors.error,
            onError: AppColors.white,
            outline: surface.outline,
            shadow: surface.shadow,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surface.background,
      primaryColor: AppColors.primary,
      colorScheme: colorScheme,
      textTheme: baseTextTheme.copyWith(
        displayLarge: displayFont(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: surface.onSurface,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: displayFont(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: surface.onSurface,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: displayFont(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: surface.onSurface,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: surface.onSurface,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: surface.onSurface,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: surface.onSurface,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: surface.onSurface,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: surface.onSurface,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: surface.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: surface.onSurface,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: surface.onSurfaceVariant,
          height: 1.5,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: surface.onSurfaceMuted,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        iconTheme: IconThemeData(color: surface.onSurface, size: 22),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: surface.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: surface.surfaceHighlight,
          disabledForegroundColor: surface.onSurfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: surface.outlineStrong, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.surface,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: surface.onSurfaceMuted,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: surface.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: surface.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: surface.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: surface.outline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface.surfaceVariant,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: surface.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: isDark ? surface.background : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        elevation: 0,
      ),
    );
  }
}

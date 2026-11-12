import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Industrial Precision design system — UdhaM
/// Reference: stitch_udham_industrial_expense_manager/industrial_precision/DESIGN.md
class UdhamColors {
  const UdhamColors._();

  // Core palette
  static const surface = Color(0xFFFBF9F2);
  static const surfaceDim = Color(0xFFDBDAD3);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F4ED);
  static const surfaceContainer = Color(0xFFEFEEE7);
  static const surfaceContainerHigh = Color(0xFFE9E8E1);
  static const surfaceContainerHighest = Color(0xFFE3E3DC);
  static const onSurface = Color(0xFF1B1C18);
  static const onSurfaceVariant = Color(0xFF444845);
  static const inverseSurface = Color(0xFF30312C);
  static const inverseOnSurface = Color(0xFFF2F1EA);
  static const outline = Color(0xFF747875);
  static const outlineVariant = Color(0xFFC4C7C3);

  // Primary
  static const primary = Color(0xFF0A0D0B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF202321);
  static const onPrimaryContainer = Color(0xFF888A87);
  static const inversePrimary = Color(0xFFC5C7C4);
  static const primaryFixed = Color(0xFFE1E3DF);
  static const primaryFixedDim = Color(0xFFC5C7C4);
  static const onPrimaryFixed = Color(0xFF191C1A);
  static const onPrimaryFixedVariant = Color(0xFF454745);

  // Secondary (Signal Orange)
  static const secondary = Color(0xFF904D00);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFF9F49);
  static const onSecondaryContainer = Color(0xFF6E3A00);
  static const secondaryFixed = Color(0xFFFFDCC3);
  static const secondaryFixedDim = Color(0xFFFFB77D);
  static const onSecondaryFixed = Color(0xFF2F1500);
  static const onSecondaryFixedVariant = Color(0xFF6E3900);

  // Tertiary (deep dark green)
  static const tertiary = Color(0xFF050F08);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF1A251D);
  static const onTertiaryContainer = Color(0xFF818D82);
  static const tertiaryFixed = Color(0xFFD9E6D9);
  static const tertiaryFixedDim = Color(0xFFBDCABE);
  static const onTertiaryFixed = Color(0xFF141E16);
  static const onTertiaryFixedVariant = Color(0xFF3E4940);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

/// Typography using Bricolage Grotesque + Inter + Space Mono
class UdhamTypography {
  const UdhamTypography._();

  static TextTheme textTheme() {
    return TextTheme(
      // display — Bricolage Grotesque
      displayLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 48,
        height: 52 / 48,
        color: UdhamColors.onSurface,
      ),
      displayMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 36,
        height: 40 / 36,
        color: UdhamColors.onSurface,
      ),
      displaySmall: GoogleFonts.bricolageGrotesque(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 26,
        height: 30 / 26,
        color: UdhamColors.onSurface,
      ),

      // headline — Bricolage Grotesque
      headlineLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 32,
        height: 36 / 32,
        color: UdhamColors.onSurface,
      ),
      headlineMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 22,
        height: 26 / 22,
        color: UdhamColors.onSurface,
      ),
      headlineSmall: GoogleFonts.bricolageGrotesque(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 22 / 18,
        color: UdhamColors.onSurface,
      ),

      // title — Bricolage Grotesque
      titleLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 16,
        height: 22 / 16,
        color: UdhamColors.onSurface,
      ),
      titleMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 20 / 14,
        color: UdhamColors.onSurface,
      ),
      titleSmall: GoogleFonts.bricolageGrotesque(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 16 / 12,
        color: UdhamColors.onSurface,
      ),

      // body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.01 * 16,
        height: 24 / 16,
        color: UdhamColors.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 20 / 14,
        color: UdhamColors.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 16 / 12,
        color: UdhamColors.onSurfaceVariant,
      ),

      // label — Space Mono for technical labels
      labelLarge: GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 11,
        height: 14 / 11,
        color: UdhamColors.onSurfaceVariant,
      ),
      labelMedium: GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 10,
        height: 12 / 10,
        color: UdhamColors.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.05 * 9,
        height: 12 / 9,
        color: UdhamColors.onSurfaceVariant,
      ),
    );
  }

  /// Space Mono for monetary amounts — always tabular
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ColorScheme _colorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      surface: UdhamColors.surface,
      onSurface: UdhamColors.onSurface,
      surfaceContainerLowest: UdhamColors.surfaceContainerLowest,
      surfaceContainerLow: UdhamColors.surfaceContainerLow,
      surfaceContainer: UdhamColors.surfaceContainer,
      surfaceContainerHigh: UdhamColors.surfaceContainerHigh,
      surfaceContainerHighest: UdhamColors.surfaceContainerHighest,
      inverseSurface: UdhamColors.inverseSurface,
      onInverseSurface: UdhamColors.inverseOnSurface,
      surfaceTint: UdhamColors.onSurfaceVariant,
      onSurfaceVariant: UdhamColors.onSurfaceVariant,
      outline: UdhamColors.outline,
      outlineVariant: UdhamColors.outlineVariant,
      primary: UdhamColors.primary,
      onPrimary: UdhamColors.onPrimary,
      primaryContainer: UdhamColors.primaryContainer,
      onPrimaryContainer: UdhamColors.onPrimaryContainer,
      inversePrimary: UdhamColors.inversePrimary,
      secondary: UdhamColors.secondary,
      onSecondary: UdhamColors.onSecondary,
      secondaryContainer: UdhamColors.secondaryContainer,
      onSecondaryContainer: UdhamColors.onSecondaryContainer,
      tertiary: UdhamColors.tertiary,
      onTertiary: UdhamColors.onTertiary,
      tertiaryContainer: UdhamColors.tertiaryContainer,
      onTertiaryContainer: UdhamColors.onTertiaryContainer,
      error: UdhamColors.error,
      onError: UdhamColors.onError,
      errorContainer: UdhamColors.errorContainer,
      onErrorContainer: UdhamColors.onErrorContainer,
    );
  }

  static ThemeData light() {
    final scheme = _colorScheme();
    final text = UdhamTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: UdhamColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: UdhamColors.surface,
        foregroundColor: UdhamColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: UdhamColors.onSurface,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: UdhamColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: UdhamColors.outlineVariant, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: UdhamColors.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UdhamColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: UdhamColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: UdhamColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide:
              const BorderSide(color: UdhamColors.secondary, width: 1.5),
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 10,
          color: UdhamColors.onSurfaceVariant,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: UdhamColors.inverseSurface,
        contentTextStyle:
            GoogleFonts.inter(color: UdhamColors.inverseOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: UdhamColors.primaryContainer,
        selectedItemColor: UdhamColors.secondaryContainer,
        unselectedItemColor: UdhamColors.onPrimaryContainer,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: UdhamColors.secondary,
          foregroundColor: UdhamColors.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: UdhamColors.onSurface,
          side: const BorderSide(color: UdhamColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() => light(); // single theme, light only per design
}

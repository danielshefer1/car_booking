import 'package:flutter/material.dart';

class AppColors {
  static const clay = Color(0xFFCC785C);
  static const clayDark = Color(0xFFB0613F);
  static const cream = Color(0xFFFAF9F5);
  static const creamSoft = Color(0xFFF5F4EE);
  static const sage = Color(0xFF8B8278);
  static const ink = Color(0xFF1F1E1D);
  static const inkSoft = Color(0xFF4A4641);
  static const line = Color(0xFFE3DED3);
}

const _serif = 'serif';

ThemeData buildClaudeTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.clay,
    onPrimary: AppColors.cream,
    primaryContainer: const Color(0xFFF2D9CE),
    onPrimaryContainer: AppColors.clayDark,
    secondary: AppColors.sage,
    onSecondary: AppColors.cream,
    secondaryContainer: const Color(0xFFDCD7CD),
    onSecondaryContainer: AppColors.ink,
    tertiary: const Color(0xFF6B6B62),
    onTertiary: AppColors.cream,
    tertiaryContainer: AppColors.creamSoft,
    onTertiaryContainer: AppColors.ink,
    error: const Color(0xFFB3261E),
    onError: AppColors.cream,
    errorContainer: const Color(0xFFF4DCDA),
    onErrorContainer: const Color(0xFF5B1210),
    surface: AppColors.cream,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: AppColors.cream,
    surfaceContainer: AppColors.creamSoft,
    surfaceContainerHigh: const Color(0xFFEEECDF),
    surfaceContainerHighest: const Color(0xFFE8E5D5),
    outline: AppColors.line,
    outlineVariant: const Color(0xFFEDE8DC),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.cream,
    inversePrimary: const Color(0xFFE8B6A3),
  );

  const radius = BorderRadius.all(Radius.circular(12));
  const pillRadius = BorderRadius.all(Radius.circular(999));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: NoSplash.splashFactory,
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.25),
      headlineLarge: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.25),
      headlineMedium: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink),
      headlineSmall: TextStyle(fontFamily: _serif, fontWeight: FontWeight.w500, color: AppColors.ink),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, color: AppColors.inkSoft),
      bodyLarge: TextStyle(color: AppColors.ink, height: 1.45),
      bodyMedium: TextStyle(color: AppColors.ink, height: 1.4),
      bodySmall: TextStyle(color: AppColors.inkSoft, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
      labelMedium: TextStyle(color: AppColors.inkSoft, letterSpacing: 0.2),
      labelSmall: TextStyle(color: AppColors.inkSoft, letterSpacing: 0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: _serif,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.clay, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.inkSoft),
      floatingLabelStyle: const TextStyle(color: AppColors.clayDark),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: const Color(0xFFD9CFC7),
        disabledForegroundColor: AppColors.inkSoft,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.clayDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      highlightElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: pillRadius),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.inkSoft,
      textColor: AppColors.ink,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: AppColors.cream),
      shape: const RoundedRectangleBorder(borderRadius: radius),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: _serif,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      contentTextStyle: const TextStyle(color: AppColors.inkSoft, height: 1.45),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.clay,
    ),
  );
}

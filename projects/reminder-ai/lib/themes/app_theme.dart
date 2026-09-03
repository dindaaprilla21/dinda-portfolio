import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors (New Palette) ──────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF7785A3); // Slate Blue
  static const Color secondaryColor = Color(0xFFDBA66F); // Sandy Orange
  static const Color accentColor    = Color(0xFFE5C890); // Golden Yellow
  static const Color successColor   = Color(0xFF8CAF8F); // Sage Green
  static const Color warningColor   = Color(0xFFE5C890); // Golden Yellow
  static const Color errorColor     = Color(0xFFD67B7B); // Muted Coral Red
  static const Color infoColor      = Color(0xFF88A5C5); // Muted Blue

  // ─── Light Theme Colors ────────────────────────────────────────────────────
  static const Color lightBackgroundColor = Color(0xFFEADCB8); // Light Warm Cream
  static const Color lightSurfaceColor    = Color(0xFFFFFFFF);
  static const Color lightTextPrimary     = Color(0xFF2C3545); // Deep Slate
  static const Color lightTextSecondary   = Color(0xFF5E6982); // Muted Slate Blue
  static const Color lightBorderColor     = Color(0xFFDDDCD3); // Warm Sand Border

  // ─── Dark Theme Colors ─────────────────────────────────────────────────────
  static const Color darkBackgroundColor = Color(0xFF161922); // Deep Slate Navy
  static const Color darkSurfaceColor    = Color(0xFF222633); // Dark Slate Surface
  static const Color darkTextPrimary     = Color(0xFFECEEF4); // Slate White
  static const Color darkTextSecondary   = Color(0xFF9EABB8); // Muted Slate Gray
  static const Color darkBorderColor     = Color(0xFF2C3140); // Dark Slate Border

  // ─── Current Dynamic Colors ────────────────────────────────────────────────
  static Color backgroundColor = lightBackgroundColor;
  static Color surfaceColor    = lightSurfaceColor;
  static Color textPrimary     = lightTextPrimary;
  static Color textSecondary   = lightTextSecondary;
  static Color borderColor     = lightBorderColor;

  // ─── Premium Gradients ─────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF9AA7C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroBgGradient = LinearGradient(
    colors: [Color(0xFF5A6885), Color(0xFF3B465C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        background: lightBackgroundColor,
        onBackground: lightTextPrimary,
        onSurface: lightTextPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurfaceColor,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurfaceColor,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.outfit(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.outfit(
          color: lightTextSecondary,
          fontSize: 15,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected) ? primaryColor : Colors.white),
        trackColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected)
                ? primaryColor.withOpacity(0.4)
                : Colors.grey.shade300),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: lightSurfaceColor,
        hourMinuteColor: lightBackgroundColor,
        hourMinuteTextColor: lightTextPrimary,
        dialBackgroundColor: lightBackgroundColor,
        dialHandColor: primaryColor,
        dialTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? Colors.white
              : lightTextPrimary,
        ),
        entryModeIconColor: primaryColor,
        dayPeriodTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? Colors.white
              : lightTextSecondary,
        ),
        dayPeriodColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor
              : lightBackgroundColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: lightSurfaceColor,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dayStyle: GoogleFonts.outfit(color: lightTextPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        onBackground: darkTextPrimary,
        onSurface: darkTextPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.outfit(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.outfit(
          color: darkTextSecondary,
          fontSize: 15,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected) ? primaryColor : Colors.grey.shade400),
        trackColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected)
                ? primaryColor.withOpacity(0.45)
                : darkBorderColor),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: darkSurfaceColor,
        hourMinuteColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor.withOpacity(0.3)
              : darkBackgroundColor,
        ),
        hourMinuteTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor
              : darkTextPrimary,
        ),
        dialBackgroundColor: darkBackgroundColor,
        dialHandColor: primaryColor,
        dialTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? Colors.white
              : darkTextPrimary,
        ),
        entryModeIconColor: secondaryColor,
        dayPeriodTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? Colors.white
              : darkTextSecondary,
        ),
        dayPeriodColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor
              : darkBackgroundColor,
        ),
        helpTextStyle: GoogleFonts.outfit(
          color: darkTextSecondary,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: darkSurfaceColor,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dayStyle: GoogleFonts.outfit(color: darkTextPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Update Dynamic Colors ─────────────────────────────────────────────────
  static void updateThemeColors(bool isDark) {
    if (isDark) {
      backgroundColor = darkBackgroundColor;
      surfaceColor    = darkSurfaceColor;
      textPrimary     = darkTextPrimary;
      textSecondary   = darkTextSecondary;
      borderColor     = darkBorderColor;
    } else {
      backgroundColor = lightBackgroundColor;
      surfaceColor    = lightSurfaceColor;
      textPrimary     = lightTextPrimary;
      textSecondary   = lightTextSecondary;
      borderColor     = lightBorderColor;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 3: return errorColor;
      case 2: return warningColor;
      case 1: return successColor;
      default: return textSecondary;
    }
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'akademik': primaryColor,
      'personal': secondaryColor,
      'kerja': accentColor,
      'kesehatan': successColor,
      'lainnya': textSecondary,
    };
    return colors[category.toLowerCase()] ?? textSecondary;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

class SunColors {
  // =========================
  // BRAND ACCENTS
  // =========================

  // Woman
  static const Color womanAccentDark = Color(0xFFFD00DD);
  static const Color womanAccentLight = Color(0xFFFD00DD);
  static const Color womanSecondaryDark = Color(0xFFFF66F0);
  static const Color womanSecondaryLight = Color(0xFFFF99F5);

  // Man
  static const Color manAccentDark = Color(0xFF00BFFF);
  static const Color manAccentLight = Color(0xFF0284C7);
  static const Color manSecondaryDark = Color(0xFF38BDF8);
  static const Color manSecondaryLight = Color(0xFF3B82F6);

  // =========================
  // STATUS
  // =========================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // =========================
  // GLOBAL NEUTRALS (PRO LOOK)
  // =========================

  // Dark – premium neutral (no tint)
  static const Color darkBg0 = Color(0xFF0B0F14);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF050505);
  static const Color darkText = Color(0xFFE6EDF6);
  static const Color darkMuted = Color(0xFF94A3B8);

  // Light – clean minimal
  static const Color lightBg = Color(0xFFF5F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);

  // =========================
  // BACKGROUND TOKENS
  // =========================
  // Stejný styl pro man i woman → jen jemný rozdíl tónu

  // MAN
  static const Color manBgLight = Color(0xFFF6FBFF);
  static const Color manBgTintLight = Color(0xFFEFF7FF);
  static const Color manBgDark = Color(0xFF0A0F17);
  static const Color manBgTintDark = Color(0xFF0D1623);

  static const Color manCardLight = Color(0xFFFFFFFF);
  static const Color manCardDark = Color(0xFF0F1722);

  static const Color manStrokeLight = Color(0x14000000);
  static const Color manStrokeDark = Color(0x14FFFFFF);

  // WOMAN (stejně čisté, žádná fialová mlha)
  static const Color womanBgLight = Color(0xFFFFFBFE);
  static const Color womanBgTintLight = Color(0xFFFFF4FB);
  static const Color womanBgDark = Color(0xFF0A0F17);
  static const Color womanBgTintDark = Color(0xFF14121A);

  static const Color womanCardLight = Color(0xFFFFFFFF);
  static const Color womanCardDark = Color(0xFF14141F);

  static const Color womanStrokeLight = Color(0x14000000);
  static const Color womanStrokeDark = Color(0x14FFFFFF);
}

class SunTheme {
  // ---------- Premium surface helpers ----------
  static Color accent(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanAccentDark : SunColors.womanAccentLight;
    }
    return isDark ? SunColors.manAccentDark : SunColors.manAccentLight;
  }

  /// Back-compat alias (older code)
  static Color accentColor(SunGenderMode gender, Brightness b) =>
      accent(gender, b);

  /// 70/30 brand gradient for buttons / highlights
  /// Brand gradient 70/30:
  /// - Woman: 70% pink -> 30% blue
  /// - Man:   70% blue -> 30% pink
  static LinearGradient brandGradient70_30(SunGenderMode gender) {
    final pink = SunColors.womanAccentDark; // #FD00DD
    final blue = SunColors.manAccentDark; // #00BFFF
    if (gender == SunGenderMode.woman) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [pink, pink, blue],
        stops: const [0.0, 0.70, 1.0],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [blue, blue, pink],
      stops: const [0.0, 0.70, 1.0],
    );
  }

  static Color cardSurface(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanCardDark : SunColors.womanCardLight;
    }
    return isDark ? SunColors.manCardDark : SunColors.manCardLight;
  }

  static Color surfaceStroke(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanStrokeDark : SunColors.womanStrokeLight;
    }
    return isDark ? SunColors.manStrokeDark : SunColors.manStrokeLight;
  }

  static List<BoxShadow> surfaceShadow(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    final a = accent(gender, b);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.32 : 0.08),
        blurRadius: 26,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: a.withOpacity(isDark ? 0.06 : 0.04),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  static ThemeData dark(SunGenderMode gender) {
    final primary = gender == SunGenderMode.woman
        ? SunColors.womanAccentDark
        : SunColors.manAccentDark;

    final secondary = gender == SunGenderMode.woman
        ? SunColors.womanSecondaryDark
        : SunColors.manSecondaryDark;

    final cs = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: SunColors.darkSurface,
      error: SunColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: SunColors.darkCard, // pozadí celé aplikace
      cardColor: SunColors.darkCard,
      dividerColor: Colors.white10,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SunColors.darkText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: SunColors.darkText,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: SunColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: SunColors.darkText),
        bodySmall: TextStyle(color: SunColors.darkMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SunColors.darkText,
          side: BorderSide(color: primary.withOpacity(0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.06),
        selectedColor: primary.withOpacity(0.18),
        side: BorderSide(color: Colors.white.withOpacity(0.10)),
        labelStyle: const TextStyle(color: SunColors.darkText),
        secondaryLabelStyle: const TextStyle(color: SunColors.darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black, // pozadi spodni menu
        selectedItemColor: primary,
        unselectedItemColor: SunColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData light(SunGenderMode gender) {
    final primary = gender == SunGenderMode.woman
        ? SunColors.womanAccentLight
        : SunColors.manAccentLight;

    final secondary = gender == SunGenderMode.woman
        ? SunColors.womanSecondaryLight
        : SunColors.manSecondaryLight;

    final cs = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: SunColors.lightSurface,
      error: SunColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: SunColors.lightCard, // pozadí celeé aplikace
      cardColor: SunColors.lightCard,
      dividerColor: const Color(0xFFE9EBF3),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SunColors.lightText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: SunColors.lightText,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: SunColors.lightText,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: SunColors.lightText),
        bodySmall: TextStyle(color: SunColors.lightMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SunColors.lightText,
          side: BorderSide(color: primary.withOpacity(0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primary.withOpacity(0.12),
        side: const BorderSide(color: Color(0xFFE9EBF3)),
        labelStyle: const TextStyle(color: SunColors.lightText),
        secondaryLabelStyle: const TextStyle(color: SunColors.lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: SunColors.lightMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  /// Helper pro background gradient podle gender + brightness
  static List<Color> backgroundGradient(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (isDark) {
      return [
        gender == SunGenderMode.man
            ? SunColors.manBgDark
            : SunColors.womanBgDark,
        gender == SunGenderMode.man
            ? SunColors.manBgTintDark
            : SunColors.womanBgTintDark,
      ];
    } else {
      return [
        gender == SunGenderMode.man
            ? SunColors.manBgLight
            : SunColors.womanBgLight,
        gender == SunGenderMode.man
            ? SunColors.manBgTintLight
            : SunColors.womanBgTintLight,
      ];
    }
  }
}

class SunSectionMenuItem {
  final String label;
  final IconData icon;

  const SunSectionMenuItem({required this.label, required this.icon});
}

import 'package:flutter/material.dart';

/// Design tokens — «Old Coptic Orthodox Monastery — Luxury Digital Manuscript Library».
/// Colours are the owner's palette (2026-11-03); derived tones are mixed from them.
abstract final class AppColors {
  static const obsidian = Color(0xFF14110F);
  static const walnut = Color(0xFF302018);
  static const leather = Color(0xFF513329);
  static const gold = Color(0xFFB68D48);
  static const goldHi = Color(0xFFE3CCA0);
  static const parchment = Color(0xFFEFE4CF);
  static const burgundy = Color(0xFF6B2429);

  // Derived.
  static const goldDeep = Color(0xFF7A5A2A);
  static const ink = Color(0xFF2A1E17); // text on parchment (contrast ≈ 13:1)
  static const inkSoft = Color(0xFF5E4A3C); // secondary text on parchment (≈ 7:1)
  static const ivory = Color(0xFFF4ECDD); // text on dark (≈ 15:1 on obsidian)
  static const ivorySoft = Color(0xFFC9B9A0); // secondary on dark (≈ 9:1)
  static const hairline = Color(0x33E3CCA0);
  static const rubric = Color(0xFF8A2A2F); // liturgical rubrics on parchment
  static const candleBg = Color(0xFF1A1512);
  static const candleText = Color(0xFFE9DCC4);
}

abstract final class Fonts {
  /// Editorial headings and long reading text.
  static const display = 'Amiri';

  /// Interface: buttons, labels, descriptions.
  static const ui = 'IBMPlexSansArabic';
  static const coptic = 'NotoSansCoptic';
}

abstract final class Textures {
  static const leather = 'assets/textures/leather.jpg';
  static const walnut = 'assets/textures/walnut.jpg';
  static const sandstone = 'assets/textures/sandstone.jpg';
  static const parchment = 'assets/textures/parchment.jpg';
}

abstract final class Space {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 24.0, xxl = 32.0, xxxl = 48.0;
}

abstract final class Radii {
  static const card = 10.0, cover = 6.0, pill = 40.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 420);
  static const slow = Duration(milliseconds: 700);
  static const curve = Curves.easeOutCubic;

  /// Honours prefers-reduced-motion (Flutter web maps it to disableAnimations).
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Aged-gold metal: a tight bright edge over a muted body; no yellow glow.
abstract final class Gilt {
  static const gradient = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [Color(0xFF8C6A33), AppColors.goldHi, AppColors.gold, Color(0xFF7A5A2A), Color(0xFFC9A464)],
    stops: [0, 0.22, 0.48, 0.78, 1],
  );

  static List<BoxShadow> innerish = const [BoxShadow(color: Color(0x66000000), blurRadius: 1, offset: Offset(0, 1))];
}

abstract final class AppText {
  static const heroTitle = TextStyle(
    fontFamily: Fonts.display,
    fontSize: 46,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.ivory,
  );
  static const eyebrow = TextStyle(
    fontFamily: Fonts.ui,
    fontSize: 13,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.goldHi,
  );
  static const lead = TextStyle(fontFamily: Fonts.ui, fontSize: 16, height: 1.75, color: AppColors.ivorySoft);
  static const sectionTitle = TextStyle(
    fontFamily: Fonts.display,
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ivory,
  );
  static const cardTitle = TextStyle(
    fontFamily: Fonts.display,
    fontSize: 21,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.ivory,
  );
  static const body = TextStyle(fontFamily: Fonts.ui, fontSize: 15, height: 1.7, color: AppColors.ivorySoft);
  static const label = TextStyle(
    fontFamily: Fonts.ui,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.ivory,
  );
  static const caption = TextStyle(fontFamily: Fonts.ui, fontSize: 12, height: 1.5, color: AppColors.ivorySoft);
  static const button = TextStyle(fontFamily: Fonts.ui, fontSize: 15, fontWeight: FontWeight.w600);
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.obsidian,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.obsidian,
      secondary: AppColors.burgundy,
      surface: AppColors.walnut,
      onSurface: AppColors.ivory,
    ),
    textTheme: base.textTheme.apply(fontFamily: Fonts.ui, bodyColor: AppColors.ivory, displayColor: AppColors.ivory),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.gold),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.gold),
  );
}

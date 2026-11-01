import 'package:flutter/material.dart';

/// «Old Coptic Luxury» tokens (docs/design/DESIGN_DIRECTION.md).
class Palette {
  const Palette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.rubric,
    required this.lapis,
    required this.gold,
    required this.line,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color inkSoft;
  final Color rubric;
  final Color lapis;
  final Color gold;
  final Color line;

  /// Parchment day mode.
  static const parchment = Palette(
    background: Color(0xFFF3EBDD),
    surface: Color(0xFFFAF5EC),
    ink: Color(0xFF2B2118),
    inkSoft: Color(0xFF6B5A47),
    rubric: Color(0xFF9E2B1E),
    lapis: Color(0xFF26407A),
    gold: Color(0xFFB08A3E),
    line: Color(0xFFD9CBB2),
  );

  /// Candle night mode.
  static const candle = Palette(
    background: Color(0xFF15110D),
    surface: Color(0xFF1F1913),
    ink: Color(0xFFEADBC0),
    inkSoft: Color(0xFFB09C7E),
    rubric: Color(0xFFD4705F),
    lapis: Color(0xFF8FA6DA),
    gold: Color(0xFFD1AE62),
    line: Color(0xFF3A3026),
  );
}

class Fonts {
  static const arabic = 'Amiri';
  static const coptic = 'NotoSansCoptic';
}

ThemeData buildTheme(Palette p, Brightness b) {
  final base = ThemeData(brightness: b, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    colorScheme: base.colorScheme.copyWith(
      primary: p.lapis,
      secondary: p.gold,
      surface: p.surface,
      onSurface: p.ink,
      error: p.rubric,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: Fonts.arabic,
      bodyColor: p.ink,
      displayColor: p.ink,
    ),
    dividerColor: p.line,
  );
}

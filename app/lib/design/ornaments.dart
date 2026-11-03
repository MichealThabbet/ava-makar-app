import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Original ornaments drawn in code, inspired by Coptic geometric interlace.
/// They are new designs, not reproductions of any documented artefact.

Paint _giltStroke(Rect r, double w) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..shader = Gilt.gradient.createShader(r);

/// Corner piece: two interlaced quarter-loops and a small stepped cross-knot.
class CornerOrnament extends StatelessWidget {
  const CornerOrnament({super.key, this.size = 46, this.quarterTurns = 0});
  final double size;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: quarterTurns,
    child: CustomPaint(size: Size.square(size), painter: _CornerPainter()),
  );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    final p = _giltStroke(r, s.width * 0.035);
    final u = s.width;
    // Frame arms.
    c.drawLine(Offset(u * 0.06, u * 0.06), Offset(u, u * 0.06), p);
    c.drawLine(Offset(u * 0.06, u * 0.06), Offset(u * 0.06, u), p);
    c.drawLine(Offset(u * 0.16, u * 0.16), Offset(u * 0.86, u * 0.16), p..strokeWidth = u * 0.018);
    c.drawLine(Offset(u * 0.16, u * 0.16), Offset(u * 0.16, u * 0.86), p);
    // Interlaced loops (over-under rendered by a gap in the lower strand).
    p.strokeWidth = u * 0.03;
    c.drawArc(
      Rect.fromCircle(center: Offset(u * 0.34, u * 0.34), radius: u * 0.16),
      math.pi * 0.05,
      math.pi * 1.9,
      false,
      p,
    );
    c.drawArc(
      Rect.fromCircle(center: Offset(u * 0.50, u * 0.50), radius: u * 0.12),
      -math.pi * 0.95,
      math.pi * 1.7,
      false,
      p,
    );
    // Stepped knot.
    final k = Offset(u * 0.34, u * 0.34);
    final d = u * 0.045;
    c.drawRect(
      Rect.fromCenter(center: k, width: d * 2, height: d * 2),
      Paint()..shader = Gilt.gradient.createShader(r),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Horizontal divider: fading hairlines and a central interlace medallion.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.width = 220, this.onLight = false});
  final double width;
  final bool onLight;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, 22), painter: _DividerPainter(onLight));
}

class _DividerPainter extends CustomPainter {
  _DividerPainter(this.onLight);
  final bool onLight;

  @override
  void paint(Canvas c, Size s) {
    final mid = Offset(s.width / 2, s.height / 2);
    final edge = onLight ? AppColors.goldDeep : AppColors.gold;
    for (final dir in [-1.0, 1.0]) {
      final from = mid + Offset(dir * 18, 0);
      final to = Offset(dir < 0 ? 0 : s.width, mid.dy);
      c.drawLine(
        from,
        to,
        Paint()
          ..strokeWidth = 1
          ..shader = LinearGradient(colors: [edge, edge.withValues(alpha: 0)]).createShader(Rect.fromPoints(from, to)),
      );
    }
    final r = Rect.fromCircle(center: mid, radius: 11);
    final p = _giltStroke(r, 1.4);
    // Four interlocking petals around a square — a knot rosette.
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final cOff = mid + Offset(math.cos(a), math.sin(a)) * 4.5;
      c.drawCircle(cOff, 4.5, p);
    }
    c.drawRect(Rect.fromCenter(center: mid, width: 4, height: 4), Paint()..color = edge);
  }

  @override
  bool shouldRepaint(covariant _DividerPainter old) => old.onLight != onLight;
}

/// Small, respectful mark: a Coptic cross inside a gilt ring (logo placeholder
/// until the monastery's official emblem is supplied).
class MonasteryMark extends StatelessWidget {
  const MonasteryMark({super.key, this.size = 34});
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _MarkPainter());
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    final ctr = r.center;
    final u = s.width;
    c.drawCircle(ctr, u * 0.47, Paint()..color = AppColors.obsidian.withValues(alpha: 0.55));
    c.drawCircle(ctr, u * 0.46, _giltStroke(r, u * 0.045));
    c.drawCircle(ctr, u * 0.38, _giltStroke(r, u * 0.015));
    final fill = Paint()..shader = Gilt.gradient.createShader(r);
    final arm = u * 0.1, len = u * 0.26;
    for (var i = 0; i < 4; i++) {
      c.save();
      c.translate(ctr.dx, ctr.dy);
      c.rotate(i * math.pi / 2);
      final path = Path()
        ..moveTo(-arm / 2, 0)
        ..lineTo(arm / 2, 0)
        ..lineTo(arm * 0.95, -len)
        ..lineTo(-arm * 0.95, -len)
        ..close();
      c.drawPath(path, fill);
      c.drawCircle(Offset(0, -len - arm * 0.35), arm * 0.32, fill);
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Carved arch outline used to frame the hero composition.
class ArchFramePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final inset = 18.0;
    final path = Path()
      ..moveTo(inset, h)
      ..lineTo(inset, h * 0.42)
      ..arcToPoint(Offset(w - inset, h * 0.42), radius: Radius.elliptical((w - inset * 2) / 2, h * 0.34))
      ..lineTo(w - inset, h);
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldHi.withValues(alpha: 0.55), AppColors.gold.withValues(alpha: 0)],
        ).createShader(Offset.zero & s),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

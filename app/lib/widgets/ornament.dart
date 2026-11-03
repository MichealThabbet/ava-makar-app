import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Original interlace headpiece band (drawn for this app, not traced).
class Headpiece extends StatelessWidget {
  const Headpiece({super.key, required this.color, this.height = 18});
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _BandPainter(color)),
  );
}

class _BandPainter extends CustomPainter {
  _BandPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final mid = size.height / 2;
    final r = size.height / 2 - 2;
    canvas.drawLine(Offset(0, 1), Offset(size.width, 1), paint);
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), paint);
    final step = r * 2.4;
    for (double x = r + 4; x < size.width - r; x += step) {
      canvas.drawCircle(Offset(x, mid), r * 0.75, paint);
      final path = Path()
        ..moveTo(x + r * 0.75, mid)
        ..quadraticBezierTo(x + step / 2, mid - r, x + step - r * 0.75, mid)
        ..moveTo(x + r * 0.75, mid)
        ..quadraticBezierTo(x + step / 2, mid + r, x + step - r * 0.75, mid);
      if (x + step < size.width - r) canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BandPainter old) => old.color != color;
}

/// Small Coptic-style cross mark built from four arms.
class CrossMark extends StatelessWidget {
  const CrossMark({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _CrossPainter(color)),
  );
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color;
    final c = Offset(s.width / 2, s.height / 2);
    final arm = s.width * 0.42;
    final w = s.width * 0.16;
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * math.pi / 2);
      final path = Path()
        ..moveTo(-w / 2, 0)
        ..lineTo(-w / 2, -arm * 0.75)
        ..lineTo(-w * 1.1, -arm)
        ..lineTo(w * 1.1, -arm)
        ..lineTo(w / 2, -arm * 0.75)
        ..lineTo(w / 2, 0)
        ..close();
      canvas.drawPath(path, p);
      canvas.restore();
    }
    canvas.drawCircle(c, w * 0.9, p);
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}

/// Manuscript-style illuminated initial for the first letter of a text.
class IlluminatedInitial extends StatelessWidget {
  const IlluminatedInitial({
    super.key,
    required this.letter,
    required this.gold,
    required this.ink,
    required this.fontFamily,
  });

  final String letter;
  final Color gold;
  final Color ink;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      margin: const EdgeInsetsDirectional.only(end: 10, top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: gold, width: 1.4),
        borderRadius: BorderRadius.circular(4),
        gradient: RadialGradient(colors: [gold.withValues(alpha: 0.22), gold.withValues(alpha: 0.04)]),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(fontFamily: fontFamily, fontSize: 32, color: ink, fontWeight: FontWeight.w700, height: 1.1),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

// ── SVG source ────────────────────────────────────────────────────────────────
// viewBox="0 0 146 134"  stroke gradient: #31C9D6 → #A24FCA
// stroke-width: 4.05567  stroke-linecap/join: round
// ─────────────────────────────────────────────────────────────────────────────

const _kViewW = 146.0;
const _kViewH = 134.0;
const _kStrokeW = 4.05567;

const _kPathData =
    'M54.6049 26.9022C54.6049 18.2679 48.6226 9.63707 25.1695 30.6029'
    'C-7.94554 60.2061 3.09298 126.814 6.7724 130.514'
    'C10.4518 134.215 50.9255 115.713 54.6049 108.312'
    'C58.2843 100.911 50.9255 89.8096 58.2843 75.0078'
    'M91.3991 26.9021C91.3991 18.2677 97.3814 9.63693 120.834 30.6028'
    'C153.95 60.206 142.911 126.814 139.232 130.514'
    'C135.552 134.215 95.0785 115.712 91.3991 108.312'
    'C87.7196 100.911 95.0785 89.8094 87.7196 75.0077'
    'M109.797 86.11C109.797 68.6355 98.6143 59.9237 90.0984 54.2562'
    'C72.5337 42.5665 73.002 20.8013 73.002 2.02778'
    'C73.002 20.8013 73.4704 42.5665 55.9057 54.2562'
    'C47.3898 59.9237 36.208 68.6355 36.208 86.11';

const _kColorStart = Color(0xFF31C9D6);
const _kColorEnd = Color(0xFFA24FCA);

// ── Painter ───────────────────────────────────────────────────────────────────

class Spo2IconPainter extends CustomPainter {
  const Spo2IconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width / _kViewW, size.height / _kViewH);
    final dx = (size.width - _kViewW * scale) / 2;
    final dy = (size.height - _kViewH * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final path = parseSvgPathData(_kPathData);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_kColorStart, _kColorEnd],
      ).createShader(Rect.fromLTWH(0, 0, _kViewW, _kViewH));

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Spo2IconPainter old) => false;
}

// ── Widget wrapper ────────────────────────────────────────────────────────────

class Spo2Icon extends StatelessWidget {
  final double size;

  const Spo2Icon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: Spo2IconPainter()),
    );
  }
}

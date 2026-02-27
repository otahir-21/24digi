import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

// ── SVG source ────────────────────────────────────────────────────────────────
// viewBox="0 0 117 119"  stroke gradient: #31C8D4 → #A852D2
// stroke-width: 13.5  stroke-linecap/join: round
// ─────────────────────────────────────────────────────────────────────────────

const _kViewW = 117.0;
const _kViewH = 119.0;
const _kStrokeW = 13.5;

const _kPathData =
    'M54.75 43.6419V81.4057'
    'M62.75 81.4057V43.6419'
    'M81.1389 111.75C58.25 104.525 12.4722 88.3418 12.4722 81.4057'
    'C12.4722 73.0654 47.7731 80.7712 57.2505 85.2284'
    'C57.8882 85.5283 58.6118 85.5283 59.2495 85.2284'
    'C68.7269 80.7712 104.028 73.0654 104.028 81.4057'
    'C104.028 88.3418 58.25 104.525 35.3611 111.75'
    'M6.75 60.6689C34.2167 60.6689 41.0833 43.8665 47.95 40.495'
    'C54.8167 37.1235 61.6833 37.1229 68.55 40.4958'
    'C75.4167 43.8688 82.2833 60.6689 109.75 60.6689'
    'M65.4028 13.8446C65.4028 17.7628 62.2004 20.9392 58.25 20.9392'
    'C54.2996 20.9392 51.0972 17.7628 51.0972 13.8446'
    'C51.0972 9.92636 54.2996 6.75 58.2499 6.75'
    'C62.2003 6.75 65.4028 9.92636 65.4028 13.8446Z';

const _kColorStart = Color(0xFF31C8D4);
const _kColorEnd = Color(0xFFA852D2);

// ── Painter ───────────────────────────────────────────────────────────────────

class StressIconPainter extends CustomPainter {
  const StressIconPainter();

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
  bool shouldRepaint(covariant StressIconPainter old) => false;
}

// ── Widget wrapper ────────────────────────────────────────────────────────────

class StressIcon extends StatelessWidget {
  final double size;

  const StressIcon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: StressIconPainter()),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/app_constants.dart';

/// A reusable painter for drawing the application's signature cyan-to-purple
/// gradient border onto any rounded rectangle.
class DigiGradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;

  const DigiGradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppGradients.smoothBorderColors,
        stops: AppGradients.smoothBorderStops,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant DigiGradientBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.strokeWidth != strokeWidth;
}

import 'package:flutter/material.dart';
import '../core/app_constants.dart';

/// A [CustomPainter] that draws a rounded-rectangle border with the shared
/// 7-stop cyan → transparent → purple smooth gradient used on every tile,
/// chip and review-section card throughout the app.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   painter: SmoothGradientBorder(radius: 12 * s, selected: isSelected),
///   child: ...,
/// )
/// ```
class SmoothGradientBorder extends CustomPainter {
  final double radius;

  /// When [selected] is true the stroke is 1.5 px wide, otherwise 1.0 px.
  final bool selected;

  const SmoothGradientBorder({
    required this.radius,
    this.selected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 1.5 : 1.0
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppGradients.smoothBorderColors,
        stops: AppGradients.smoothBorderStops,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant SmoothGradientBorder old) =>
      old.selected != selected || old.radius != radius;
}

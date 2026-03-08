import 'package:flutter/material.dart';

class GradientBorderWrapper extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final Color innerColor;

  const GradientBorderWrapper({
    super.key,
    required this.child,
    this.height = 68.32,
    this.borderRadius = 40,
    this.borderWidth = 2,
    this.innerColor = const Color(0xFF020A10), // Your app background
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: RadialGradient(
          radius: 8,
          center: Alignment.centerLeft,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            const Color(0xFF00F0FF).withOpacity(0.5),
            const Color(0xFFFFFFFF).withOpacity(0.2),
            const Color(0xFFCE6AFF).withOpacity(0.8),
            const Color(0xFF8726B7).withOpacity(0.0),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          color: innerColor.withOpacity(0.95),
        ),
        child: child,
      ),
    );
  }
}

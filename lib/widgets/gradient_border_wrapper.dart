import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

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
    final s = UIScale.of(context);
    return Container(
      height: height* s,
      padding: EdgeInsets.all(borderWidth* s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius* s),
        gradient: RadialGradient(
          radius: 10* s,
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
          borderRadius: BorderRadius.circular(borderRadius* s - borderWidth* s),
          color: innerColor.withOpacity(0.95),
        ),
        child: child,
      ),
    );
  }
}

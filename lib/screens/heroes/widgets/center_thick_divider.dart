import 'package:flutter/material.dart';

class CenterThickDivider extends StatelessWidget {
  final double width;
  final double maxThickness;
  final Color color;

  const CenterThickDivider({
    super.key,
    this.width = double.infinity,
    this.maxThickness = 2,
    this.color = const Color(0xFF6B7680),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: maxThickness,
      child: CustomPaint(
        painter: _DividerPainter(color, maxThickness),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _DividerPainter(this.color, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    final centerY = size.height / 2;
    final halfThickness = thickness / 2;

    path.moveTo(0, centerY);
    path.quadraticBezierTo(
      size.width * 0.25,
      centerY - halfThickness,
      size.width * 0.5,
      centerY - halfThickness,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      centerY - halfThickness,
      size.width,
      centerY,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      centerY + halfThickness,
      size.width * 0.5,
      centerY + halfThickness,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      centerY + halfThickness,
      0,
      centerY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class CircleIcon extends StatelessWidget {
  final String icon;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? iconColor;

  const CircleIcon({
    super.key,
    required this.icon,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      padding: EdgeInsets.all(6 * s),
      height: height ?? 43 * s,
      width: width ?? 43 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
        color: backgroundColor ?? Color(0xFF1C2230),
      ),
      child: Center(child: Image.asset(icon, color: iconColor)),
    );
  }
}

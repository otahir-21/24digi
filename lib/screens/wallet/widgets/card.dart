import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class BaseCard extends StatelessWidget {
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? borderColor;
  final Widget? child;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? height;
  final double? width;
  final LinearGradient? gradient;

  const BaseCard({
    super.key,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.child,
    this.horizontalPadding,
    this.verticalPadding,
    this.height,
    this.width, this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      height: height,
      width: width,
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: horizontalPadding ?? 0,
        vertical: verticalPadding?? 0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xff0A1019).withValues(alpha: 0.2),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 16 * s),
        border: Border.all(
          color: borderColor ?? Color(0xffFFFFFF).withOpacity(0.04),
        ),
      ),
      child: child,
    );
  }
}

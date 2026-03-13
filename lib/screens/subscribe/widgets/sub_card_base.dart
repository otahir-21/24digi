import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class SubCardBase extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? horizontalPadding;
  final double? verticalPadding;

  const SubCardBase({
    super.key,
    required this.child,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 18 * s,
        vertical: verticalPadding ?? 20 * s,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xffFFFFFF).withValues(alpha: 0.06),
          width: 1.25,
        ),
        borderRadius: BorderRadius.circular(14 * s),
        color: Color(0xffFFFFFF).withValues(alpha: 0.04),
      ),
      child: child,
    );
  }
}

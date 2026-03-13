import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class HeroBaseContainer extends StatelessWidget {
  final Widget? child;
  const HeroBaseContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return  Container(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: 26 * s,
        horizontal: 22 * s,
      ),
      decoration: BoxDecoration(
        color: Color(0xff9BB6EB).withValues(alpha: 0.2),
        border: Border.all(color: Color(0xff9BB6EB).withValues(alpha: 0.21)),
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}

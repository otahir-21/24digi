import 'package:flutter/material.dart';

class SubCardBase extends StatelessWidget {
  final Widget child;
  const SubCardBase({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffFFFFFF).withValues(alpha: 0.06), width: 1.25),
        borderRadius: BorderRadius.circular(14),
        color: Color(0xffFFFFFF).withValues(alpha: 0.04),
      ),
      child: child,
    );
  }
}

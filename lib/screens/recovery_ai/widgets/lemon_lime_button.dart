import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/gradient_border_wrapper.dart';

class LemonLimeButton extends StatelessWidget {

  final VoidCallback? onTap;
  const LemonLimeButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderWrapper(
        innerColor: Color(0xff000403),
        child: Center(
          child: Text(
            "CONTINUE",
            style: const TextStyle(
              fontFamily: "LemonMilk",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xff6FFFE9),
            ),
          ),
        ),
      ),
    );
  }
}

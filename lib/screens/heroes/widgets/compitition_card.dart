import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class CompititionCard extends StatelessWidget {
  final Color? borderColor;
  final String image;
  final String name;

  const CompititionCard({
    super.key,
    this.borderColor,
    required this.image,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final Color themeColor = borderColor ?? const Color(0xffCB9D5D);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 50 * s),
          decoration: BoxDecoration(
            color: const Color(0xff151B20),
            border: Border.all(
              color: themeColor,
              width: 3 * s,
            ),
            borderRadius: BorderRadius.circular(25 * s),
          ),
          child: Image.asset(
            image,
            height: 114 * s,
            width: 36 * s,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 11 * s),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "HelveticaNeue",
            fontSize: 12 * s,
            fontWeight: FontWeight.w500,
            color: themeColor,
          ),
        ),
      ],
    );
  }
}

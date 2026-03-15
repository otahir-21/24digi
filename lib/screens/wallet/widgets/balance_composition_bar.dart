import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class BalanceCompositionBar extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;

  const BalanceCompositionBar({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    // Convert 0.75 to "75%"
    final String percentText = "${(percentage * 100).toInt()}%";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 14 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xff8888A0),
              ),
            ),
            Text(
              percentText,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * s),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8 * s,
            backgroundColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/widgets/custom_text_field.dart';

class CustomAmountWidget extends StatelessWidget {
  const CustomAmountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      horizontalPadding: 18*s,
      verticalPadding: 18*s,
      backgroundColor: Colors.white.withValues(alpha: 0.02),
      borderColor: Colors.white.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8*s,
        children: [
          Text(
            "Amount (AED)",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xff8888A0),
            ),
          ),
          CustomTextField(
              backgroundColor: Colors.white.withValues(alpha: 0.03),
              borderColor: Colors.white.withValues(alpha: 0.06),
              hintText: "AED 50"),
          Text(
            "You will receive ~500 points",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xff00D4AA),
            ),
          ),
        ],
      ),
    );
  }
}

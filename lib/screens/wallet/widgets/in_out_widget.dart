import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';

class InOutWidget extends StatelessWidget {
  final bool totalIn;
  final String? amount;

  const InOutWidget({super.key, this.amount, this.totalIn = true});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      horizontalPadding: 17 * s,
      verticalPadding: 17 * s,
      width: 197*s,
      borderColor: totalIn
          ? const Color(0xFF00D4AA).withValues(alpha: 0.04)
          : Color(0xffF472B6).withValues(alpha: 0.04),
      backgroundColor: totalIn
          ? const Color(0xFF00D4AA).withValues(alpha: 0.06)
          : Color(0xffF472B6).withValues(alpha: 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalIn ? "Total In" : "Total out",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: const Color(0xFF555568),
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount ?? "",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: totalIn ? const Color(0xFF00D4AA) : Color(0xffF472B6),
                  fontSize: 19 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(width: 8 * s),
          Image.asset(
            "assets/profile/profile_digi_point.png",
            height: 55 * s,
            width: 55 * s,
          ),
        ],
      ),
    );
  }
}

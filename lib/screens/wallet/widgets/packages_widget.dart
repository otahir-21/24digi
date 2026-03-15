import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';

class PackagesWidget extends StatelessWidget {
  final String? title;
  final String? amount;
  final String? suffix;
  final double? suffixFontSize;
  final Color? suffixFontColor;
  final bool isBestValue; // New Property

  const PackagesWidget({
    super.key,
    this.title,
    this.amount,
    this.suffix,
    this.suffixFontSize,
    this.suffixFontColor,
    this.isBestValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BaseCard(
          horizontalPadding: 18 * s,
          verticalPadding: 12*s,
          // If best value, use a subtle gold border, else keep original
          borderColor: Colors.white.withValues(alpha: 0.04),
          backgroundColor: Colors.white.withValues(alpha: 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amount ?? "",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: const Color(0xFFFFFFFF),
                          fontSize: 19 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        title ?? "",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: const Color(0xFF555568),
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8 * s),
                  Image.asset(
                    "assets/images/digi_point.png",
                    height: 55 * s,
                    width: 55 * s,
                  ),
                ],
              ),
              Text(
                suffix ?? "",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: suffixFontColor ?? const Color(0xffFFFFFF),
                  fontSize: suffixFontSize ?? 15 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Best Value Tag
        if (isBestValue)
          Positioned(
            top: -10 * s,
            left: 12 * s,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                color: const Color(0xff00D4AA),
                borderRadius: BorderRadius.circular(20 * s),
              ),
              child: Text(
                "BEST VALUE",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

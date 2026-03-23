import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';

class PurchasingWidget extends StatelessWidget {
  final String? title;
  final String? amount;
  final String? suffix;
  final double? suffixFontSize;
  final Color? suffixFontColor;
  final bool showPts;

  const PurchasingWidget({
    super.key,
    this.suffix,
    this.suffixFontSize,
    this.suffixFontColor, this.amount, this.title, this.showPts = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      horizontalPadding: 17 * s,
      verticalPadding: 17 * s,
      borderColor: Color(0xff00D4AA).withValues(alpha: 0.1),
      backgroundColor: Color(0xff00D4AA).withValues(alpha: 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "You're purchasing",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: const Color(0xFF8888A0),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: amount ?? "2,500 ",
                          style: TextStyle(
                            fontSize: 19 * s,
                            color: Color(0xffFFFFFF),
                          ),
                        ),
                        if(showPts)
                        TextSpan(
                          text: "PTS ",
                          style: TextStyle(
                            color: const Color(
                              0xff00D4AA,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        if(showPts)
                        const TextSpan(
                          text: "+250",
                          style: TextStyle(color: Color(0xffFBBF24)),
                        ),
                      ],
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
          Text(
            suffix ?? "225.00 AED",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: suffixFontColor?? const Color(0xffFFFFFF),
              fontSize: suffixFontSize?? 21 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

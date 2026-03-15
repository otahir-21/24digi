import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class RewardsWidget extends StatelessWidget {
  final Color? cardColor;
  final Color? cardBorderColor;
  final String? icon;
  final Color? iconBackgroundColor;
  final String? title;
  final Color? titleColor;
  final String? description;
  final String? points;
  final String? category;
  final String? dayLeft;
  final VoidCallback? buttonOnTap;

  const RewardsWidget({
    super.key,
    this.cardColor,
    this.cardBorderColor,
    this.icon,
    this.iconBackgroundColor,
    this.title,
    this.description,
    this.titleColor,
    this.points,
    this.category,
    this.dayLeft,
    this.buttonOnTap, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final Color defaultThemeColor = const Color(0xff6366F1);

    return BaseCard(
      horizontalPadding: 17 * s,
      verticalPadding: 17 * s,
      backgroundColor: Color(0xffffffff).withValues(alpha: 0.02),
      borderColor: cardBorderColor ?? Color(0xffffffff).withValues(alpha: 0.04),
      child: Column(
        spacing: 12 * s,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleIcon(
                height: 51 * s,
                width: 51 * s,
                borderRadius: 16 * s,
                backgroundColor:
                    iconBackgroundColor ??
                    defaultThemeColor.withValues(alpha: 0.1),
                icon: icon ?? "assets/icons/starr.png",
              ),
              SizedBox(width: 11 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title ?? "",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            color: titleColor ?? Color(0xffffffff),
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      description ?? "",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        color: const Color(0xFF555568),
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      spacing: 8 * s,
                      children: [
                        Text(
                          "${points ?? ""} PTS",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            color: titleColor ?? Color(0xff00D4AA),
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * s,
                            vertical: 4 * s,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffffffff).withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                          child: Text(
                            category ?? "",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              color: Color(0xff8888A0),
                              fontWeight: FontWeight.w500,
                              fontSize: 9 * s,
                            ),
                          ),
                        ),
                        if (dayLeft != null) ...[
                          SizedBox(width: 8 * s),
                          Image.asset("assets/icons/timmer.png"),
                          Text(
                            dayLeft ?? "",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              color: Color(0xffF472B6),
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          PrimaryButton(
            onTap: buttonOnTap,
            title: "Redeem Now",
            fontColor: Color(0xff00D4AA),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            isGradient: true,
            gradientColorList: [
              Color(0xff00D4AA).withValues(alpha: 0.12),
              Color(0xff00D4AA).withValues(alpha: 0.02),
            ],
            borderColor: Color(0xff00D4AA).withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }
}

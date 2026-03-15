import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class AiInsightWidget extends StatelessWidget {
  final Color? cardColor;
  final Color? cardBorderColor;
  final String? icon;
  final Color? iconBackgroundColor;
  final String? title;
  final Color? titleColor;
  final String? description;
  final bool showSuffixIcon;
  final bool isUrgent;
  final double? horizontalOuterPadding;

  const AiInsightWidget({
    super.key,
    this.cardColor,
    this.cardBorderColor,
    this.icon,
    this.iconBackgroundColor,
    this.title,
    this.description,
    this.showSuffixIcon = true, // Default to true to match original
    this.isUrgent = false,
    this.horizontalOuterPadding,
    this.titleColor, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final Color defaultThemeColor = const Color(0xff6366F1);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalOuterPadding ?? 16 * s,
      ),
      child: BaseCard(
        horizontalPadding: 17 * s,
        verticalPadding: 17 * s,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: cardColor != null
              ? [
                  cardColor!.withValues(alpha: 0.06),
                  cardColor!.withValues(alpha: 0.02),
                ]
              : [
                  defaultThemeColor.withValues(alpha: 0.06),
                  defaultThemeColor.withValues(alpha: 0.02),
                ],
        ),
        borderColor:
            cardBorderColor ?? defaultThemeColor.withValues(alpha: 0.1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleIcon(
              height: 36 * s,
              width: 36 * s,
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
                        title ?? "AI INSIGHT",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: titleColor ?? defaultThemeColor,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isUrgent) ...[
                        SizedBox(width: 6 * s),
                        Container(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 4 * s),
                          height: 18 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xffEF4444,
                            ).withValues(alpha: 0.12), // Red for urgent
                            borderRadius: BorderRadius.circular(15 * s),
                          ),
                          child: Text(
                            "Urgent",
                            style: TextStyle(
                              fontSize: 9 * s,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffEF4444),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    description ??
                        "You earned +420 pts this week.\nEfficiency is up 12% from last week.",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: const Color(0xFFB0B0C0),
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showSuffixIcon)
              Icon(
                Icons.arrow_forward_ios,
                size: 16 * s,
                color: (cardBorderColor ?? defaultThemeColor).withValues(
                  alpha: 0.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

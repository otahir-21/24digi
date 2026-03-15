import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class SmartInsightCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String? description;
  final double? descriptionFontSize;
  final String? icon;
  final Color? cardColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? titleColor;
  final LinearGradient? cardGradient;
  final Color? descriptionColor;
  final Color? subTitleColor;
  final double? spaceBeforeDescription;
  final bool circularIcon;
  final Color? iconBgColor;
  final double? horizontalPadding;
  final double? verticalPadding;

  const SmartInsightCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.cardColor,
    this.borderColor,
    this.iconColor,
    this.titleColor,
    this.descriptionColor,
    this.subTitle,
    this.descriptionFontSize,
    this.cardGradient,
    this.subTitleColor,
    this.spaceBeforeDescription,
    this.circularIcon = false,
    this.iconBgColor,
    this.horizontalPadding,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      gradient: cardGradient,
      horizontalPadding: horizontalPadding ?? 17 * s,
      verticalPadding: verticalPadding ?? 17 * s,
      backgroundColor: cardColor,
      borderColor: borderColor,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              circularIcon
                  ? CircleIcon(
                      iconColor: iconColor,
                      backgroundColor: iconBgColor,
                      icon: icon ?? "assets/icons/starss.png",
                    )
                  : Image.asset(
                      icon ?? "assets/icons/starss.png",
                      color: iconColor,
                    ),
              SizedBox(width: 8 * s),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Color(0xffFBBF24),
                ),
              ),
            ],
          ),
          if (subTitle != null) ...[
            SizedBox(height: 7 * s),
            Text(
              subTitle ?? "",
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 19 * s,
                fontWeight: FontWeight.w500,
                color: subTitleColor ?? Color(0xffFFFFFF),
              ),
            ),
          ],
          SizedBox(height: spaceBeforeDescription ?? 7 * s),
          Text(
            description ?? "",
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              fontSize: descriptionFontSize ?? 12 * s,
              fontWeight: FontWeight.w500,
              color: descriptionColor ?? Color(0xffB0B0C0),
            ),
          ),
        ],
      ),
    );
  }
}

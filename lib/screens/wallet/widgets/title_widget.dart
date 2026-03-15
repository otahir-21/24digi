import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final double? titleFontSize;
  final String? subtitle;
  final String? badgeText;
  final String? badgeIcon;
  final Color? badgeColor;
  final VoidCallback? onBadgeTap;
  final CrossAxisAlignment titleCrossAxis;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool isSecure;
  final String? value;
  final Color? titleFontColor;
  final Color? valueFontColor;
  final double? valueFontSize;
  final double? spaceAboveSubtitle;


  const TitleWidget({
    super.key,
    this.title,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
    this.onBadgeTap,
    this.titleCrossAxis = CrossAxisAlignment.start,
    this.crossAxisAlignment,
    this.isSecure = false,
    this.titleFontSize,
    this.value, this.titleFontColor, this.valueFontColor, this.valueFontSize, this.spaceAboveSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final Color themeColor = badgeColor ?? const Color(0xffFBBF24);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        // Title and Subtitle Section
        Expanded(
          child: Column(
            crossAxisAlignment: titleCrossAxis,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: titleFontSize ?? 20 * s,
                    fontWeight: FontWeight.w500,
                    color: titleFontColor ??const Color(0xffFFFFFF),
                  ),
                ),
              SizedBox(height: spaceAboveSubtitle?? 0,),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff555568),
                  ),
                ),
            ],
          ),
        ),
        if (isSecure)
          Row(
            spacing: 8 * s,
            children: [
              Image.asset(
                "assets/icons/Lock2.png",
                color: Color(0xff00D4AA).withValues(alpha: 0.6),
                height: 11 * s,
              ),
              Text(
                "Secure",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: Color(0xff00D4AA).withValues(alpha: 0.6),
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        // Optional Badge/Chip Section
        if (badgeText != null)
          GestureDetector(
            onTap: onBadgeTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * s,
                vertical: 4 * s,
              ),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(color: themeColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeIcon != null) ...[
                    Image.asset(badgeIcon!, width: 12 * s, color: themeColor),
                    SizedBox(width: 4 * s),
                  ],
                  Text(
                    badgeText!,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: themeColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10 * s,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (value != null)
          Text(
            value ?? "",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color:valueFontColor?? Color(0xffFFFFFF),
              fontSize: valueFontSize?? 15 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

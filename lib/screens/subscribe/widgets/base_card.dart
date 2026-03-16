import 'package:flutter/material.dart';

import '../../recovery_ai/widgets/option_chip.dart';

class BaseCard extends StatelessWidget {
  final List<Color>? cardGradientColorList;
  final Color? cardBorderColor;
  final double? topBorderWidth;
  final String title;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? titleFontColor;
  final double? spaceBeforeDescription;
  final String? description;
  final double? descriptionFontSize;
  final Color? descriptionFontColor;
  final VoidCallback? descriptionOnCall;
  final String? status;
  final Color? statusBackgroundColor;
  final Color? statusBorderColor;
  final Color? statusFontColor;
  final double? statusFontSize;
  final Widget child;
  final bool bottomSpacing;
  final VoidCallback? statusOnTap;

  // New Prefix Icon properties
  final String? prefixIcon;
  final bool prefixIconWithBase;
  final Color? iconBgColor;
  final Color? iconBorderColor;
  final Gradient? iconGradient;
  final Color? iconImageColor;

  final String? titleTrailingIcon;
  final MainAxisSize? titleRowMainAxisSize;
  final double? iconBorderRadius;

  BaseCard({
    super.key,
    required this.title,
    required this.child,
    this.prefixIcon,
    this.description,
    this.status,
    this.iconBgColor,
    this.iconGradient,
    this.titleFontSize,
    this.titleFontWeight,
    this.statusBackgroundColor,
    this.statusBorderColor,
    this.statusFontColor,
    this.statusFontSize,
    this.cardGradientColorList,
    this.cardBorderColor,
    this.topBorderWidth,
    this.titleFontColor,
    this.prefixIconWithBase = true,
    this.bottomSpacing = true,
    this.iconBorderColor,
    this.descriptionFontColor,
    this.spaceBeforeDescription,
    this.descriptionOnCall,
    this.titleTrailingIcon, this.descriptionFontSize, this.iconImageColor, this.statusOnTap, this.titleRowMainAxisSize, this.iconBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 440;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 20 * s),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cardBorderColor ?? const Color(0xff1E2A3D),
            width: topBorderWidth ?? 1.25,
          ),
          bottom: BorderSide(
            color: cardBorderColor ?? const Color(0xff1E2A3D),
            width: 1.25,
          ),
          left: BorderSide(
            color: cardBorderColor ?? const Color(0xff1E2A3D),
            width: 1.25,
          ),
          right: BorderSide(
            color: cardBorderColor ?? const Color(0xff1E2A3D),
            width: 1.25,
          ),
        ),
        borderRadius: BorderRadius.circular(16 * s),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
          cardGradientColorList ??
              [
                const Color(0xff0F1520),
                const Color(0xff162032),
                const Color(0xff162032),
              ],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prefixIcon != null)
                prefixIconWithBase
                    ? Container(
                  width: 46.51 * s,
                  height: 46.51 * s,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: iconBorderColor ?? Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(iconBorderRadius ?? 14.8 * s),
                    color: iconBgColor,
                    gradient: iconGradient,
                  ),
                  // padding: const EdgeInsets.all(10),
                  child: Image.asset(prefixIcon ?? "", color: iconImageColor,),
                )
                    : Image.asset(prefixIcon ?? ""),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      mainAxisSize: titleRowMainAxisSize ?? MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: titleFontSize ?? 25 * s,
                              fontWeight: titleFontWeight ?? FontWeight.w500,
                              color: titleFontColor ?? Color(0xffffffff),
                            ),
                          ),
                        ),
                        if (titleTrailingIcon != null) ...[
                          SizedBox(width: 4 * s),
                          Image.asset(titleTrailingIcon!),
                        ],
                        if (status != null) ...[
                          OptionChip(

                            fontColor:
                            statusFontColor ?? const Color(0xffD4A574),
                            horizontalPadding: 6 * s,
                            fontWeight: FontWeight.w500,
                            fontSize: statusFontSize ?? 14 * s,
                            borderRadius: 100,
                            height: 26 * s,
                            backgroundColor:
                            statusBackgroundColor ??
                                const Color(0xffD4A574).withValues(
                                    alpha: 0.1),
                            borderColor:
                            statusBorderColor ??
                                const Color(0xffD4A574).withValues(
                                    alpha: 0.2),
                            title: status!,
                            isSelected: false,
                            onTap: statusOnTap ?? (){},
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      SizedBox(height: spaceBeforeDescription),
                      GestureDetector(
                        onTap: descriptionOnCall ?? () {},
                        child: Text(
                          description!,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: descriptionFontSize ?? 14.8 * s,
                            fontWeight: FontWeight.w500,
                            color: descriptionFontColor ?? Color(0xff7B8BA5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (bottomSpacing) SizedBox(height: 30 * s),
          child,
        ],
      ),
    );
  }
}

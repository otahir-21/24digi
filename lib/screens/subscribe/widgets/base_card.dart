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
  final Color? descriptionFontColor;
  final VoidCallback? descriptionOnCall;
  final String? status;
  final Color? statusBackgroundColor;
  final Color? statusBorderColor;
  final Color? statusFontColor;
  final double? statusFontSize;
  final Widget child;
  final bool bottomSpacing;

  // New Prefix Icon properties
  final String? prefixIcon;
  final bool prefixIconWithBase;
  final Color? iconBgColor;
  final Color? iconBorderColor;
  final Gradient? iconGradient;

  final String? titleTrailingIcon;

  const BaseCard({
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
    this.titleTrailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
        borderRadius: BorderRadius.circular(16),
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
                        width: 46.51,
                        height: 46.51,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: iconBorderColor ?? Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(14.8),
                          color: iconBgColor,
                          gradient: iconGradient,
                        ),
                        // padding: const EdgeInsets.all(10),
                        child: Image.asset(prefixIcon ?? ""),
                      )
                    : Image.asset(prefixIcon ?? ""),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            // overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: titleFontSize ?? 25,
                              fontWeight: titleFontWeight ?? FontWeight.w500,
                              color: titleFontColor ?? Color(0xffffffff),
                            ),
                          ),
                        ),
                        if (titleTrailingIcon != null) ...[
                          const SizedBox(width: 4),
                          Image.asset(titleTrailingIcon!),
                        ],
                        if (status != null) ...[
                          Spacer(),
                          OptionChip(
                            fontColor:
                                statusFontColor ?? const Color(0xffD4A574),
                            horizontalPadding: 6,
                            fontWeight: FontWeight.w500,
                            fontSize: statusFontSize ?? 14,
                            borderRadius: 100,
                            height: 26,
                            backgroundColor:
                                statusBackgroundColor ??
                                const Color(0xffD4A574).withValues(alpha: 0.1),
                            borderColor:
                                statusBorderColor ??
                                const Color(0xffD4A574).withValues(alpha: 0.2),
                            title: status!,
                            isSelected: false,
                            onTap: () {},
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: spaceBeforeDescription),
                    if (description != null)
                      GestureDetector(
                        onTap: descriptionOnCall ?? () {},
                        child: Text(
                          description!,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 14.8,
                            fontWeight: FontWeight.w500,
                            color: descriptionFontColor ?? Color(0xff7B8BA5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (bottomSpacing)
            const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}

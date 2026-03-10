import 'package:flutter/material.dart';

import '../../recovery_ai/widgets/option_chip.dart';

class ActiveSubscriptionCard extends StatelessWidget {
  final List<Color>? cardGradientColorList;
  final Color? cardBorderColor;
  final double? topBorderWidth;
  final String title;
  final String? price;
  final String? unit;
  final double? priceFontSize;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? titleFontColor;
  final double? spaceBeforeDescription;
  final String? plan;
  final Color? descriptionFontColor;
  final VoidCallback? descriptionOnCall;
  final String? status;
  final Color? statusBackgroundColor;
  final Color? statusBorderColor;
  final Color? statusFontColor;
  final double? statusFontSize;
  final bool bottomSpacing;

  // New Prefix Icon properties
  final String? prefixIcon;
  final bool prefixIconWithBase;
  final Color? iconBgColor;
  final Color? iconBorderColor;
  final Gradient? iconGradient;

  final String? nextPaymentDate;

  const ActiveSubscriptionCard({
    super.key,
    required this.title,
    this.prefixIcon,
    this.plan,
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
    this.price,
    this.unit,
    this.priceFontSize,
    this.nextPaymentDate,
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: titleFontSize ?? 16,
                              fontWeight: titleFontWeight ?? FontWeight.w500,
                              color: titleFontColor ?? Color(0xffE8ECF4),
                            ),
                          ),
                        ),
                        Text(
                          price ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: priceFontSize ?? 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffE8ECF4),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(height: spaceBeforeDescription),
                        if (plan != null)
                          GestureDetector(
                            onTap: descriptionOnCall ?? () {},
                            child: Text(
                              plan!,
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 14.8,
                                fontWeight: FontWeight.w500,
                                color:
                                    descriptionFontColor ?? Color(0xff7B8BA5),
                              ),
                            ),
                          ),
                        if (status != null) SizedBox(width: 6),
                        OptionChip(
                          fontColor: (status == "Trail") ? Color(0xffFFB900) : const Color(0xff00D492),
                          horizontalPadding: 6,
                          fontWeight: FontWeight.w500,
                          fontSize: statusFontSize ?? 12,
                          borderRadius: 100,
                          height: 21,
                          backgroundColor:
                          (status == "Trail") ? Color(0xffFFB900).withValues(alpha: 0.1)
                               : const Color(0xff00BC7D).withValues(alpha: 0.1),
                          borderColor: statusBorderColor,
                          title: "• ${status!}",
                          isSelected: false,
                          onTap: () {},
                        ),
                        Spacer(),
                        Text(
                          unit ?? "",
                          style: const TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff7B8BA5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsetsGeometry.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xff1E2A3D), width: 1.25),
              ),
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Next Payment:",
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 14.8,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff7B8BA5),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nextPaymentDate ?? "",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 14.8,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffE8ECF4),
                    ),
                  ),
                ),
                Image.asset("assets/icons/Settings.png"),
                SizedBox(width: 14),
                Image.asset("assets/icons/ArrowUpCircle.png"),
                SizedBox(width: 14),
                Image.asset("assets/icons/PauseCircle.png"),
                SizedBox(width: 14),
                Image.asset("assets/icons/XCircle.png"),
                SizedBox(width: 14),
                Image.asset("assets/icons/ChevronDown.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

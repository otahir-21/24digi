import 'package:flutter/material.dart';

import '../../recovery_ai/widgets/option_chip.dart';

class BundlesCard extends StatelessWidget {
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

  final String? bundleCategory1;
  final String? bundleCategory2;

  const BundlesCard({
    super.key,
    required this.title,
    this.description,
    this.status,
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

    this.descriptionFontColor,
    this.spaceBeforeDescription,
    this.descriptionOnCall,
     this.bundleCategory1,
     this.bundleCategory2,
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

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: titleFontSize ?? 16,
                  fontWeight: titleFontWeight ?? FontWeight.w500,
                  color: titleFontColor ?? Color(0xffE8ECF4),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  OptionChip(
                    fontColor: statusFontColor ?? const Color(0xff7B8BA5),
                    horizontalPadding: 6,
                    fontWeight: FontWeight.w500,
                    fontSize: statusFontSize ?? 12,
                    borderRadius: 100,
                    height: 18,
                    backgroundColor:
                        statusBackgroundColor ?? const Color(0xff1A2233),
                    borderColor: statusBorderColor ?? const Color(0xff1A2233),
                    title: bundleCategory1 ?? "",
                    isSelected: false,
                    onTap: () {},
                  ),
                  OptionChip(
                    fontColor: statusFontColor ?? const Color(0xff7B8BA5),
                    horizontalPadding: 6,
                    fontWeight: FontWeight.w500,
                    fontSize: statusFontSize ?? 12,
                    borderRadius: 100,
                    height: 18,
                    backgroundColor:
                        statusBackgroundColor ?? const Color(0xff1A2233),
                    borderColor: statusBorderColor ?? const Color(0xff1A2233),
                    title: bundleCategory2 ?? "",
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                description ?? "",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 14.8,
                  fontWeight: FontWeight.w500,
                  color: descriptionFontColor ?? Color(0xff7B8BA5),
                ),
              ),
              Text(
                "149 AED/mo",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 14.8,
                  fontWeight: FontWeight.w500,
                  color: descriptionFontColor ?? Color(0xff7B8BA5),
                ),
              ),
              OptionChip(
                fontColor: statusFontColor ?? const Color(0xff00D492),
                horizontalPadding: 6,
                fontWeight: FontWeight.w500,
                fontSize: statusFontSize ?? 12,
                borderRadius: 100,
                height: 26,
                backgroundColor:
                    statusBackgroundColor ??
                    const Color(0xffD4A574).withValues(alpha: 0.1),
                borderColor:
                    statusBorderColor ??
                    const Color(0xffD4A574).withValues(alpha: 0.2),
                title: status ?? "",
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

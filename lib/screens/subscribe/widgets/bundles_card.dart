import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import '../../recovery_ai/widgets/option_chip.dart';
import '../../recovery_ai/widgets/primary_button.dart';

class BundlesCard extends StatelessWidget {
  final Color? cardBorderColor;
  final String title;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? titleFontColor;
  final String? actualPrice;
  final Color? actualPriceFontColor;
  final Color? statusBackgroundColor;
  final Color? statusBorderColor;
  final Color? statusFontColor;
  final double? statusFontSize;
  final String? bundleCategory1;
  final String? bundleCategory2;
  final String? save;
  final String? newPrice;
  final bool isRecommended;

  const BundlesCard({
    super.key,
    required this.title,
    this.titleFontSize,
    this.titleFontWeight,
    this.statusBackgroundColor,
    this.statusBorderColor,
    this.statusFontColor,
    this.statusFontSize,
    this.cardBorderColor,
    this.titleFontColor,
    this.bundleCategory1,
    this.bundleCategory2,
    this.actualPriceFontColor,
    this.actualPrice,
    this.save,
    this.newPrice,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card Container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 20 * s),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  cardBorderColor ??
                  const Color(0xffD4A574).withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xffD4A574).withValues(alpha: 0.03),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                          fontSize: titleFontSize ?? 16 * s,
                          fontWeight: titleFontWeight ?? FontWeight.w500,
                          color: titleFontColor ?? const Color(0xffE8ECF4),
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      Row(
                        children: [
                          OptionChip(
                            fontColor:
                                statusFontColor ?? const Color(0xff7B8BA5),
                            horizontalPadding: 6 * s,
                            fontWeight: FontWeight.w500,
                            fontSize: statusFontSize ?? 12 * s,
                            borderRadius: 100,
                            height: 26 * s,
                            backgroundColor:
                                statusBackgroundColor ??
                                const Color(0xff1A2233),
                            borderColor:
                                statusBorderColor ?? const Color(0xff1A2233),
                            title: bundleCategory1 ?? "",
                            isSelected: false,
                            onTap: () {},
                          ),
                          SizedBox(width: 4 * s),
                          OptionChip(
                            fontColor:
                                statusFontColor ?? const Color(0xff7B8BA5),
                            horizontalPadding: 6 * s,
                            fontWeight: FontWeight.w500,
                            fontSize: statusFontSize ?? 12 * s,
                            borderRadius: 100,
                            height: 26 * s,
                            backgroundColor:
                                statusBackgroundColor ??
                                const Color(0xff1A2233),
                            borderColor:
                                statusBorderColor ?? const Color(0xff1A2233),
                            title: bundleCategory2 ?? "",
                            isSelected: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          actualPrice ?? "",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: const Color(0xff7b8ba5),
                            decorationThickness: 2,
                            fontFamily: "HelveticaNeue",
                            fontSize: 14.8 * s,
                            fontWeight: FontWeight.w500,
                            color:
                                actualPriceFontColor ?? const Color(0xff7B8BA5),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 16.92 * s,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: newPrice,
                                style: TextStyle(
                                  color: const Color(0xffffffff),
                                ),
                              ),
                              TextSpan(
                                text: " AED/mo",
                                style: TextStyle(
                                  fontSize: 14.8 * s,
                                  color: const Color(0xff7B8BA5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10 * s),
                        OptionChip(
                          fontColor: statusFontColor ?? const Color(0xff00D492),
                          horizontalPadding: 6 * s,
                          fontWeight: FontWeight.w500,
                          fontSize: statusFontSize ?? 12 * s,
                          borderRadius: 100,
                          height: 26 * s,
                          backgroundColor:
                              statusBackgroundColor ??
                              const Color(0xff00BC7D).withValues(alpha: 0.1),
                          borderColor:
                              statusBorderColor ??
                              const Color(0xff00BC7D).withValues(alpha: 0.2),
                          title: save ?? "",
                          isSelected: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * s),
              PrimaryButton(
                onTap: () {},
                title: "Upgrade to Bundle \u2794",
                isGradient: true,
                gradientColorList: const [Color(0xffD4A574), Color(0xffC08B5C)],
                height: 42 * s,
                fontSize: 14 * s,
                fontWeight: FontWeight.w500,
                fontColor: const Color(0xff080C14),
                borderColor: const Color(0xffd4a574),
              ),
            ],
          ),
        ),

        // Recommended Tag
        if (isRecommended)
          Positioned(
            top: -9.32 * s,
            left: 18.16 * s,
            child: Container(
              // width: 122.38 * s,
              height: 21.14 * s,
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(41878068),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffD4A574), Color(0xffC08B5C)],
                ),
              ),
              child: Row(
                children: [
                  Image.asset("assets/icons/BadgeCheck.png"),
                  Text(
                    "Recommended",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontWeight: FontWeight.w500,
                      fontSize: 12 * s,
                      color: const Color(0xff080C14),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

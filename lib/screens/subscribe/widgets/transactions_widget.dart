import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import '../../recovery_ai/widgets/option_chip.dart';

class TransactionsWidget extends StatelessWidget {
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
  final VoidCallback? downloadOnTap;
  final VoidCallback? statusOnTap;
  final String? billAmount;

  const TransactionsWidget({
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
    this.cardBorderColor,
    this.topBorderWidth,
    this.titleFontColor,
    this.descriptionFontColor,
    this.spaceBeforeDescription,
    this.descriptionOnCall,
    this.descriptionFontSize,
    this.statusOnTap,
    this.downloadOnTap, this.billAmount,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 20 * s),
      decoration: BoxDecoration(
        border: Border.all(
          color: cardBorderColor ?? Colors.transparent,
          width: 1.25,
        ),
        borderRadius: BorderRadius.circular(16 * s),
        color: Colors.transparent,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: titleFontSize ?? 14 * s,
                                fontWeight: titleFontWeight ?? FontWeight.w500,
                                color: titleFontColor ?? Color(0xffE8ECF4),
                              ),
                            ),
                            if (description != null)
                              GestureDetector(
                                onTap: descriptionOnCall ?? () {},
                                child: Text(
                                  description!,
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: descriptionFontSize ?? 12.69 * s,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        descriptionFontColor ??
                                        Color(0xff7B8BA5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Spacer(),
                        if (status != null) ...[
                          OptionChip(
                            fontColor:
                                statusFontColor ?? const Color(0xff00D492),
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
                                const Color(0xff00BC7D).withValues(alpha: 0.1),
                            title: "• ${status!}",
                            isSelected: false,
                            onTap: statusOnTap ?? () {},
                          ),
                        ],
                        SizedBox(width: 14 * s,),
                        Text(
                          billAmount ?? " ",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: titleFontSize ?? 14 * s,
                            fontWeight: titleFontWeight ?? FontWeight.w500,
                            color: titleFontColor ?? Color(0xffE8ECF4),
                          ),
                        ),
                        SizedBox(width: 14 * s,),
                        GestureDetector(
                          onTap: downloadOnTap,
                          child: Image.asset("assets/icons/Download.png"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

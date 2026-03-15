import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/widgets/sub_card_base.dart';

class SubscriptionDetailsCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool showTitleBelow;
  final String detail;
  final String? unit;
  final double? detailsFontSize;

  const SubscriptionDetailsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.unit,
    this.detailsFontSize,
    this.showTitleBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return SubCardBase(
      horizontalPadding: 13 * s,
      verticalPadding: 13 * s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(icon, width: 20 * s, height: 20* s),
               SizedBox(width: 8 * s),
              if (!showTitleBelow)
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff7B8BA5),
                    ),
                  ),
                ),
            ],
          ),
          if (showTitleBelow)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: Color(0xff7B8BA5),
              ),
            ),
          SizedBox(height: 10 * s),

          Row(
            spacing: 12 * s,
            children: [
              Expanded(
                child: Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: detailsFontSize  ?? 24 * s,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffE8ECF4),
                  ),
                ),
              ),
              Text(
                unit ?? "",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff7B8BA5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

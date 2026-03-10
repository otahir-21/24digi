import 'package:flutter/material.dart';
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
    return SubCardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: 8),
              if (!showTitleBelow)
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 15,
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
              style: const TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff7B8BA5),
              ),
            ),
          const SizedBox(height: 10),

          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: detailsFontSize ?? 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffE8ECF4),
                  ),
                ),
              ),
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
    );
  }
}

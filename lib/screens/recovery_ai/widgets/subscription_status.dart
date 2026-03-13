import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final String status;
  final String painAccess;
  final String periodEnd;
  final String message;

  const SubscriptionStatusWidget({
    super.key,
    required this.status,
    required this.painAccess,
    required this.periodEnd,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
     TextStyle labelStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontWeight: FontWeight.w500,
      fontSize: 14  * s,
      color: Color(0xffA8B3BA),
    );

      TextStyle valueStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontWeight: FontWeight.w500,
      fontSize: 14 * s,
      color: Color(0xffEAF2F5),
    );

    return Container(
      padding:   EdgeInsets.symmetric(horizontal: 10* s, vertical: 15 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25 * s),
        color: const Color(0xff151B20).withOpacity(0.4),
        border: Border.all(
          color: const Color(0xffA8B3BA).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status", style: labelStyle),
                  SizedBox(height: 10 * s),
                  Text("Pain access", style: labelStyle),
                  SizedBox(height: 10* s),
                  Text("Period end", style: labelStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(status, style: valueStyle),
                    SizedBox(height: 10 * s),
                  Text(painAccess, style: valueStyle),
                    SizedBox(height: 10* s),
                  Text(periodEnd, style: valueStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: 15* s),
          Text(message, style: labelStyle),
        ],
      ),
    );
  }
}

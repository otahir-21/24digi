import 'package:flutter/material.dart';

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
    const TextStyle labelStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Color(0xffA8B3BA),
    );

    const TextStyle valueStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Color(0xffEAF2F5),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status", style: labelStyle),
                  SizedBox(height: 10),
                  Text("Pain access", style: labelStyle),
                  SizedBox(height: 10),
                  Text("Period end", style: labelStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(status, style: valueStyle),
                  const SizedBox(height: 10),
                  Text(painAccess, style: valueStyle),
                  const SizedBox(height: 10),
                  Text(periodEnd, style: valueStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(message, style: labelStyle),
        ],
      ),
    );
  }
}

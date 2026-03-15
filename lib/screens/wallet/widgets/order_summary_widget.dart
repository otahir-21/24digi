import 'package:flutter/material.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';

class OrderSummaryWidget extends StatelessWidget {
  const OrderSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.27 * s,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TitleWidget(title: "Order Summary", titleFontSize: 15 * s),
          SizedBox(height: 16 * s),
          TitleWidget(
            title: "Points",
            titleFontSize: 15 * s,
            titleFontColor: Color(0xff8888A0),
            value: "2,500 PTS",
          ),
          SizedBox(height: 12 * s),
          TitleWidget(
            title: "Bonus Points",
            titleFontSize: 15 * s,
            titleFontColor: Color(0xff8888A0),
            value: "+250 PTS",
            valueFontColor: Color(0xffFBBF24),
          ),
          SizedBox(height: 12 * s),
          TitleWidget(
            title: "Payment Method",
            titleFontSize: 15 * s,
            titleFontColor: Color(0xff8888A0),
            value: "Visa • 4892",
          ),
          SizedBox(height: 12 * s),
          /// DIVIDER
          Container(height: 1, color: Colors.white.withOpacity(0.06)),
          SizedBox(height: 12 * s),
          TitleWidget(
            title: "Total",
            titleFontSize: 15 * s,
            value: "2225.00 AED",
            valueFontSize: 19 * s,
          )
        ],
      ),
    );
  }
}

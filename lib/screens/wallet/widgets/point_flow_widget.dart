import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/labe_widet.dart';
import 'package:kivi_24/screens/wallet/widgets/period_toggle_button.dart';
import 'package:kivi_24/screens/wallet/widgets/point_flow_graph.dart';

class PointFlowWidget extends StatelessWidget {
  const PointFlowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      backgroundColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
      horizontalPadding: 18 * s,
      verticalPadding: 23 * s,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                 "Point Flow",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffFFFFFF),
                ),
              ),
              PeriodToggleButton()
            ],
          ),
          SizedBox(
              height: 200 * s,
              child: PointFlowGraph()),
        ],
      ),
    );
  }
}

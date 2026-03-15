import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controller/wallet_analytics_controller.dart';

class PointSourcesGraph extends StatelessWidget {
  const PointSourcesGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final WalletAnalyticsController controller =
        Get.find<WalletAnalyticsController>();

    return SfCircularChart(
      margin: EdgeInsets.zero,
      // Optional: Add a legend
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,

        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(
          fontFamily: "HelveticaNeue",
          fontSize: 12 * s,
          color: const Color(0xffA8B3BA),
        ),
      ),
      // Middle text using annotations
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: SizedBox()
        ),
      ],
      series: <CircularSeries<DoughnutData, String>>[
        DoughnutSeries<DoughnutData, String>(
          dataSource: controller.doughnutStats,
          xValueMapper: (DoughnutData data, _) => data.category,
          yValueMapper: (DoughnutData data, _) => data.value,
          pointColorMapper: (DoughnutData data, _) => data.color,
          innerRadius: '65%',
          strokeColor: Color(0xff0E1215),
          // Size of the hollow center
          radius: '80%',
          enableTooltip: false,
        ),
      ],
    );
  }
}

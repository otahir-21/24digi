import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/wallet_analytics_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class PointFlowGraph extends StatelessWidget {
  const PointFlowGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final  controller = Get.find<WalletAnalyticsController>();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,

      // X-Axis (Days) - Made transparent
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0), // Transparent horizontal bar
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(
          fontFamily: "HelveticaNeue",
          color: const Color(0xffA8B3BA),
          fontSize: 12 * s,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Y-Axis (Hidden for clean look)
      primaryYAxis: const NumericAxis(
        isVisible: false,
        majorGridLines: MajorGridLines(width: 0),
      ),

      // Series Mapping
      series: <CartesianSeries>[
        // Earned Column (Green)
        ColumnSeries<HeroChartData, String>(
          dataSource: controller.weeklyStats,
          xValueMapper: (HeroChartData data, _) => data.day,
          yValueMapper: (HeroChartData data, _) => data.earned,
          color: const Color(0xff6366F1),
          borderRadius: BorderRadius.circular(4 * s),
          width: 0.8  , // Width of individual bar
          spacing: 0.1, // Gap between the two bars of the same day
        ),

        // Spent Column (Pink)
        ColumnSeries<HeroChartData, String>(
          dataSource: controller.weeklyStats,
          xValueMapper: (HeroChartData data, _) => data.day,
          yValueMapper: (HeroChartData data, _) => data.spent,
          color: const Color(0xff00D4AA),
          borderRadius: BorderRadius.circular(4 * s),
          width: 0.8 ,
          spacing: 0.2,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import 'base_card.dart';
import 'bundles_card.dart';

class BundleAndSavings extends StatelessWidget {
  const BundleAndSavings({super.key});

  @override
  Widget build(BuildContext context) {
    final s= UIScale.of(context);
    return BaseCard(
      cardBorderColor: Color(0xff1E2A3D),
      cardGradientColorList: [
        Color(0xff0F1520),
        Color(0xff0F1520),
      ],
      title: "Bundles & Savings",
      titleFontSize: 19 * s,
      titleFontColor: Color(0xffE8ECF4),
      description: "Save more by combining your subscriptions",
      descriptionFontSize: 14 * s,
      titleTrailingIcon: "assets/icons/Gift.png",
      titleRowMainAxisSize: MainAxisSize.min,
      child: Column(
        spacing: 16,
        children: [
          BundlesCard(
            title: "24DIGI Premium bundle",
            bundleCategory1: "C By AI",
            bundleCategory2: "AI Models",
            actualPrice: "219.96 AED",
            newPrice: "149.99",
            save: "Save 32%",
            isRecommended: true,
          ),
          BundlesCard(
            title: "Health + AI Pack",
            bundleCategory1: "24Diet",
            bundleCategory2: "SafeLife",
            actualPrice: "199.99 AED",
            newPrice: "89.99",
            save: "Save 31%",
          ),
        ],
      ),
    );
  }
}

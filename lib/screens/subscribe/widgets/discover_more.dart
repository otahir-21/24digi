import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/widgets/base_card.dart';
import 'package:kivi_24/screens/subscribe/widgets/recomendations_widget.dart';

class DiscoverMore extends StatelessWidget {
  const DiscoverMore({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      cardBorderColor: Color(0xff1E2A3D),
      cardGradientColorList: [Color(0xff0F1520), Color(0xff0F1520)],
      title: "Discover More",
      titleFontSize: 19 * s,
      titleFontColor: Color(0xffE8ECF4),
      descriptionFontSize: 14 * s,
      description: "Personalized recommendations based on your activity",
      titleTrailingIcon: "assets/icons/Compass.png",
      titleRowMainAxisSize: MainAxisSize.min,
      child: Column(
        spacing: 12,
        children: [
          RecommendationsWidget(
            iconPath: "assets/icons/Vector (2).png",
            title: "24Shop Premium",
            description: "Priority shipping, exclusive deals & AI shopping assistant",
            price: "29.99",
            message: "Based on your purchase history, you'd save ~92 AED",
          ),
          RecommendationsWidget(
            iconGradientColorList: [
              Color(0xff0092B8),
              Color(0xff00786F),
            ],
            iconPath: "assets/icons/IconComp.png",
            title: "Delivery Plus",
            description: "Unlimited free delivery on all 24DIGI services",
            price: "18.99",
            message: "You ordered 8 times this month — Delivery Plus would be free.",
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.title,
    required this.duration,
    required this.price,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    TextStyle subTextStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 18 * s,
      fontWeight: FontWeight.w500,
      color: Color(0xffA8B3BA),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 20 * s),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xffC084FC)
                : const Color(0xffA8B3BA),
            width: isSelected ? 1.0 : 0.2,
          ),
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xff0E1215).withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 24 * s,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffC084FC),
                  ),
                ),
                Image.asset(
                  "assets/icons/check_point.png",
                  width: 24 * s,
                  height: 24 * s,
                  color: const Color(0xffC084FC),
                ),
              ],
            ),

            SizedBox(height: 8 * s),

            Row(children: [Text("$duration . $price", style: subTextStyle)]),

             SizedBox(height: 16 * s),

            ...features.map(
              (feature) => Padding(
                padding:  EdgeInsets.only(bottom: 6.0 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("• ", style: subTextStyle), // Small dot
                    Expanded(child: Text(feature, style: subTextStyle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

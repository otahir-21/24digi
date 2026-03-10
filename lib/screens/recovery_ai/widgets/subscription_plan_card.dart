import 'package:flutter/material.dart';

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
    const TextStyle subTextStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xffA8B3BA),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xffC084FC) : const Color(0xffA8B3BA),
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
                  style: const TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffC084FC),
                  ),
                ),
                Image.asset(
                  "assets/icons/check_point.png",
                  width: 24,
                  height: 24,
                  color: const Color(0xffC084FC),
                )
              ],
            ),

            const SizedBox(height: 8),

            /// Price and Duration Line
            Row(
              children: [
                Text("$duration . $price", style: subTextStyle),
              ],
            ),

            const SizedBox(height: 16),

            /// Features List
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: subTextStyle), // Small dot
                  Expanded(
                    child: Text(feature, style: subTextStyle),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

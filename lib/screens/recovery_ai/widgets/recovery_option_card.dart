import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class RecoveryOptionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String heading;
  final String description;
  final String value; // Unique ID for this card (e.g., "option1")
  final RxString selectedValue; // The observable from your controller
  final VoidCallback onTap;

  const RecoveryOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.heading,
    required this.description,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
         final bool isSelected = selectedValue.value == value;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 20 * s),
          decoration: BoxDecoration(
             border: Border.all(
              color: isSelected ? const Color(0xFFC084FC) : const Color(0xffA8B3BA),
              width: isSelected ? 1.5 * s : 0.2 * s,
            ),
            borderRadius: BorderRadius.circular(25 * s),
            color: const Color(0xff0E1215).withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        icon,
                        width: 20 * s,
                        height: 20 * s,
                        // Optional: Tint icon purple when selected
                        color: isSelected ? const Color(0xFFC084FC) : null,
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ],
                  ),
                  // Checkmark changes color or visibility
                  Image.asset(
                    "assets/icons/check_point.png",
                    width: 24 * s,
                    height: 24 * s,
                    color: isSelected ? const Color(0xFFC084FC) : const Color(0xffA8B3BA),
                  )
                ],
              ),
              SizedBox(height: 10 * s),

              /// Heading
              Text(
                heading,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffC084FC),
                ),
              ),
              SizedBox(height: 6 * s),

              /// Description
              Text(
                description,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffA8B3BA),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

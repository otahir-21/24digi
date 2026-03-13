import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class GenderWidget extends StatelessWidget {
  final String image;
  final RxString selectedGender;
  final String value;
  final VoidCallback onTap;

  const GenderWidget({
    super.key,
    required this.image,
    required this.selectedGender,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        // Check if this specific widget is selected
        bool isSelected = selectedGender.value == value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Border Container
            Container(
              width: 100 * s,
              height: 100 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Switch between Solid Purple and Gradient
                color: isSelected ? const Color(0xFF9F0AD6) : null,
                gradient: isSelected
                    ? null
                    : LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF9F0AD6).withValues(alpha: 0.4),
                    const Color(0xff8C0DDC).withValues(alpha: 0.4),
                    const Color(0xFF2BCCDE).withValues(alpha: 0.4),
                    const Color(0xFF307ED8).withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            // Inner Black Gap
            Container(
              width: 94 * s,
              height: 94 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.92),
              ),
            ),
            // Image Container
            Container(
              width: 86 * s, // Slightly smaller to show the border better
              height: 86 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x4D060B3D),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

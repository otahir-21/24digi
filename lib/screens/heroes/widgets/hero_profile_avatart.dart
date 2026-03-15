import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class HeroProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onBackTap;

  const HeroProfileAvatar({
    super.key,
    required this.imageUrl,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final double avatarSize = 160 * s; // Radius 80 * 2

    return Stack(
      alignment: Alignment.center,
      children: [
        Stack(
          children: [
            Align(
              alignment: const Alignment(-0.1, 0.0),
              child: Container(
                width: avatarSize + 50,
                height: avatarSize + 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      const Color(0xffE3B427).withValues(alpha: 0.6),
                      const Color(0xffE3B427).withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            // Blue Radial (Right side)
            Align(
              alignment: const Alignment(0.1, 0),
              child: Container(
                width: avatarSize + 50,
                height: avatarSize + 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      const Color(0xff2F3DD9).withValues(alpha: 0.9),
                      const Color(0xff2F3DD9).withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 2. The Main Profile Image
        CircleAvatar(
          radius: 90 * s,
          backgroundColor: const Color(0xff151B20), // Dark base color
          child: ClipOval(
            child: Image.asset(
              imageUrl,
              width: 190 * s,
              height: 190 * s,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

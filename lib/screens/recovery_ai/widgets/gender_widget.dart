import 'package:flutter/material.dart';

class GenderWidget extends StatelessWidget {
  final String image;
  const GenderWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: AlignmentGeometry.bottomCenter,
              end: AlignmentGeometry.topCenter,
              colors: [
                const Color(0xFF9F0AD6).withValues(alpha: 0.4),
                const Color(0xff8C0DDC).withValues(alpha: 0.4),
                const Color(0xFF2BCCDE).withValues(alpha: 0.4),
                const Color(0xFF307ED8).withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.92)
          ),
        ),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Your specific background color #060B3D4D
            color: const Color(0x4D060B3D),
            image: DecorationImage(
              image: AssetImage(image),
              // THIS IS THE KEY: 'contain' ensures the whole image is visible
              // 'cover' fills the circle but might crop the edges
              fit: BoxFit.contain,
            ),
          ),
        ),
        //
        // CircleAvatar(
        //   backgroundColor: Color(0xff060B3D).withValues(alpha: 0.3),
        //   radius: 47, // Diameter of 50
        //   backgroundImage: AssetImage(
        //     "assets/fonts/male.png",
        //   ),
        // ),
      ],
    )
    ;
  }
}

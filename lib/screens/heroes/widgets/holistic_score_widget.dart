import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class HolisticScoreWidget extends StatelessWidget {
  final String score;
  final String label;

  const HolisticScoreWidget({
    super.key,
    this.score = "98%",
    this.label = "HOLISTIC SCORE",
  });

  @override
  Widget build(BuildContext context) {
final s = UIScale.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. The Base Image
        Image.asset(
          "assets/images/holistic_score.png",
          width: 394 * s,
          height: 394 * s,
          // fit: BoxFit.contain,
        ),

        // 2. The Overlay Container to cover and replace text
        Container(
          width: 200 * s, // Sufficient width to cover original text
          height: 200 * s, // Sufficient height to cover original text
          decoration: const BoxDecoration(
            color: Color(0xff0E1215),
            shape: BoxShape.circle
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dynamic Score Text
              Text(
                score,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 40 * s,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffEAF2F5),
                ),
              ),
              SizedBox(height: 8 * s),
              // Dynamic Label Text
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "HelveticaNeueLight",
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffEAF2F5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

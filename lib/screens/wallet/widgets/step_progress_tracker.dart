import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class StepProgressTracker extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-indexed (e.g., 1, 2, or 3)

  const StepProgressTracker({
    super.key,
    this.totalSteps = 3,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    const Color brandColor = Color(0xff00D4AA);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(totalSteps, (index) {
        int stepNumber = index + 1;
        bool isCompleted = stepNumber < currentStep;
        bool isActive = stepNumber == currentStep;
        bool isLast = index == totalSteps - 1;

        return Row(
          children: [
            // Step Circle
            Container(
              width: 28 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? brandColor
                    : isActive
                    ? brandColor.withValues(alpha: 0.2)
                    : Color(0xffFFFFFF).withValues(alpha: 0.04),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.black, size: 16 * s)
                    : Text(
                        "$stepNumber",
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.black
                              : isActive
                              ? brandColor
                              : Color(0xff555568),
                          fontWeight: FontWeight.bold,
                          fontSize: 14 * s,
                        ),
                      ),
              ),
            ),

            // Connecting Line
            if (!isLast)
              Container(
                margin: EdgeInsetsGeometry.symmetric(horizontal: 8 * s),
                width: 95 * s,
                height: 1.08 * s,
                color: isCompleted
                    ? brandColor.withValues(alpha: 0.3)
                    : Color(0xff555568),
              ),
          ],
        );
      }),
    );
  }
}

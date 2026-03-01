import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'language_slider.dart';

/// The back-arrow + step-progress-bar row used at the top of every setup
/// screen (step 2 through 6). Pass [filledCount] to control how many
/// segments are lit cyan.
///
/// ```dart
/// SetupTopBar(s: s, filledCount: 1), // step 2 — 1 of 5 filled
/// SetupTopBar(s: s, filledCount: 3), // step 4 — 3 of 5 filled
/// ```
class SetupTopBar extends StatelessWidget {
  final double s;
  final int filledCount;
  final int totalSteps;

  const SetupTopBar({
    super.key,
    required this.s,
    required this.filledCount,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF00F0FF),
                size: 24 * s,
              ),
            ),
            const LanguageSlider(),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          children: List.generate(totalSteps, (i) {
            final isFilled = i < filledCount;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < totalSteps - 1 ? 6 * s : 0),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _StepSegmentPainter(isFilled: isFilled, s: s),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepSegmentPainter extends CustomPainter {
  final bool isFilled;
  final double s;
  _StepSegmentPainter({required this.isFilled, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFilled
          ? const Color(0xFF00F0FF)
          : const Color(0xFF26313A).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const h = 4.0;
    final path = Path();
    // Angled segment shape: /__/
    path.moveTo(6 * s, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 6 * s, h * s);
    path.lineTo(0, h * s);
    path.close();

    canvas.drawPath(path, paint);

    if (isFilled) {
      // Glow effect for filled steps
      final glowPaint = Paint()
        ..color = const Color(0xFF00F0FF).withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * s);
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A compact info/description box used below the title on each setup screen.
///
/// ```dart
/// InfoBox(s: s, text: 'Help our AI…'),
/// ```
class InfoBox extends StatelessWidget {
  final double s;
  final String text;

  const InfoBox({super.key, required this.s, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * s),
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12 * s,
          fontWeight: FontWeight.w300,
          color: AppColors.labelDim,
          height: 1.5,
        ),
      ),
    );
  }
}

/// A section-label text widget. Replaces the repeated `_sectionLabel()` helper
/// defined locally in most setup screens.
///
/// ```dart
/// SectionLabel(s: s, text: 'Activity Level'),
/// ```
class SectionLabel extends StatelessWidget {
  final double s;
  final String text;

  const SectionLabel({super.key, required this.s, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15 * s,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

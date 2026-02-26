import 'package:flutter/material.dart';
import '../core/app_constants.dart';

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

  /// Number of cyan (filled) segments — should match the step index.
  final int filledCount;

  /// Total number of segments. Defaults to 5.
  final int totalSteps;

  const SetupTopBar({
    super.key,
    required this.s,
    required this.filledCount,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.cyan,
            size: 20 * s,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Row(
            children: List.generate(totalSteps, (i) {
              return Expanded(
                child: Container(
                  height: 3 * s,
                  margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 * s : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2 * s),
                    color: i < filledCount
                        ? AppColors.cyan
                        : AppColors.trackInactive,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
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
      padding: EdgeInsets.symmetric(
        horizontal: 14 * s,
        vertical: 8 * s,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * s),
        color: AppColors.surfaceCard,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 1,
        ),
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

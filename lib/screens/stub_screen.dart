import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_constants.dart';
import '../widgets/digi_background.dart';

/// Reusable placeholder screen for pages not yet implemented.
/// Each named page (Bracelet, Diet, etc.) is a thin wrapper around this.
class StubScreen extends StatelessWidget {
  final String title;
  final Color? accent;

  const StubScreen({
    super.key,
    required this.title,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / AppConstants.figmaW;
    final color = accent ?? AppColors.cyan;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DigiBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20 * s, vertical: 16 * s),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: color, size: 20 * s),
                    ),
                    SizedBox(width: 12 * s),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'LemonMilk',
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Coming soon
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.construction_rounded,
                          color: color.withAlpha(120), size: 56 * s),
                      SizedBox(height: 16 * s),
                      Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w400,
                          color: color,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

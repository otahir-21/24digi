import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'diet_home_screen.dart';

class DietWelcomeScreen extends StatelessWidget {
  const DietWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/diet/diet_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay for better contrast
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: .3)),
          ),

          // Main Card
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 340 * s,
                  maxHeight: 520 * s,
                ),
                child: CustomPaint(
                  painter: _DietCardBorderPainter(s: s),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36 * s),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .4),
                          borderRadius: BorderRadius.circular(36 * s),
                        ),
                        child: Stack(
                          children: [
                            // Top glow gradient
                            Positioned(
                              top: -50 * s,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 250 * s,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.topCenter,
                                    radius: 1.0,
                                    colors: [
                                      const Color(
                                        0xFFFACC15,
                                      ).withValues(alpha: .3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Bottom glow gradient
                            Positioned(
                              bottom: -50 * s,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 250 * s,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.bottomCenter,
                                    radius: 1.0,
                                    colors: [
                                      const Color(
                                        0xFF991B1B,
                                      ).withValues(alpha: .2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Content
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 60 * s),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Welcome to',
                                      style: GoogleFonts.inter(
                                        fontSize: 22 * s,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white.withValues(
                                          alpha: .85,
                                        ),
                                        letterSpacing: 1.2 * s,
                                      ),
                                    ),
                                    Text(
                                      '24 DIET',
                                      style: TextStyle(
                                        fontFamily: 'LemonMilk',
                                        fontSize: 54 * s,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.5 * s,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DietHomeScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'CONTINUE',
                                        style: TextStyle(
                                          fontFamily: 'LemonMilk',
                                          fontSize: 20 * s,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DietCardBorderPainter extends CustomPainter {
  final double s;
  _DietCardBorderPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(36 * s));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = const SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 3.14159 * 2,
        colors: [
          Color(0xFF6FFFE9), // Cyan
          Color(0xFFC084FC), // Purple
          Color(0xFFFF3582), // Pink/Magenta
          Color(0xFFFACC15), // Yellow/Orange
          Color(0xFF6FFFE9), // Back to Cyan
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

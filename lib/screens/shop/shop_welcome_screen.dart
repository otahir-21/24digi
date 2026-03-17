import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'shop_gender_screen.dart';

class ShopWelcomeScreen extends StatelessWidget {
  const ShopWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/shop/shop_background.png', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                Expanded(child: Center(child: _buildGlassCard(context, s))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, double s) {
    return Container(
      width: 300 * s,
      height: 480 * s,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24 * s)),
      child: CustomPaint(
        painter: _ShopGradientBorderPainter(radius: 24 * s, strokeWidth: 3 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24 * s),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF00F0FF),
                    ),
                  ),
                  SizedBox(height: 40 * s),
                  _buildNeonTitle(s),
                  SizedBox(height: 80 * s),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShopGenderScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32 * s,
                        vertical: 12 * s,
                      ),
                      child: Text(
                        'CONTINUE',
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonTitle(double s) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Text(
          '24 SHOP',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 42 * s,
            fontWeight: FontWeight.w800,
            color: Colors.transparent,
            height: 1.3,
            shadows: [
              Shadow(color: const Color(0xFF00F0FF), blurRadius: 20 * s),
              Shadow(color: const Color(0xFFFF2E93), blurRadius: 40 * s),
            ],
          ),
        ),
        // Solid fill
        Text(
          '24 SHOP',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 42 * s,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _ShopGradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;

  _ShopGradientBorderPainter({required this.radius, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00F0FF), // Cyan
          Color(0xFFFF2E93), // Pink
          Color(0xFF00F0FF),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

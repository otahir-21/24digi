import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Figma CSS (exact) ────────────────────────────────────────────────────────
// background:
//   radial-gradient(90.16% 143.01% at 15.32% 21.04%,
//     rgba(51,255,232,0.1) 0%, rgba(110,191,244,0.0224) 77.08%, rgba(70,144,213,0) 100%),
//   radial-gradient(52.8% 82.5% at 50% 50%,
//     rgba(147,19,98,0) 0%, rgba(191,26,131,0.022) 64.9%, rgba(229,32,161,0.1) 100%),
//   linear-gradient(0deg, rgba(24,34,43,0.1), rgba(24,34,43,0.1));
//
// border: 2px solid — border-image-source:
//   radial-gradient(80.38% 222.5% at -13.75% -12.36%, #00F0FF 0%, transparent 100%),
//   radial-gradient(80.69% 208.78% at 108.28% 112.58%, #CE6AFF 0%, rgba(135,38,183,0) 100%);
//
// backdrop-filter: blur(80px);
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double borderWidth;
  final double blurSigma;
  final Widget child;

  const GlassCard({
    super.key,
    required this.width,
    required this.height,
    this.radius = 40,
    this.borderWidth = 2,
    this.blurSigma = 80,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // ── Gradient border ──
          Positioned.fill(
            child: CustomPaint(
              painter: _GradientBorderPainter(
                radius: radius,
                strokeWidth: borderWidth,
              ),
            ),
          ),

          // ── Card fill + backdrop blur (inset by border width) ──
          Positioned(
            top: borderWidth,
            left: borderWidth,
            right: borderWidth,
            bottom: borderWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - borderWidth),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Stack(
                  children: [
                    // Layer 1 — linear base: rgba(24, 34, 43, 0.1)
                    Positioned.fill(
                      child: Container(
                        color: const Color.fromRGBO(24, 34, 43, 0.1),
                      ),
                    ),

                    // Layer 2 — radial-gradient(90.16% 143.01% at 15.32% 21.04%, ...)
                    // CSS 15.32% 21.04% → Flutter Alignment(-0.694, -0.579)
                    Positioned.fill(
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(-0.694, -0.579),
                            radius: 1.55,
                            colors: [
                              Color.fromRGBO(51, 255, 232, 0.10),
                              Color.fromRGBO(110, 191, 244, 0.0224),
                              Color.fromRGBO(70, 144, 213, 0.0),
                            ],
                            stops: [0.0, 0.7708, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Layer 3 — radial-gradient(52.8% 82.5% at 50% 50%, ...)
                    // CSS 50% 50% → Flutter Alignment(0, 0)
                    Positioned.fill(
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0.0, 0.0),
                            radius: 1.0,
                            colors: [
                              Color.fromRGBO(147, 19, 98, 0.0),
                              Color.fromRGBO(191, 26, 131, 0.022),
                              Color.fromRGBO(229, 32, 161, 0.10),
                            ],
                            stops: [0.0, 0.649, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned.fill(child: child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Border painter ───────────────────────────────────────────────────────────
// Radial 1: 80.38% 222.5% at -13.75% -12.36% → #00F0FF → transparent (top-left)
// Radial 2: 80.69% 208.78% at 108.28% 112.58% → #CE6AFF → transparent (bottom-right)
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;

  const _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Radial 1 — top-left: #00F0FF (cyan) → transparent
    paint.shader = RadialGradient(
      center: const Alignment(-1.275, -1.247),
      radius: 2.2,
      colors: const [Color(0xFF00F0FF), Color(0x0000F0FF)],
      stops: const [0.0, 1.0],
    ).createShader(rect);
    canvas.drawRRect(rrect, paint);

    // Radial 2 — bottom-right: #CE6AFF (purple) → transparent
    paint.shader = RadialGradient(
      center: const Alignment(1.166, 1.252),
      radius: 1.8,
      colors: const [Color(0xFFCE6AFF), Color(0x00872AB7)],
      stops: const [0.0, 1.0],
    ).createShader(rect);
    paint.blendMode = BlendMode.srcOver;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) =>
      old.radius != radius || old.strokeWidth != strokeWidth;
}
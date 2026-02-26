import 'package:flutter/material.dart';

/// The animated circuit + logo background rendered behind every screen's card.
///
/// Uses [LayoutBuilder] instead of [MediaQuery] so it only rebuilds when the
/// widget's own dimensions change — NOT when the keyboard opens/closes or
/// system insets change. This eliminates unnecessary full-tree rebuilds.
class DigiBackground extends StatelessWidget {
  final Widget child;
  final double circuitOpacity;
  final double logoOpacity;

  const DigiBackground({
    super.key,
    required this.child,
    this.circuitOpacity = 0.05,
    this.logoOpacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── Circuit overlay (top) ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.60,
                    child: Image.asset(
                      'assets/circuit.png',
                      width: w,
                      height: w, // square crop (matches original 394×394)
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // ── Big 24 logo — top ghost ──
              Positioned(
                top: -30,
                left: 0,
                width: w,
                height: h * 0.52,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: logoOpacity,
                    child: Image.asset(
                      'assets/24 logo.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // ── Big 24 logo — bottom ghost ──
              Positioned(
                bottom: -30,
                left: 0,
                width: w,
                height: h * 0.32,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: logoOpacity * 0.6,
                    child: Image.asset(
                      'assets/24 logo.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // ── Page content (always on top) ──
              Positioned.fill(child: child),
            ],
          );
        },
      ),
    );
  }
}
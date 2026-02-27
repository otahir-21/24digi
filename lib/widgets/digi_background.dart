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
  final bool showCircuit;

  const DigiBackground({
    super.key,
    required this.child,
    this.circuitOpacity = 0.05,
    this.logoOpacity = 0.18,
    this.showCircuit = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1220),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── Big 24 logo — centre ghost (sign-up pages only) ──
              if (logoOpacity > 0)
                Positioned(
                  top: h * 0.08,
                  left: 0,
                  width: w,
                  height: h * 0.55,
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

              if (logoOpacity > 0)
                Positioned(
                  bottom: -20,
                  left: 0,
                  width: w,
                  height: h * 0.30,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: logoOpacity * 0.5,
                      child: Image.asset(
                        'assets/24 logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

              // ── Circuit overlay (top only) ──
              if (showCircuit)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.55,
                      child: Image.asset(
                        'assets/circuit.png',
                        width: w,
                        height: w,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
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
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
  final Color backgroundColor;
  /// Height of circuit.png as a fraction of screen width (default 1.0 = square).
  /// Use e.g. 0.4 so tiles start just below the circuit strip.
  final double circuitHeightFactor;

  const DigiBackground({
    super.key,
    required this.child,
    this.circuitOpacity = 0.75,
    this.logoOpacity = 0.40,
    this.showCircuit = true,
    this.backgroundColor = const Color(0xFF000000),
    this.circuitHeightFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── Big 24 logo — top ghost ──
              if (logoOpacity > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  width: w,
                  height: h * 0.40,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: logoOpacity,
                      child: Image.asset(
                        'assets/24 logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.topLeft,
                        errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

              // ── Bottom 24 logo ghost ──
              if (logoOpacity > 0)
                Positioned(
                  bottom: -h * 0.05,
                  left: -w * 0.1,
                  width: w * 1.2,
                  height: h * 0.40,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: logoOpacity,
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
                      opacity: circuitOpacity,
                      child: Image.asset(
                        'assets/circuit.png',
                        width: w,
                        height: w * circuitHeightFactor,
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
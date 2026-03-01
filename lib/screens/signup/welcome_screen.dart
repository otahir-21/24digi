import 'package:flutter/material.dart';
import '../../widgets/digi_text.dart';
import '../../widgets/screen_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: false,
      // Zero padding so positions match Figma exactly
      contentPadding: (s) => EdgeInsets.zero,
      customCardHeightRatio: 0.70,
      builder: (s) => LayoutBuilder(
        builder: (context, constraints) {
          // Use actual card height for vertical positioning (responsive)
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── WELCOME TO text ──
              Positioned(
                top: h * 0.069, // Figma: 34/492
                left: 0,
                right: 0,
                child: Center(child: DigiText.welcomeTo(s)),
              ),

              // ── 24 logo with blue glow shadow ──
              Positioned(
                top: h * 0.181, // Figma: 89/492
                left: 26 * s,
                child: Container(
                  width: 307.36 * s,
                  height: h * 0.528, // Figma: 259.8/492
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF053155),
                        blurRadius: 50 * s,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/24 logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),

              // ── Subtitle ──
              Positioned(
                top: h * 0.760, // Figma: 374/492
                left: 0,
                right: 0,
                child: Center(child: DigiText.subtitle(s)),
              ),

              // ── Get started ──
              Positioned(
                top: h * 0.888, // Figma: 437/492
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/second'),
                    child: DigiText.getStarted(s),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
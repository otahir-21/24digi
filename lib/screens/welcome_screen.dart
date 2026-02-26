import 'package:flutter/material.dart';
import '../widgets/digi_text.dart';
import '../widgets/screen_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: false,
      builder: (s) => Stack(
        children: [
                  // ── 24 logo: exact Figma position relative to card ──
                  // Figma absolute: top=315, left=43  |  card at: top=226, left=17
                  // Relative to card: top=89, left=26
                  Positioned(
                    top: 89 * s,
                    left: 26 * s,
                    width: 307.36 * s,
                    height: 259.8 * s,
                    child: Image.asset(
                      'assets/24 logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),

                  // ── WELCOME TO text pinned to top ──
                  Positioned(
                    top: 34 * s,
                    left: 30 * s,
                    right: 30 * s,
                    child: DigiText.welcomeTo(s),
                  ),

                  // ── Subtitle + GET STARTED pinned to bottom ──
                  Positioned(
                    bottom: 36 * s,
                    left: 30 * s,
                    right: 30 * s,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DigiText.subtitle(s),
                        SizedBox(height: 28 * s),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/second'),
                          child: DigiText.getStarted(s),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
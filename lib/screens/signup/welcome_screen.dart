import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../widgets/digi_text.dart';
import '../../widgets/screen_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // If user already has registered number and user details, redirect to home
    if (auth.isLoggedIn && auth.isProfileComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF020A10),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
        ),
      );
    }
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
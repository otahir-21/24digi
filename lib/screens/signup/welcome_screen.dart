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
      builder: (s) => Stack(
        children: [
                  // ── 24 logo: centered horizontally ──
                  Positioned(
                    top: 89 * s,
                    left: 0,
                    right: 0,
                    height: 259.8 * s,
                    child: Center(
                      child: Image.asset(
                        'assets/24 logo.png',
                        width: 307.36 * s,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
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
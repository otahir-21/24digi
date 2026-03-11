import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_calculating_screen.dart';

class WelcomeCByAIScreen extends StatelessWidget {
  const WelcomeCByAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/c_by_ai/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withValues(alpha: .2)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const ShopTopBar(),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Neon 'C BY AI' Text in background
                    AnimatedOpacity(
                      opacity: 0.8,
                      duration: const Duration(seconds: 1),
                      child: Text(
                        'C BY AI',
                        style: GoogleFonts.outfit(
                          fontSize: 100 * s,
                          fontWeight: FontWeight.w200,
                          color: Colors.transparent,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: const Color(
                                0xFF00F0FF,
                              ).withValues(alpha: .5),
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Outlined Text for the Neon effect
                    Text(
                      'C BY AI',
                      style: GoogleFonts.outfit(
                        fontSize: 100 * s,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 8,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1.5
                          ..color = const Color(0xFF00F0FF),
                      ),
                    ),

                    // HI, USER text
                    Positioned(
                      bottom: 0,
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Central Card
                Container(
                  width: 340 * s,
                  height: 520 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36 * s),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withValues(alpha: .5),
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: .15),
                        Colors.white.withValues(alpha: .05),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35 * s),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24 * s),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .05),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 24.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to',
                                style: GoogleFonts.outfit(
                                  fontSize: 40 * s,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: .9),
                                ),
                              ),
                              Text(
                                'C BY AI',
                                style: GoogleFonts.outfit(
                                  fontSize: 62 * s,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CByAiCalculatingScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'CONTINUE',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24 * s,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
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

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

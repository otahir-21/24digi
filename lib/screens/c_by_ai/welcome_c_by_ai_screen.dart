import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_calculating_screen.dart';
import 'c_by_ai_generating_screen.dart';
import 'c_by_ai_tracker_screen.dart';
import 'providers/c_by_ai_provider.dart';

class WelcomeCByAIScreen extends StatefulWidget {
  const WelcomeCByAIScreen({super.key});

  @override
  State<WelcomeCByAIScreen> createState() => _WelcomeCByAIScreenState();
}

class _WelcomeCByAIScreenState extends State<WelcomeCByAIScreen> {
  bool _isRecovering = true;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final provider = context.read<CByAiProvider>();
    final recovered = await provider.recoverSession();
    if (recovered) {
      if (!mounted) return;
      if (provider.isGenerating) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CByAiGeneratingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CByAiTrackerScreen(initialIsCalendar: true),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isRecovering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final provider = context.watch<CByAiProvider>();

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

                    // HI, <username> text
                    Positioned(
                      bottom: 0,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final name = auth.profile?.name?.trim();
                          final displayName = (name != null && name.isNotEmpty)
                              ? name.toUpperCase()
                              : 'USER';
                          return Text(
                            'HI, $displayName',
                            style: GoogleFonts.outfit(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Central Card
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * 0.88,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * s,
                        vertical: 32 * s,
                      ),
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
                            padding: EdgeInsets.symmetric(vertical: 24 * s),
                            color: Colors.white.withValues(alpha: .05),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Welcome to',
                                  style: GoogleFonts.outfit(
                                    fontSize: 36 * s,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white.withValues(alpha: .9),
                                  ),
                                ),

                                SizedBox(height: 50 * s),

                                Text(
                                  'C BY AI',
                                  style: GoogleFonts.outfit(
                                    fontSize: 56 * s,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),

                                SizedBox(height: 50 * s),

                                if (_isRecovering || provider.isLoadingUserData)
                                  const CircularProgressIndicator(
                                    color: Color(0xFF00F0FF),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to calculating screen; backend runs there with loader
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
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
                                        fontSize: 22 * s,
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
                    );
                  },
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

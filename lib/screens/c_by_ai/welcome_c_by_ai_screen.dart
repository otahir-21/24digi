import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/api_config.dart';
import '../../core/app_constants.dart';
import '../../subscriptions/c_by_ai_entitlement.dart';
import '../subscribe/views/subscription.dart';
import 'c_by_ai_generating_screen.dart';
import 'c_by_ai_profile_setup_screen.dart';
import 'c_by_ai_tracker_screen.dart';
import 'providers/c_by_ai_provider.dart';

class WelcomeCByAIScreen extends StatefulWidget {
  const WelcomeCByAIScreen({super.key});

  @override
  State<WelcomeCByAIScreen> createState() => _WelcomeCByAIScreenState();
}

class _WelcomeCByAIScreenState extends State<WelcomeCByAIScreen> {
  bool _isRecovering = true;
  bool _continueBusy = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final provider = context.read<CByAiProvider>();
    final auth = context.read<AuthProvider>();
    final recovered = await provider.recoverSession();
    if (recovered) {
      if (!mounted) return;
      final uid = auth.firebaseUser?.uid;
      final allowed = await CByAiEntitlement.userHasAccess(uid);
      if (!mounted) return;
      if (!allowed) {
        setState(() => _isRecovering = false);
        return;
      }
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

  void _openProfileSetup() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const CByAiProfileSetupScreen()),
    );
  }

  Future<void> _onContinuePressed() async {
    if (_continueBusy) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use C BY AI.')),
      );
      return;
    }
    if (!ApiConfig.cByAiPaywallEnabled) {
      _openProfileSetup();
      return;
    }
    setState(() => _continueBusy = true);
    try {
      var ok = await CByAiEntitlement.userHasAccess(uid);
      if (!mounted) return;
      if (ok) {
        _openProfileSetup();
        return;
      }
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => Subscription()),
      );
      if (!mounted) return;
      ok = await CByAiEntitlement.userHasAccess(uid);
      if (ok && mounted) {
        _openProfileSetup();
      }
    } finally {
      if (mounted) setState(() => _continueBusy = false);
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/c_by_ai/background.png'),
                fit: BoxFit.cover,
              ),
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
                // FIX 1: Added width: double.infinity so the Stack
                // fills full width and Positioned children center correctly
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: AnimatedOpacity(
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
                      ),
                    ),
                    // Outlined Text for the Neon effect
                    Text(
                      'C BY AI',
                      style: GoogleFonts.outfit(
                        fontSize: 100 * s,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 8,
                        foreground:
                            Paint()
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
                          final displayName =
                              (name != null && name.isNotEmpty)
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

                    // Tutorial/Help Icon
                    Positioned(
                      top: 10 * s,
                      right: 10 * s,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tutorial coming soon!'),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/icons/HelpCircle.png',
                          width: 28 * s,
                          height: 28 * s,
                          color: const Color(0xFF00F0FF),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // FIX 2: Wrapped LayoutBuilder in Center so the card
                // is always horizontally centered regardless of screen width
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.88,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * s,
                          vertical: 32 * s,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36 * s),
                          border: Border.all(
                            color: const Color(
                              0xFF00F0FF,
                            ).withValues(alpha: .5),
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

                                  if (_isRecovering ||
                                      provider.isLoadingUserData ||
                                      _continueBusy)
                                    const CircularProgressIndicator(
                                      color: Color(0xFF00F0FF),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: _onContinuePressed,
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

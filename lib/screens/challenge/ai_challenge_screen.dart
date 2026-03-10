import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

class AIChallengeScreen extends StatefulWidget {
  const AIChallengeScreen({super.key});

  @override
  State<AIChallengeScreen> createState() => _AIChallengeScreenState();
}

class _AIChallengeScreenState extends State<AIChallengeScreen> {
  static const Color _bg = Color(0xFF0A0F14); // Very dark background
  static const Color _green = Color(0xFF00592F); // Dark green for title

  bool _showComingSoon = true;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Background content
            Column(
              children: [
                const ProfileTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const NeverScrollableScrollPhysics(), // Match design static feel
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20 * s),
                          Text(
                            'HI, USER',
                            style: GoogleFonts.inter(
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            '24 Challenge',
                            style: GoogleFonts.outfit(
                              fontSize: 48 * s,
                              fontWeight: FontWeight.w900,
                              color: _green,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 40 * s),
                          // Blurred/Darkened background cards
                          Opacity(
                            opacity: 0.3,
                            child: Column(
                              children: [
                                _SlantedCard(
                                  s: s,
                                  label: '24 Competition',
                                  isRight: true,
                                ),
                                SizedBox(height: 16 * s),
                                _SlantedCard(
                                  s: s,
                                  label: '24 Private Zone',
                                  isRight: false,
                                ),
                                SizedBox(height: 16 * s),
                                _SlantedCard(
                                  s: s,
                                  label: '24 AI Challenge Zone',
                                  isRight: true,
                                ),
                                SizedBox(height: 16 * s),
                                _SlantedCard(
                                  s: s,
                                  label: '24 Adventure zone',
                                  isRight: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Coming Soon Popup
            if (_showComingSoon)
              _ComingSoonPopup(
                s: s,
                onClose: () => setState(() => _showComingSoon = false),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlantedCard extends StatelessWidget {
  final double s;
  final String label;
  final bool isRight;

  const _SlantedCard({
    required this.s,
    required this.label,
    required this.isRight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: 300 * s,
        height: 100 * s,
        child: CustomPaint(
          painter: _SlantedCardPainter(
            isRight: isRight,
            color: const Color(0xFF00FF88).withValues(alpha: 0.2),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00592F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlantedCardPainter extends CustomPainter {
  final bool isRight;
  final Color color;
  _SlantedCardPainter({required this.isRight, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final slant = 40.0;
    if (isRight) {
      path.moveTo(slant, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - slant, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ComingSoonPopup extends StatelessWidget {
  final double s;
  final VoidCallback onClose;

  const _ComingSoonPopup({required this.s, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320 * s,
        padding: EdgeInsets.all(24 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1217).withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 40 * s,
              spreadRadius: 4 * s,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: Colors.white70, size: 24 * s),
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              'Coming Soon',
              style: GoogleFonts.outfit(
                fontSize: 32 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              'We are working on\nsomething amazing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16 * s),
          ],
        ),
      ),
    );
  }
}

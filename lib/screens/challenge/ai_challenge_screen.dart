import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import 'adventure_challenge_screen.dart';

class AIChallengeScreen extends StatefulWidget {
  const AIChallengeScreen({super.key});

  @override
  State<AIChallengeScreen> createState() => _AIChallengeScreenState();
}

class _AIChallengeScreenState extends State<AIChallengeScreen> {
  static const Color _bg = Color(0xFF040A11);
  static const Color _green = Color(0xFF00592F);
  static const Color _brightGreen = Color(0xFF00FF88);

  bool _showComingSoon = true;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8 * s, 8 * s, 8 * s, 12 * s),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18 * s),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF040A11), Color(0xFF02060C)],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(6 * s, 8 * s, 6 * s, 20 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _TopGradientBar(s: s),
                        SizedBox(height: 12 * s),
                        Text(
                          'HI, USER',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD8D8D8),
                          ),
                        ),
                        SizedBox(height: 10 * s),
                        Text(
                          '24 Challenge',
                          style: GoogleFonts.outfit(
                            fontSize: 60 / 2 * s * 2,
                            fontWeight: FontWeight.w800,
                            color: _green,
                            shadows: [
                              Shadow(
                                color: _brightGreen.withValues(alpha: 0.25),
                                blurRadius: 14 * s,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20 * s),
                        _buildMainCardStack(s),
                        SizedBox(height: 14 * s),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdventureChallengeScreen(),
                              ),
                            );
                          },
                          child: _AdventureSlantedCard(s: s),
                        ),
                        SizedBox(height: 10 * s),
                      ],
                    ),
                  ),
                ),
                if (_showComingSoon)
                  _ComingSoonOverlay(
                    s: s,
                    onClose: () => setState(() => _showComingSoon = false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCardStack(double s) {
    return SizedBox(
      height: 360 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -22 * s,
            top: 88 * s,
            width: 84 * s,
            height: 98 * s,
            child: _SidePeekCard(s: s, text: '2', alignRightAccent: true),
          ),
          Positioned(
            right: -18 * s,
            top: 10 * s,
            width: 84 * s,
            height: 98 * s,
            child: _SidePeekCard(s: s, text: '7', alignRightAccent: false),
          ),
          Positioned(
            right: -18 * s,
            bottom: 20 * s,
            width: 84 * s,
            height: 98 * s,
            child: _SidePeekCard(s: s, text: 'e', alignRightAccent: false),
          ),
          Positioned(
            left: 20 * s,
            right: 20 * s,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF07111B),
                borderRadius: BorderRadius.circular(2 * s),
              ),
              child: const _CenterGlow(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopGradientBar extends StatelessWidget {
  const _TopGradientBar({required this.s});

  final double s;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34 * s),
        gradient: const LinearGradient(
          colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: EdgeInsets.all(1.3 * s),
      child: Container(
        height: 60 * s,
        padding: EdgeInsets.symmetric(horizontal: 12 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF142230).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(34 * s),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left,
                size: 40 / 2 * s * 2,
                color: Color(0xFF00F0FF),
              ),
            ),
            const Spacer(),
            Image.asset('assets/24 logo.png', height: 38 * s),
            const Spacer(),
            Container(
              width: 40 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/fonts/male.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidePeekCard extends StatelessWidget {
  const _SidePeekCard({
    required this.s,
    required this.text,
    required this.alignRightAccent,
  });

  final double s;
  final String text;
  final bool alignRightAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1620),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(
          color: const Color(0xFF00FF88).withValues(alpha: 0.35),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: alignRightAccent
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 4 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88),
                borderRadius: BorderRadius.horizontal(
                  right: alignRightAccent
                      ? Radius.circular(8 * s)
                      : Radius.zero,
                  left: alignRightAccent ? Radius.zero : Radius.circular(8 * s),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 34 / 2 * s * 2,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00FF88).withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureSlantedCard extends StatelessWidget {
  const _AdventureSlantedCard({required this.s});

  final double s;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 102 * s,
      child: CustomPaint(
        painter: _SlantedCardPainter(border: const Color(0xFF00A15A)),
        child: ClipPath(
          clipper: const _SlantedClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E3F43), Color(0xFF2F3033)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 30 * s),
            child: Text(
              '24 Adventure\nzone',
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00592F),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 1.5 * s,
                    offset: Offset(0, 1 * s),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonOverlay extends StatelessWidget {
  const _ComingSoonOverlay({required this.s, required this.onClose});

  final double s;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        alignment: Alignment.center,
        child: SizedBox(
          width: 330 * s,
          height: 310 * s,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF06111B).withValues(alpha: 0.95),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0C0).withValues(alpha: 0.25),
                        blurRadius: 70 * s,
                        spreadRadius: 16 * s,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 248 * s,
                  padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 22 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1520).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18 * s),
                    border: Border.all(
                      color: const Color(0xFF00E5CC).withValues(alpha: 0.55),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -6 * s,
                        top: -10 * s,
                        child: GestureDetector(
                          onTap: onClose,
                          child: Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 26 / 2 * s * 2,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 8 * s),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Coming ',
                                  style: GoogleFonts.inter(
                                    fontSize: 40 / 2 * s * 2,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Soon',
                                  style: GoogleFonts.inter(
                                    fontSize: 40 / 2 * s * 2,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF88E0D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            'We are working on\nsomething amazing.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 18 / 2 * s * 2,
                              color: const Color(0xFFC3C3C3),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterGlow extends StatelessWidget {
  const _CenterGlow();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GlowPainter(), child: const SizedBox.expand());
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.48;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFCC).withValues(alpha: 0.28),
          const Color(0xFF00A676).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0, 0.48, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SlantedClipper extends CustomClipper<Path> {
  const _SlantedClipper();

  @override
  Path getClip(Size size) {
    final cut = 58.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SlantedCardPainter extends CustomPainter {
  const _SlantedCardPainter({required this.border});

  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final cut = 58.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

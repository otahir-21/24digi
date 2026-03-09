import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// Standalone entry – remove if you already have main.dart
// ─────────────────────────────────────────────────────────────
void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AIChallengeScreen(),
      );
}

// ─────────────────────────────────────────────────────────────
// AIChallengeScreen
// ─────────────────────────────────────────────────────────────
class AIChallengeScreen extends StatefulWidget {
  const AIChallengeScreen({super.key});

  @override
  State<AIChallengeScreen> createState() => _AIChallengeScreenState();
}

class _AIChallengeScreenState extends State<AIChallengeScreen> {
  // ── palette ───────────────────────────────────────────────
  static const Color kBg = Color(0xFF080E12);
  static const Color kGreen = Color(0xFF00FF88);
  static const Color kGreenDim = Color(0xFF00C86A);
  static const Color kCyan = Color(0xFF00E5CC);
  static const Color kPurple = Color(0xFF9B59F5);
  static const Color kCardBg = Color(0xFF0D1A14);
  static const Color kModalBg = Color(0xFF111A20);

  bool _showModal = true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── scrollable body ──────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  _buildTopBar(w),
                  const SizedBox(height: 20),
                  _buildGreeting(),
                  const SizedBox(height: 44),
                  _buildMainCard(w, h),
                  const SizedBox(height: 0),
                  _buildAdventureCard(w),
                  const SizedBox(height: 48),
                ],
              ),
            ),

            // ── Coming Soon modal overlay ────────────────────
            if (_showModal) _buildModalOverlay(w),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar(double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1520),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        child: CustomPaint(
          painter: _GradientBorderPainter(
            radius: 40,
            strokeWidth: 1.8,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [kCyan, kPurple],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Back arrow
                const Icon(Icons.chevron_left,
                    color: Colors.white, size: 28),
                const Spacer(),
                // Logo
                _buildLogo(),
                const Spacer(),
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kCyan, width: 2),
                    color: Colors.grey.shade700,
                    image: const DecorationImage(
                      // Replace with your asset when available
                      image: AssetImage('assets/avatar/user.png'),
                      fit: BoxFit.cover,
                      onError: _avatarErrorBuilder,
                    ),
                  ),
                  child: ClipOval(
                    child: Icon(Icons.person,
                        color: Colors.white70, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // iridescent "24·eDiGi" logo
  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF00E5FF),
              Color(0xFF7B61FF),
              Color(0xFF00CFFF),
            ],
          ).createShader(bounds),
          child: Text(
            '24',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          '·eDiGi',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
            letterSpacing: 1.5,
            height: 0.8,
          ),
        ),
      ],
    );
  }

  // ── GREETING ─────────────────────────────────────────────
  Widget _buildGreeting() {
    return Column(
      children: [
        Text(
          'HI, USER',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFF00FF88),
              const Color(0xFF00CC6A),
            ],
          ).createShader(bounds),
          child: Text(
            '24 Challenge',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked by shader
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: kGreen.withOpacity(0.55),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── MAIN CARD (the large dark area with radial glow + peeking side cards) ──
  Widget _buildMainCard(double w, double h) {
    final cardH = h * 0.46;

    return SizedBox(
      width: w,
      height: cardH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Centre card: dark with teal radial glow ──────
          Positioned(
            left: 28,
            right: 28,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: _RadialGlowPainter(
                  color: const Color(0xFF005540),
                  glowColor: const Color(0xFF00F0A0),
                  radius: 0.55,
                ),
              ),
            ),
          ),

          // ── Left peeking card with green tab ────────────
          Positioned(
            left: -52,
            top: cardH * 0.12,
            bottom: cardH * 0.12,
            width: 88,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1A14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // green right-side tab
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: kGreen.withOpacity(0.6),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
                // dim "7" or rank text visible on edge
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      '7',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kGreen.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right peeking cards (two stacked) ────────────
          // Upper right card
          Positioned(
            right: -52,
            top: cardH * 0.05,
            height: cardH * 0.36,
            width: 80,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1A14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGreen.withOpacity(0.3), width: 1),
                  ),
                ),
                // green left-side tab
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: kGreen.withOpacity(0.6),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lower right card
          Positioned(
            right: -52,
            top: cardH * 0.50,
            height: cardH * 0.36,
            width: 80,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1A14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGreen.withOpacity(0.3), width: 1),
                  ),
                ),
                // green left-side tab
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: kGreen.withOpacity(0.6),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
                // "e" text peeking
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      'e',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kGreen.withOpacity(0.55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ADVENTURE CARD (bottom trapezoid) ────────────────────
  Widget _buildAdventureCard(double w) {
    final cardW = w * 0.68;
    const cardH = 110.0;
    const kCut = 44.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: CustomPaint(
          painter: _TrapezoidPainter(
            bgColor: const Color(0xFF2A2D27),
            borderColor: kGreen.withOpacity(0.5),
            cutRight: true,
            cut: kCut,
          ),
          child: ClipPath(
            clipper: _TrapezoidClipper(cutRight: true, cut: kCut),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                '24 Adventure\nzone',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kGreen,
                  height: 1.25,
                  shadows: [
                    Shadow(
                      color: kGreen.withOpacity(0.55),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── COMING SOON MODAL ────────────────────────────────────
  Widget _buildModalOverlay(double w) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: _ComingSoonModal(
            onClose: () => setState(() => _showModal = false),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Coming Soon Modal Card
// ─────────────────────────────────────────────────────────────
class _ComingSoonModal extends StatelessWidget {
  final VoidCallback onClose;
  static const Color kGreen = Color(0xFF00FF88);

  const _ComingSoonModal({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: w * 0.78,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111A20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kGreen.withOpacity(0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button row
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: Colors.white70, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Coming ',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Soon',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'We are working on\nsomething amazing.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Trapezoid Clipper
// cutRight=true  → right side diagonal (card on LEFT of screen)
//   (0,0) ────────── (w-cut, 0)
//   (0,h) ────────── (w, h)
// ─────────────────────────────────────────────────────────────
class _TrapezoidClipper extends CustomClipper<Path> {
  final bool cutRight;
  final double cut;
  const _TrapezoidClipper({required this.cutRight, required this.cut});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    if (cutRight) {
      path.moveTo(0, 0);
      path.lineTo(w - cut, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
    } else {
      path.moveTo(cut, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────
// Trapezoid Painter (fill + border)
// ─────────────────────────────────────────────────────────────
class _TrapezoidPainter extends CustomPainter {
  final Color bgColor;
  final Color borderColor;
  final bool cutRight;
  final double cut;

  const _TrapezoidPainter({
    required this.bgColor,
    required this.borderColor,
    required this.cutRight,
    required this.cut,
  });

  Path _path(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    if (cutRight) {
      path.moveTo(0, 0);
      path.lineTo(w - cut, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
    } else {
      path.moveTo(cut, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_path(size), Paint()..color = bgColor);
    canvas.drawPath(
      _path(size),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Radial Glow Painter (for the main dark card)
// ─────────────────────────────────────────────────────────────
class _RadialGlowPainter extends CustomPainter {
  final Color color;
  final Color glowColor;
  final double radius; // 0..1, fraction of card width

  const _RadialGlowPainter({
    required this.color,
    required this.glowColor,
    this.radius = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * radius;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(0.18),
          color.withOpacity(0.28),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Gradient Border Painter (for the top bar pill border)
// ─────────────────────────────────────────────────────────────
class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  const _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Avatar image error builder (static, for DecorationImage)
// ─────────────────────────────────────────────────────────────
void _avatarErrorBuilder(Object error, StackTrace? stackTrace) {
  // no-op – the ClipOval Icon fallback shows instead
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/screens/c_by_ai/welcome_c_by_ai_screen.dart';
import 'package:kivi_24/screens/challenge/challenge_welcome_screen.dart';
import 'package:kivi_24/screens/diet/diet_welcome_screen.dart';
import 'package:kivi_24/screens/shop/shop_welcome_screen.dart';
import 'package:kivi_24/screens/bracelet/bracelet_search_screen.dart';
import '../core/app_constants.dart';
import '../widgets/digi_background.dart';
import 'stub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _nav(String title) {
    if (title == '24 DIET') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DietWelcomeScreen()),
      );
    } else if (title == 'CHALLENGE ZONE') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChallengeWelcomeScreen()),
      );
    } else if (title == '24 SHOP') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopWelcomeScreen()),
      );
    } else if (title == 'C BY AI') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeCByAIScreen()),
      );
    } else if (title == '24 BRACELET') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BraceletSearchScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StubScreen(title: title)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name?.toUpperCase() ?? 'USER';

    return Scaffold(
      backgroundColor: Colors.black,
      body: DigiBackground(
        showLanguageSlider: false,
        circuitOpacity: 0.6,
        circuitHeightFactor: 0.5,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PillHeader(s: s),
                SizedBox(height: 14 * s),
                Text(
                  'HI, $name',
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 2.5 * s,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00F0FF).withOpacity(0.5),
                        blurRadius: 10 * s,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28 * s),
                _SectionOne(s: s, onTap: _nav),
                SizedBox(height: 60 * s),
                _SectionTwo(s: s, onTap: _nav),
                SizedBox(height: 60 * s),
                _SectionThree(s: s, onTap: _nav),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HEADER ───────────────────────────────────────────────────────────────────

class _PillHeader extends StatelessWidget {
  final double s;
  const _PillHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62 * s,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519).withOpacity(0.85),
        borderRadius: BorderRadius.circular(31 * s),
        border: Border.all(color: const Color(0xFF1E2D38), width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF00F0FF),
                size: 20 * s,
              ),
            ),
            Image.asset(
              'assets/24 logo.png',
              height: 40 * s,
              fit: BoxFit.contain,
            ),
            Container(
              width: 44 * s,
              height: 44 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset('assets/fonts/male.png', fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SECTION 1 ────────────────────────────────────────────────────────────────

class _SectionOne extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionOne({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // cut value shared between all 3 tiles so the notch interlocks perfectly
    const double cut = 30.0;

    return SizedBox(
      height: 215 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column 44%
          Expanded(
            flex: 44,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap('CHALLENGE ZONE'),
                    child: CustomPaint(
                      painter: _TopLeftTilePainter(s, cut),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 14 * s,
                          right: 30 * s,
                          top: 12 * s,
                          bottom: 12 * s,
                        ),
                        alignment: Alignment.centerLeft,
                        child: _GlowText(
                          s: s,
                          text: 'CHALLENGE\nZONE',
                          fontSize: 16 * s,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap('24 BRACELET'),
                    child: CustomPaint(
                      painter: _BottomLeftTilePainter(s, cut),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 14 * s,
                          right: 30 * s,
                          top: 12 * s,
                          bottom: 12 * s,
                        ),
                        alignment: Alignment.centerLeft,
                        child: _GlowText(
                          s: s,
                          text: '24\nBRACELET',
                          fontSize: 16 * s,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Gap so diagonals face each other visibly
          SizedBox(width: 6 * s),
          // Right C BY AI 56%
          Expanded(
            flex: 56,
            child: GestureDetector(
              onTap: () => onTap('C BY AI'),
              child: CustomPaint(
                painter: _CByAiTilePainter(s, cut),
                child: Container(
                  padding: EdgeInsets.only(left: 34 * s, right: 12 * s),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlowText(
                        s: s,
                        text: 'C',
                        fontSize: 88 * s,
                        letterSpacing: 0,
                        isOutline: true,
                      ),
                      SizedBox(height: 2 * s),
                      _GlowText(
                        s: s,
                        text: 'BY AI',
                        fontSize: 22 * s,
                        letterSpacing: 3 * s,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SECTION 2 ────────────────────────────────────────────────────────────────

class _SectionTwo extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionTwo({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTap('24 DELIVERY'),
              child: CustomPaint(
                painter: _LeftTrapPainter(s),
                child: Container(
                  padding: EdgeInsets.only(left: 14 * s, right: 32 * s),
                  alignment: Alignment.centerLeft,
                  child: _GlowText(
                    s: s,
                    text: '24\nDELIVERY',
                    fontSize: 20 * s,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 28 * s),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap('24 DIET'),
              child: CustomPaint(
                painter: _RightTrapPainter(s),
                child: Container(
                  padding: EdgeInsets.only(left: 32 * s, right: 14 * s),
                  alignment: Alignment.centerRight,
                  child: _GlowText(
                    s: s,
                    text: '24\nDIET',
                    fontSize: 20 * s,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SECTION 3 ────────────────────────────────────────────────────────────────

class _SectionThree extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionThree({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTap('AI MODELS'),
              child: CustomPaint(
                painter: _LeftTrapPainter(s),
                child: Container(
                  padding: EdgeInsets.only(left: 14 * s, right: 32 * s),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlowText(
                        s: s,
                        text: 'AI',
                        fontSize: 40 * s,
                        isOutline: true,
                        letterSpacing: 0,
                      ),
                      SizedBox(width: 8 * s),
                      _GlowText(
                        s: s,
                        text: 'MODELS',
                        fontSize: 14 * s,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap('24 SHOP'),
              child: CustomPaint(
                painter: _RightTrapPainter(s),
                child: Container(
                  padding: EdgeInsets.only(left: 32 * s, right: 14 * s),
                  alignment: Alignment.centerRight,
                  child: _GlowText(
                    s: s,
                    text: '24\nSHOP',
                    fontSize: 20 * s,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GLOW TEXT ─────────────────────────────────────────────────────────────────

class _GlowText extends StatelessWidget {
  final double s;
  final String text;
  final double fontSize;
  final double letterSpacing;
  final TextAlign textAlign;
  final bool isOutline;

  const _GlowText({
    required this.s,
    required this.text,
    required this.fontSize,
    this.letterSpacing = 1.0,
    this.textAlign = TextAlign.center,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00F0FF);
    if (isOutline) {
      return Stack(
        children: [
          Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: Colors.transparent,
              letterSpacing: letterSpacing,
              height: 1.0,
              shadows: [
                Shadow(color: cyan.withOpacity(0.9), blurRadius: 18 * s),
              ],
            ),
          ),
          Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2 * s
                ..color = cyan,
              letterSpacing: letterSpacing,
              height: 1.0,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'LemonMilk',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: cyan,
        letterSpacing: letterSpacing,
        height: 1.1,
        shadows: [
          Shadow(color: cyan.withOpacity(0.9), blurRadius: 10 * s),
          Shadow(color: cyan.withOpacity(0.4), blurRadius: 20 * s),
        ],
      ),
    );
  }
}

// ── SHARED DRAW HELPER ────────────────────────────────────────────────────────

void _drawTilePath(
  Canvas canvas,
  Size size,
  Path path, {
  bool pinkGlow = false,
}) {
  // Background fill
  canvas.drawPath(
    path,
    Paint()
      ..color = const Color(0xFF0A1520).withOpacity(0.92)
      ..style = PaintingStyle.fill,
  );

  // Pink radial glow for C BY AI
  if (pinkGlow) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.4, 0.75),
          radius: 0.85,
          colors: [
            const Color(0xFFCC0055).withOpacity(0.35),
            const Color(0xFF660033).withOpacity(0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );
  }

  // Gradient border
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF00F0FF), const Color(0xFFAA44FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round,
  );
}

// ── PAINTERS ──────────────────────────────────────────────────────────────────

// TOP-LEFT tile: top is full width, bottom-right has diagonal cut
// (width, height-c) -> (width-c, height)  ==>  \ cut on bottom-right
class _TopLeftTilePainter extends CustomPainter {
  final double s;
  final double cut;
  _TopLeftTilePainter(this.s, this.cut);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    const cut = 28.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(r * s, 0)
      ..lineTo(size.width, 0) // top goes FULL width (no cut at top)
      ..lineTo(size.width - c, size.height) // bottom-right cuts INWARD
      ..lineTo(r * s, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r * s)
      ..lineTo(0, r * s)
      ..quadraticBezierTo(0, 0, r * s, 0)
      ..close();
    _drawTilePath(canvas, size, path);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// BOTTOM-LEFT tile: top-right has diagonal cut (mirror of top tile)
// (width-c, 0) -> (width, c)  ==>  / cut on top-right
class _BottomLeftTilePainter extends CustomPainter {
  final double s;
  final double cut;
  _BottomLeftTilePainter(this.s, this.cut);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    const cut = 28.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(r * s, 0)
      ..lineTo(size.width - c, 0) // top stops before right edge
      ..lineTo(size.width, size.height) // diagonal to full width at bottom
      ..lineTo(r * s, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r * s)
      ..lineTo(0, r * s)
      ..quadraticBezierTo(0, 0, r * s, 0)
      ..close();
    _drawTilePath(canvas, size, path);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// C BY AI tile:
// Left side = pointed arrow tip at (0, height/2)
// Top-left starts at (cut*s, 0), bottom-left at (cut*s, height)
// Rounded top-right and bottom-right corners
class _CByAiTilePainter extends CustomPainter {
  final double s;
  final double cut;
  _CByAiTilePainter(this.s, this.cut);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(c, 0) // top-left offset
      ..lineTo(size.width - r * s, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r * s) // top-right rounded
      ..lineTo(size.width, size.height - r * s)
      ..quadraticBezierTo(
        size.width,
        size.height, // bottom-right rounded
        size.width - r * s,
        size.height,
      )
      ..lineTo(c, size.height) // bottom-left offset
      ..lineTo(0, size.height / 2) // ◄ pointed left tip
      ..close();
    _drawTilePath(canvas, size, path, pinkGlow: true);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// LEFT TRAPEZOID: top-right diagonal cuts inward
// Top ends at (width - cut*s), bottom goes to full width
// Creates / diagonal on the right side
class _LeftTrapPainter extends CustomPainter {
  final double s;
  _LeftTrapPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    const cut = 28.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(r * s, 0)
      ..lineTo(size.width, 0) // top goes FULL width (no cut at top)
      ..lineTo(size.width - c, size.height) // bottom-right cuts INWARD
      ..lineTo(r * s, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r * s)
      ..lineTo(0, r * s)
      ..quadraticBezierTo(0, 0, r * s, 0)
      ..close();
    _drawTilePath(canvas, size, path);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// RIGHT TRAPEZOID: top-left diagonal cuts inward
// Top starts at (cut*s), bottom-left at 0
// Creates \ diagonal on the left side
class _RightTrapPainter extends CustomPainter {
  final double s;
  _RightTrapPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    const cut = 28.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(c, 0) // top-left offset
      ..lineTo(size.width - r * s, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r * s)
      ..lineTo(size.width, size.height - r * s)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - r * s,
        size.height,
      )
      ..lineTo(0, size.height) // bottom-left flush
      ..lineTo(c, 0) // diagonal back to start
      ..close();
    _drawTilePath(canvas, size, path);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

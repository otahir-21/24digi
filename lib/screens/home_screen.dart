import 'package:flutter/material.dart';
import 'package:kivi_24/screens/ai_model/ai_model_dashboard.dart';
import 'package:kivi_24/screens/bracelet/bracelet_screen.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/screens/c_by_ai/welcome_c_by_ai_screen.dart';
import 'package:kivi_24/screens/challenge/challenge_welcome_screen.dart';
import 'package:kivi_24/screens/diet/diet_welcome_screen.dart';
import 'package:kivi_24/screens/shop/shop_welcome_screen.dart';
import 'package:kivi_24/screens/bracelet/bracelet_search_screen.dart';
import 'package:kivi_24/screens/heroes/views/heroes.dart';
import 'package:kivi_24/screens/wallet/views/main_parent_screen.dart';
import 'package:kivi_24/screens/subscribe/views/subscription.dart';
import '../core/app_constants.dart';
import '../widgets/digi_background.dart';
import '../widgets/digi_pill_header.dart';
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
    } else if (title == 'AI MODELS') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiModelDashboard()),
      );
    } else if (title == 'WALLET') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainParentScreen()),
      );
    } else if (title == 'SUBSCRIBE') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Subscription()),
      );
    } else if (title == '24 HEROES') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Heroes()));
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
                const DigiPillHeader(showBack: false),
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
                SizedBox(
                  height: 50 * s,
                ), // Reduced spacing slightly for better flow
                _SectionTwo(s: s, onTap: _nav),
                SizedBox(height: 50 * s),
                _SectionThree(s: s, onTap: _nav),
                SizedBox(height: 40 * s),
                _SectionFour(s: s, onTap: _nav),
                SizedBox(height: 16 * s),
                _SectionFive(s: s, onTap: _nav),
                SizedBox(height: 40 * s),
                _BannerSection(s: s),
                SizedBox(height: 40 * s),
                _StatsSection(s: s),
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
// The home screen uses DigiPillHeader with showBack: false (no back arrow).

// ── SECTION 1 ────────────────────────────────────────────────────────────────

class _SectionOne extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionOne({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double cut = 30.0;

    return SizedBox(
      height: 215 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                          fontSize:
                              14 * s, // Slightly smaller font for better fit
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
                          fontSize: 14 * s,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * s),
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
                        fontSize: 80 * s,
                        letterSpacing: 0,
                        isOutline: true,
                      ),
                      SizedBox(height: 2 * s),
                      _GlowText(
                        s: s,
                        text: 'BY AI',
                        fontSize: 20 * s,
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
                    fontSize: 18 * s,
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
                    fontSize: 18 * s,
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
                        fontSize: 36 * s,
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
                    fontSize: 18 * s,
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

// ── SECTION 4 ────────────────────────────────────────────────────────────────

class _SectionFour extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionFour({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SquaredButton(
            s: s,
            text: 'WALLET',
            onTap: () => onTap('WALLET'),
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: _SquaredButton(
            s: s,
            text: 'SUBSCRIBE',
            onTap: () => onTap('SUBSCRIBE'),
          ),
        ),
      ],
    );
  }
}

// ── SECTION 5 ────────────────────────────────────────────────────────────────

class _SectionFive extends StatelessWidget {
  final double s;
  final Function(String) onTap;
  const _SectionFive({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SquaredButton(
            s: s,
            text: '24\nHEROES',
            onTap: () => onTap('24 HEROES'),
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: _SquaredButton(
            s: s,
            text: '24\nDISCOVERY',
            onTap: () => onTap('24 DISCOVERY'),
          ),
        ),
      ],
    );
  }
}

class _SquaredButton extends StatelessWidget {
  final double s;
  final String text;
  final VoidCallback onTap;
  const _SquaredButton({
    required this.s,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75 * s,
        decoration: BoxDecoration(
          color: const Color(
            0xFF030708,
          ).withOpacity(0.95), // Deeper dark for premium feel
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(
            color: const Color(0xFF00F0FF).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withOpacity(0.08),
              blurRadius: 10 * s,
              spreadRadius: 1 * s,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _GlowText(
          s: s,
          text: text,
          fontSize: 15 * s,
          letterSpacing: 1.2 * s,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── BANNER SECTION ────────────────────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  final double s;
  const _BannerSection({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * s),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withOpacity(0.2),
            blurRadius: 20 * s,
            spreadRadius: -5 * s,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15 * s),
        child: Stack(
          children: [
            Image.asset(
              'assets/fonts/bannerad.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fitWidth,
              alignment: Alignment.centerRight,
            ),
            // Positioned(
            //   bottom: 10 * s,
            //   right: 12 * s,
            //   child: Container(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 10 * s,
            //       vertical: 4 * s,
            //     ),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF00B2B2).withOpacity(0.8),
            //       borderRadius: BorderRadius.circular(4 * s),
            //     ),
            //     child: Text(
            //       'Learn More',
            //       style: TextStyle(
            //         fontFamily: 'HelveticaNeue',
            //         fontSize: 10 * s,
            //         color: Colors.white,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
            // Positioned(
            //   top: 15 * s,
            //   left: 15 * s,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'UNLOCK YOUR POTENTIAL',
            //         style: TextStyle(
            //           fontFamily: 'HelveticaNeue',
            //           fontSize: 18 * s,
            //           fontWeight: FontWeight.w700,
            //           color: Colors.white.withOpacity(0.9),
            //           letterSpacing: 0.5 * s,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Positioned(
            //   bottom: 12 * s,
            //   left: 15 * s,
            //   child: RichText(
            //     text: TextSpan(
            //       children: [
            //         TextSpan(
            //           text: '24',
            //           style: TextStyle(
            //             fontFamily: 'LemonMilk',
            //             fontSize: 16 * s,
            //             color: const Color(0xFF8B8B8B),
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //         TextSpan(
            //           text: 'DIGI',
            //           style: TextStyle(
            //             fontFamily: 'LemonMilk',
            //             fontSize: 16 * s,
            //             color: const Color(0xFF00F0FF),
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ── STATS SECTION ─────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  final double s;
  const _StatsSection({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF030708).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(
          color: const Color(0xFF5A4D9A).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE6AFF).withOpacity(0.1),
            blurRadius: 20 * s,
            spreadRadius: -2 * s,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _StatInput(
                      s: s,
                      iconPath: 'assets/fonts/hieght.png',
                      label: 'enter your height',
                    ),
                    SizedBox(height: 30 * s),
                    _StatInput(
                      s: s,
                      iconPath: 'assets/fonts/weight.png',
                      label: 'enter your weight',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/fonts/male.png',
                  height: 160 * s,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 8 * s),
              // Vertical progress bar
              Container(
                width: 14 * s,
                height: 150 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D38),
                  borderRadius: BorderRadius.circular(7 * s),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 14 * s,
                  height: 110 * s,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFF673AB7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(7 * s),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatInput extends StatelessWidget {
  final double s;
  final String iconPath;
  final String label;

  const _StatInput({
    required this.s,
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 32 * s,
          height: 44 * s,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 14 * s),
        Expanded(
          child: Container(
            height: 38 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF435A6C).withOpacity(0.5),
              borderRadius: BorderRadius.circular(6 * s),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            alignment: Alignment.centerLeft,
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 10 * s,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 10 * s,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
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
                Shadow(color: cyan.withOpacity(0.8), blurRadius: 15 * s),
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
                ..strokeWidth = 1.0 * s
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
        shadows: [Shadow(color: cyan.withOpacity(0.7), blurRadius: 8 * s)],
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
  canvas.drawPath(
    path,
    Paint()
      ..color = const Color(0xFF030708).withOpacity(0.95)
      ..style = PaintingStyle.fill,
  );

  if (pinkGlow) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.4, 0.75),
          radius: 0.9,
          colors: [
            const Color(0xFFCC0055).withOpacity(0.3),
            const Color(0xFF660033).withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );
  }

  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFFAA44FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round,
  );
}

// ── PAINTERS ──────────────────────────────────────────────────────────────────

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
      ..lineTo(size.width, 0)
      ..lineTo(size.width - c, size.height)
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
      ..lineTo(size.width - c, 0)
      ..lineTo(size.width, size.height)
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

class _CByAiTilePainter extends CustomPainter {
  final double s;
  final double cut;
  _CByAiTilePainter(this.s, this.cut);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - r * s, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r * s)
      ..lineTo(size.width, size.height - r * s)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - r * s,
        size.height,
      )
      ..lineTo(c, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    _drawTilePath(canvas, size, path, pinkGlow: true);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

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
      ..lineTo(size.width, 0)
      ..lineTo(size.width - c, size.height)
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

class _RightTrapPainter extends CustomPainter {
  final double s;
  _RightTrapPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    const cut = 28.0;
    final c = cut * s;
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - r * s, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r * s)
      ..lineTo(size.width, size.height - r * s)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - r * s,
        size.height,
      )
      ..lineTo(0, size.height)
      ..lineTo(c, 0)
      ..close();
    _drawTilePath(canvas, size, path);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

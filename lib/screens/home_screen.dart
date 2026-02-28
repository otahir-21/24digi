import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_constants.dart';
import '../painters/smooth_gradient_border.dart';
import '../widgets/digi_background.dart';

// ── Stub page imports ────────────────────────────────────────────────────────
import 'stub_screen.dart';
import 'bracelet/bracelet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _go(String title) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StubScreen(title: title)),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    const gap = 10.0;

    // Available content width inside horizontal padding
    final cw = mq.size.width - hPad * 2;
    // Each half-width tile — chevron arrows interlock with 0 separator, so each gets cw/2
    final col2 = cw / 2;
    // 3-column tile width
    final col3 = (cw - gap * s * 2) / 3;
    // Big-tile height: aspect ratio from Figma (≈96/200) applied to actual col2
    final tileH = col2 * 0.48;
    // Medium-tile height: aspect ratio from Figma (89.5/177) ≈ 0.505
    final medH = col2 * 0.505;

    return Scaffold(
      backgroundColor: const Color(0xFF0F151A),
      body: DigiBackground(
        backgroundColor: const Color(0xFF0F151A),
        logoOpacity: 0,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────────────────
                _TopBar(s: s),

                SizedBox(height: 4 * s),

                // ── Hi user ──────────────────────────────────────────────
                Center(
                  child: Text(
                    'HI, USER',
                    style: GoogleFonts.inter(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE1E1E1),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                SizedBox(height: 20 * s),

                // ── Big feature tiles (Bracelet + Challenge | C By AI) ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left col: Bracelet on top, Challenge below
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const BraceletScreen())),
                          child: SizedBox(
                            width: col2,
                            height: tileH,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SvgPicture.asset(
                                  'assets/fonts/24 bracelet.svg',
                                  fit: BoxFit.fill,
                                ),
                                // Centered artwork
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Circuit background, reduced size
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.45,
                                            heightFactor: 0.45,
                                            child: Image.asset(
                                              'assets/circuit.png',
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.low,
                                            ),
                                          ),
                                        ),
                                        // Main artwork scaled to fill the vector area
                                        FractionallySizedBox(
                                          widthFactor: 0.8,
                                          heightFactor: 0.8,
                                          child: Image.asset(
                                            'assets/fonts/24bracelet.png',
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bracelet icon top-right
                                Positioned(
                                  top: 10 * s,
                                  right: 14 * s,
                                  width: 32 * s,
                                  height: 32 * s,
                                  child: Image.asset(
                                    'assets/fonts/bracelet.png',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.low,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: gap * s),
                        GestureDetector(
                          onTap: () => _go('24 Challenge'),
                          child: SizedBox(
                            width: col2,
                            height: tileH,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SvgPicture.asset(
                                  'assets/fonts/challenge zone.svg',
                                  fit: BoxFit.fill,
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Circuit background, reduced size
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.45,
                                            heightFactor: 0.45,
                                            child: Image.asset(
                                              'assets/circuit.png',
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.low,
                                            ),
                                          ),
                                        ),
                                        // Main artwork scaled to fill the vector area
                                        FractionallySizedBox(
                                          widthFactor: 0.78,
                                          heightFactor: 0.78,
                                          child: Image.asset(
                                            'assets/fonts/challenge.png',
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10 * s,
                                  right: 14 * s,
                                  width: 28 * s,
                                  height: 28 * s,
                                  child: Image.asset(
                                    'assets/fonts/challenge_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Right col: C By AI — full height
                    GestureDetector(
                      onTap: () => _go('C By AI'),
                      child: SizedBox(
                        width: col2,
                        height: tileH * 2 + gap * s,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Vector background
                            SvgPicture.asset(
                              'assets/fonts/c by ai.svg',
                              fit: BoxFit.fill,
                            ),
                            // C by AI artwork
                            // Make artwork fill the tile more closely (larger fraction)
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 8 * s, 6 * s),
                                child: FractionallySizedBox(
                                  widthFactor: 0.95,
                                  heightFactor: 0.95,
                                  child: Image.asset(
                                    'assets/fonts/c_by_ai.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: gap * s),

                // ── Medium row: Delivery | Diet ──────────────────────────
                Row(
                  children: [
                    _ChevronTile(
                      width: col2,
                      height: medH,
                      cornerRadius: 10 * s,
                      arrowDepth: 16 * s,
                      isLeft: false,
                      onTap: () => _go('Delivery'),
                      child: _MediumTileContent(
                        s: s,
                        imagePath: 'assets/fonts/delivery.png',
                      ),
                    ),
                    // No SizedBox — interlocking chevron
                    _ChevronTile(
                      width: col2,
                      height: medH,
                      cornerRadius: 10 * s,
                      arrowDepth: 16 * s,
                      isLeft: true,
                      onTap: () => _go('24 Diet'),
                      child: _MediumTileContent(
                        s: s,
                        imagePath: 'assets/fonts/diet.png',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: gap * s),

                // ── Small 3×2 grid ────────────────────────────────────────
                _SmallGrid(
                  s: s,
                  col3: col3,
                  gap: gap,
                  onTap: _go,
                ),

                SizedBox(height: 24 * s),

                // ── Banner ad ─────────────────────────────────────
                _BannerCard(s: s, width: cw),

                SizedBox(height: 24 * s),

                // ── BMI / body stats card ─────────────────────────────────
                _BmiCard(
                  s: s,
                  width: cw,
                  heightCtrl: _heightCtrl,
                  weightCtrl: _weightCtrl,
                ),

                SizedBox(height: 20 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chevron path helper + painter + clipper + tile widget
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the chevron path used for both clip and border.
/// [isLeft]=false → right-pointing arrow on right edge (left tiles).
/// [isLeft]=true  → concave indent on left edge (C BY AI tile).
Path _chevronPath(Size size, double r, double depth, bool isLeft) {
  final w = size.width;
  final h = size.height;
  final mid = h / 2;
  if (!isLeft) {
    return Path()
      ..moveTo(r, 0)
      ..lineTo(w - depth, 0)
      ..lineTo(w, mid)
      ..lineTo(w - depth, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r),
          radius: Radius.circular(r), clockwise: false)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
  } else {
    return Path()
      ..moveTo(depth, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(depth, h)
      ..lineTo(0, mid)
      ..close();
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double arrowDepth;
  final bool isLeft;
  const _ChevronClipper({
    required this.cornerRadius,
    required this.arrowDepth,
    required this.isLeft,
  });
  @override
  Path getClip(Size size) =>
      _chevronPath(size, cornerRadius, arrowDepth, isLeft);
  @override
  bool shouldReclip(_ChevronClipper old) =>
      old.cornerRadius != cornerRadius ||
      old.arrowDepth != arrowDepth ||
      old.isLeft != isLeft;
}

class _ChevronBorderPainter extends CustomPainter {
  final double cornerRadius;
  final double arrowDepth;
  final bool isLeft;
  const _ChevronBorderPainter({
    required this.cornerRadius,
    required this.arrowDepth,
    required this.isLeft,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final path = _chevronPath(size, cornerRadius, arrowDepth, isLeft);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppGradients.smoothBorderColors,
        stops: AppGradients.smoothBorderStops,
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_ChevronBorderPainter old) =>
      old.cornerRadius != cornerRadius ||
      old.arrowDepth != arrowDepth ||
      old.isLeft != isLeft;
}

class _ChevronTile extends StatelessWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final double arrowDepth;
  final bool isLeft;
  final Widget child;
  final VoidCallback? onTap;

  const _ChevronTile({
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.arrowDepth,
    required this.isLeft,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ChevronBorderPainter(
            cornerRadius: cornerRadius,
            arrowDepth: arrowDepth,
            isLeft: isLeft,
          ),
          child: ClipPath(
            clipper: _ChevronClipper(
              cornerRadius: cornerRadius,
              arrowDepth: arrowDepth,
              isLeft: isLeft,
            ),
            child: ColoredBox(
              color: const Color(0xFF0A1520),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient-border tile base
// ─────────────────────────────────────────────────────────────────────────────

class _GTile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Widget child;
  final VoidCallback? onTap;

  const _GTile({
    required this.width,
    required this.height,
    required this.radius,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: SmoothGradientBorder(radius: radius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: ColoredBox(
              color: const Color(0xFF0A1520),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final double s;
  const _TopBar({required this.s});

  @override
  Widget build(BuildContext context) {
    final pillH = 60.0 * s;
    final radius = pillH / 2;
    return Container(
      height: pillH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00FFF0), // Neon cyan
            const Color(0xFFB16DFF), // Neon purple
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFF0).withOpacity(0.18),
            blurRadius: 16 * s,
            spreadRadius: 1 * s,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2.2 * s), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 2.2 * s),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A1520),
                const Color(0xFF1B1F2B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Back arrow
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF00FFF0),
                  size: 22 * s,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00FFF0).withOpacity(0.7),
                      blurRadius: 8 * s,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 24DIGI logo (centered)
              Image.asset(
                'assets/24 logo.png',
                height: 40 * s,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const Spacer(),
              // Avatar with neon border
              Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FFF0),
                      const Color(0xFFB16DFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB16DFF).withOpacity(0.18),
                      blurRadius: 8 * s,
                      spreadRadius: 1 * s,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.5 * s),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/fonts/male.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
                                colors: [
                                  const Color(0xFF0A1520),
                                  const Color(0xFF1B1F2B),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Back arrow
                                GestureDetector(
                                  onTap: () => Navigator.maybePop(context),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: const Color(0xFF00FFF0),
                                    size: 22 * s,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF00FFF0).withOpacity(0.7),
                                        blurRadius: 8 * s,
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // 24DIGI logo (centered)
                                Image.asset(
                                  'assets/24 logo.png',
                                  height: 40 * s,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                                const Spacer(),
                                // Avatar with neon border
                                Container(
                                  width: 44 * s,
                                  height: 44 * s,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF00FFF0),
                                        const Color(0xFFB16DFF),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB16DFF).withOpacity(0.18),
                                        blurRadius: 8 * s,
                                        spreadRadius: 1 * s,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.5 * s),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/fonts/male.png',
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
  final double col3;
  final double gap;
  final void Function(String) onTap;

  const _SmallGrid({
    required this.s,
    required this.col3,
    required this.gap,
    required this.onTap,
  });

  // (display label, route name)
  static const List<(String, String)> _items = [
    ('AI\nMODELS', 'AI Models'),
    ('24\nSHOP', '24 Shop'),
    ('WALLET', 'Wallet'),
    ('24\nHEROES', '24 Heroes'),
    ('SUBSCRIBE', 'Subscribe'),
    ('24\nDISCOVERY', '24 Discovery'),
  ];

  Widget _row(List<(String, String)> slice) {
    return Row(
      children: [
        for (int i = 0; i < slice.length; i++) ...[
          if (i > 0) SizedBox(width: gap * s),
          _SmallTile(
            s: s,
            width: col3,
            label: slice[i].$1,
            onTap: () => onTap(slice[i].$2),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(_items.sublist(0, 3)),
        SizedBox(height: gap * s),
        _row(_items.sublist(3, 6)),
      ],
    );
  }
}

class _SmallTile extends StatelessWidget {
  final double s;
  final double width;
  final String label;
  final VoidCallback onTap;

  const _SmallTile({
    required this.s,
    required this.width,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GTile(
      width: width,
      height: 76 * s,
      radius: 14 * s,
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 9 * s,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.4,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner ad
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final double s;
  final double width;
  const _BannerCard({required this.s, required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StubScreen(title: 'Banner')),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: SizedBox(
          width: width,
          // Aspect ratio from bannerad image (approx 3:1)
          height: width / 3.0,
          child: Image.asset(
            'assets/fonts/bannerad.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BMI / body stats card
// ─────────────────────────────────────────────────────────────────────────────

class _BmiCard extends StatelessWidget {
  final double s;
  final double width;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;

  const _BmiCard({
    required this.s,
    required this.width,
    required this.heightCtrl,
    required this.weightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 18 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18 * s),
          child: ColoredBox(
            color: const Color(0xFF0A1520),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16 * s, vertical: 16 * s),
              child: Row(
                children: [
                  // ── Fields ──
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BmiField(
                          s: s,
                          ctrl: heightCtrl,
                          hint: 'enter your height',
                          iconPath: 'assets/fonts/hieght.png',
                        ),
                        SizedBox(height: 12 * s),
                        _BmiField(
                          s: s,
                          ctrl: weightCtrl,
                          hint: 'enter your weight',
                          iconPath: 'assets/fonts/weight.png',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  // ── Male figure ──
                  Image.asset(
                    'assets/fonts/male.png',
                    height: 120 * s,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                  SizedBox(width: 8 * s),
                  // ── Vertical indicator bar ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6 * s),
                    child: SizedBox(
                      width: 10 * s,
                      height: 120 * s,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: const [
                              Color(0xFFFF6B8A),
                              Color(0xFFE91E63),
                              Color(0xFF880E4F),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _BmiField extends StatelessWidget {
  final double s;
  final TextEditingController ctrl;
  final String hint;
  final String iconPath;

  const _BmiField({
    required this.s,
    required this.ctrl,
    required this.hint,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: const Color(0xFF1E3040),
          width: 1.0,
        ),
        color: const Color(0xFF0A1820),
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 20 * s,
            height: 20 * s,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF8A9AA4),
              ),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF4A5A64),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



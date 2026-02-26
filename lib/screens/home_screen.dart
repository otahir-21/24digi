import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_constants.dart';
import '../painters/smooth_gradient_border.dart';
import '../widgets/digi_background.dart';

// ── Stub page imports ────────────────────────────────────────────────────────
import 'stub_screen.dart';

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
      backgroundColor: AppColors.black,
      body: DigiBackground(
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
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w300,
                      color: AppColors.labelDim,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                SizedBox(height: 20 * s),

                // ── Big feature tiles (Bracelet + Challenge | C By AI) ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left col: Bracelet on top, Challenge below — chevron arrow right
                    Column(
                      children: [
                        _ChevronTile(
                          width: col2,
                          height: tileH,
                          cornerRadius: 14 * s,
                          arrowDepth: 18 * s,
                          isLeft: false,
                          onTap: () => _go('24 Bracelet Page'),
                          child: _BraceletTileContent(s: s),
                        ),
                        SizedBox(height: gap * s),
                        _ChevronTile(
                          width: col2,
                          height: tileH,
                          cornerRadius: 14 * s,
                          arrowDepth: 18 * s,
                          isLeft: false,
                          onTap: () => _go('24 Challenge'),
                          child: _ChallengeTileContent(s: s),
                        ),
                      ],
                    ),

                    // No SizedBox — chevron arrow of left interlocks with concave indent of right
                    // Right col: C By AI — full height, concave left indent
                    _ChevronTile(
                      width: col2,
                      height: tileH * 2 + gap * s,
                      cornerRadius: 14 * s,
                      arrowDepth: 18 * s,
                      isLeft: true,
                      onTap: () => _go('C By AI'),
                      child: _CByAiTileContent(s: s),
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
              color: const Color(0xFF060E16),
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
              color: const Color(0xFF060E16),
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

    return CustomPaint(
      painter: SmoothGradientBorder(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: SizedBox(
            height: pillH,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Row(
                children: [
                  // Back arrow
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.cyan,
                      size: 20 * s,
                    ),
                  ),

                  const Spacer(),

                  // 24 logo centred
                  Image.asset(
                    'assets/24 logo.png',
                    height: 40 * s,
                    fit: BoxFit.contain,
                  ),

                  const Spacer(),

                  // Circular avatar with gradient ring
                  CustomPaint(
                    painter: SmoothGradientBorder(radius: 22 * s),
                    child: ClipOval(
                      child: SizedBox(
                        width: 42 * s,
                        height: 42 * s,
                        child: Image.asset(
                          'assets/fonts/male.png',
                          fit: BoxFit.cover,
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

// ─────────────────────────────────────────────────────────────────────────────
// 24 BRACELET tile content
// ─────────────────────────────────────────────────────────────────────────────

class _BraceletTileContent extends StatelessWidget {
  final double s;
  const _BraceletTileContent({required this.s});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 24BRACELET artwork fills entire tile (large)
        Image.asset(
          'assets/fonts/24bracelet.png',
          fit: BoxFit.fill,
        ),
        // Small bracelet device icon — top-right corner
        Positioned(
          top: 6 * s,
          right: 8 * s,
          width: 38 * s,
          height: 38 * s,
          child: Image.asset(
            'assets/fonts/bracelet.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHALLENGE ZONE tile content
// ─────────────────────────────────────────────────────────────────────────────

class _ChallengeTileContent extends StatelessWidget {
  final double s;
  const _ChallengeTileContent({required this.s});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Challenge zone artwork fills entire tile
        Image.asset(
          'assets/fonts/challenge.png',
          fit: BoxFit.fill,
        ),
        // Subtle dark vignette on top for depth
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: const [
                Color(0x00000000),
                Color(0x55000000),
              ],
            ),
          ),
        ),
        // Trophy icon — top-right with glowing container
        Positioned(
          top: 8 * s,
          right: 10 * s,
          child: Container(
            width: 36 * s,
            height: 36 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x33000000),
              border: Border.all(
                color: AppColors.cyan.withAlpha(80),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.all(6 * s),
            child: Image.asset(
              'assets/fonts/challenge_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// C BY AI tile content
// ─────────────────────────────────────────────────────────────────────────────

class _CByAiTileContent extends StatelessWidget {
  final double s;
  const _CByAiTileContent({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 10 * s, 4 * s),
            child: Image.asset(
              'assets/fonts/c_by_ai.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 14 * s),
          child: Text(
            'BY AI',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 15 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan,
              letterSpacing: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Medium tile content (Delivery / Diet)
// ─────────────────────────────────────────────────────────────────────────────

class _MediumTileContent extends StatelessWidget {
  final double s;
  final String imagePath;

  const _MediumTileContent({
    required this.s,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.fill,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small 3×2 grid
// ─────────────────────────────────────────────────────────────────────────────

class _SmallGrid extends StatelessWidget {
  final double s;
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
            color: const Color(0xFF06101A),
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



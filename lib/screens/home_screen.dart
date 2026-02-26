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
    const gap = 8.0;

    // Available content width inside horizontal padding
    final cw = mq.size.width - hPad * 2;
    // 2-column tile width
    final col2 = (cw - gap * s) / 2;
    // 3-column tile width
    final col3 = (cw - gap * s * 2) / 3;

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

                SizedBox(height: 16 * s),

                // ── Big feature tiles (Bracelet + Challenge | C By AI) ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left col: Bracelet on top, Challenge below — chevron arrow right
                    Column(
                      children: [
                        _ChevronTile(
                          width: col2,
                          height: 128 * s,
                          cornerRadius: 14 * s,
                          arrowDepth: 18 * s,
                          isLeft: false,
                          onTap: () => _go('24 Bracelet Page'),
                          child: _BraceletTileContent(s: s),
                        ),
                        SizedBox(height: gap * s),
                        _ChevronTile(
                          width: col2,
                          height: 128 * s,
                          cornerRadius: 14 * s,
                          arrowDepth: 18 * s,
                          isLeft: false,
                          onTap: () => _go('24 Challenge'),
                          child: _ChallengeTileContent(s: s),
                        ),
                      ],
                    ),

                    SizedBox(width: 2 * s),

                    // Right col: C By AI — full height, concave left indent
                    _ChevronTile(
                      width: col2,
                      height: 128 * s * 2 + gap * s,
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
                    _GTile(
                      width: col2,
                      height: 82 * s,
                      radius: 14 * s,
                      onTap: () => _go('Delivery'),
                      child: _MediumTileContent(
                        s: s,
                        label: 'DELIVERY',
                        imagePath: 'assets/fonts/delivery.png',
                      ),
                    ),
                    SizedBox(width: gap * s),
                    _GTile(
                      width: col2,
                      height: 82 * s,
                      radius: 14 * s,
                      onTap: () => _go('24 Diet'),
                      child: _MediumTileContent(
                        s: s,
                        label: '24 DIET',
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

                SizedBox(height: 14 * s),

                // ── Banner ad ─────────────────────────────────────────────
                _BannerCard(s: s, width: cw),

                SizedBox(height: 14 * s),

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
      children: [
        // Small bracelet device icon — top-right
        Positioned(
          top: 8 * s,
          right: 28 * s,
          child: Image.asset(
            'assets/fonts/bracelet.png',
            width: 34 * s,
            height: 34 * s,
            fit: BoxFit.contain,
          ),
        ),
        // Text — left
        Padding(
          padding: EdgeInsets.only(
              left: 12 * s, top: 12 * s, bottom: 12 * s, right: 38 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '24',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 38 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                'BRACELET',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cyan,
                  letterSpacing: 0.8,
                ),
              ),
            ],
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
      children: [
        // Small trophy/challenge icon — top-right
        Positioned(
          top: 8 * s,
          right: 28 * s,
          child: Image.asset(
            'assets/fonts/challenge.png',
            width: 30 * s,
            height: 30 * s,
            fit: BoxFit.contain,
          ),
        ),
        // Text — left
        Padding(
          padding: EdgeInsets.only(
              left: 12 * s, top: 12 * s, bottom: 12 * s, right: 38 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CHALLENGE',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'ZONE',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
  final String label;
  final String imagePath;
  const _MediumTileContent({
    required this.s,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 4 * s,
          top: 0,
          bottom: 0,
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: SizedBox(
        width: width,
        height: 110 * s,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/fonts/bannerad.png',
              fit: BoxFit.cover,
            ),
            // Dark gradient overlay on left
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xDD020A10),
                    Color(0x88020A10),
                    Color(0x00020A10),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Text overlay
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 14 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'UNLOCK YOUR',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'POTENTIAL.',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Row(
                    children: [
                      Image.asset(
                        'assets/24 logo.png',
                        height: 14 * s,
                      ),
                      const Spacer(),
                      _LearnMoreButton(s: s),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnMoreButton extends StatelessWidget {
  final double s;
  const _LearnMoreButton({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 12 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * s),
        color: AppColors.cyan,
      ),
      child: Text(
        'Learn More',
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black,
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



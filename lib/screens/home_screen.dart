import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/bracelet/bracelet_channel.dart';
import 'package:kivi_24/screens/bracelet/bracelet_screen.dart';
import 'package:kivi_24/screens/bracelet/bracelet_search_screen.dart';

import '../core/app_constants.dart';
import '../painters/smooth_gradient_border.dart';
import '../widgets/digi_background.dart';

import 'stub_screen.dart';

// ── Figma design constants. Canvas locked to 375pt. No scaling. ─────────────────
abstract class _Figma {
  static const double designW = 375.0;

  static const double hPad = 16.0;
  static const double topBarHeight = 60.0;
  static const double topBarRadius = 30.0;
  static const double topBarStroke = 2.0;
  static const double gapAfterTopBar = 6.0;
  static const double hiUserFontSize = 14.0;
  static const double hiUserLetterSpacing = 2.0;
  static const double gapAfterHiUser = 12.0;

  static const double bigTileHeight = 96.0;
  static const double gapBetweenLeftTiles = 8.0;
  static const double cByAiHeight =
      200.0; // exact: bigTileHeight + gap + bigTileHeight

  static const double bigTileContentPadLeft = 10.0;
  static const double bigTileContentPadRight = 6.0;
  static const double bigTileContentPadVertical = 4.0;
  static const double bigTileIconSize = 48.0;
  static const double bigTileIconInset = 8.0;

  static const double gapAfterBigRow = 12.0;

  static const double medTileHeight = 90.0;
  static const double chevronCornerRadius = 10.0;
  static const double chevronArrowDepth =
      17.0; // tuned so edges touch with no gap
  static const double chevronStrokeWidth = 1.5;

  static const double gapAfterMedRow = 12.0;

  static const double smallTileHeight = 76.0;
  static const double smallTileRadius = 14.0;
  static const double smallGridGap = 10.0;
  static const double smallTileFontSize = 9.0;

  static const double gapAfterGrid = 28.0;
  static const double bannerRadius = 16.0;
  static const double bannerHeight = 120.0;
  static const double gapAfterBanner = 28.0;
  static const double bannerTextTop = 16.0;
  static const double bannerTextLeft = 16.0;
  static const double bannerSubBottom = 40.0;
  static const double bannerBtnBottom = 14.0;
  static const double bannerBtnRight = 14.0;

  static const double bmiCardRadius = 18.0;
  static const double bmiCardPaddingH = 16.0;
  static const double bmiCardPaddingV = 16.0;
  static const double bmiFieldRadius = 10.0;
  static const double bmiFieldBorderWidth = 1.0;
  static const double gapAfterBmi = 24.0;

  static const double scrollVerticalPad = 18.0;

  static const double topBarLogoHeight = 40.0;
  static const double topBarAvatarSize = 44.0;
  static const double topBarAvatarStroke = 2.5;
  static const double topBarIconSize = 22.0;
  static const double topBarShadowBlur = 10.0;
  static const double topBarShadowSpread = 0.0;
  static const int topBarShadowAlpha = 38;
  static const double topBarIconShadowBlur = 6.0;
  static const int topBarIconShadowAlpha = 178;

  static const double hiUserShadowBlur = 8.0;
  static const int hiUserShadowAlpha = 80;

  static const double smallTileShadowBlur = 12.0;
  static const int smallTileShadowAlpha = 140;

  static const double medTileContentPad = 10.0;

  // Content width at 375pt (no scaling)
  static const double contentW = 343.0; // designW - hPad*2
  static const double col2 = 171.0; // contentW/2 floored
  static const double col3 = 107.0; // (contentW - smallGridGap*2)/3 floored
}

// ── C BY AI CARD (244.636 x 194.559 Figma). Own layers only. No reuse. ─────────
class _CByAiCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _CByAiCard({
    required this.width,
    required this.height,
    required this.child,
  });

  static const double _strokeWidth = 2.463;
  static const Color _strokeColor = Color(0xFF00F0FF);
  static const double _blurSigma = 32.83;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: RadialGradient pink
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(1.13, 0.76),
                    radius: 1.2,
                    colors: [
                      Color.fromRGBO(255, 53, 130, 0.08),
                      Color.fromRGBO(255, 75, 149, 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Layer 2: RadialGradient cyan
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4, -0.2),
                    radius: 1.2,
                    colors: [
                      Color.fromRGBO(51, 255, 232, 0.10),
                      Color.fromRGBO(110, 191, 244, 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Layer 3: BackdropFilter blur
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurSigma,
                    sigmaY: _blurSigma,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            child,
            // Border: exact stroke
            Positioned.fill(
              child: CustomPaint(
                painter: _CByAiCardBorderPainter(
                  strokeWidth: _strokeWidth,
                  strokeColor: _strokeColor,
                  radius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CByAiCardBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color strokeColor;
  final double radius;

  _CByAiCardBorderPainter({
    required this.strokeWidth,
    required this.strokeColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── CHALLENGE ZONE CARD (181.424 x 89.088). Own layers. No border. No C BY AI reuse. ─
class _ChallengeZoneCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _ChallengeZoneCard({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: LinearGradient rgba(90,137,153,0.10)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(90, 137, 153, 0.10),
                      Color.fromRGBO(90, 137, 153, 0.10),
                    ],
                  ),
                ),
              ),
            ),
            // Layer 2: RadialGradient pink glow bottom-right
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(1.2, 1.2),
                    radius: 0.9,
                    colors: [
                      Color.fromRGBO(255, 100, 150, 0.12),
                      Color.fromRGBO(255, 80, 140, 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Layer 3: RadialGradient cyan glow top-left
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    radius: 0.8,
                    colors: [
                      Color.fromRGBO(51, 255, 232, 0.14),
                      Color.fromRGBO(100, 220, 240, 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ── 24 BRACELET CARD. Same layered style as Challenge Zone + border stroke. ─────
class _Bracelet24Card extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _Bracelet24Card({
    required this.width,
    required this.height,
    required this.child,
  });

  static const double _strokeWidth = 2.463;
  static const Color _strokeColor = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: LinearGradient (same as Challenge Zone card, not C BY AI)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(90, 137, 153, 0.10),
                      Color.fromRGBO(90, 137, 153, 0.10),
                    ],
                  ),
                ),
              ),
            ),
            // Layer 2: RadialGradient pink bottom-right
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(1.2, 1.2),
                    radius: 0.9,
                    colors: [
                      Color.fromRGBO(255, 100, 150, 0.12),
                      Color.fromRGBO(255, 80, 140, 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Layer 3: RadialGradient cyan top-left
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    radius: 0.8,
                    colors: [
                      Color.fromRGBO(51, 255, 232, 0.14),
                      Color.fromRGBO(100, 220, 240, 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child,
            // Border: 2.463px #00F0FF
            Positioned.fill(
              child: CustomPaint(
                painter: _Bracelet24CardBorderPainter(
                  strokeWidth: _strokeWidth,
                  strokeColor: _strokeColor,
                  radius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bracelet24CardBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color strokeColor;
  final double radius;

  _Bracelet24CardBorderPainter({
    required this.strokeWidth,
    required this.strokeColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: DigiBackground(
        backgroundColor: const Color(0xFF0A0E12),
        circuitOpacity: 0.5,
        circuitHeightFactor: 0.42,
        logoOpacity: 0,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: _Figma.hPad,
              vertical: _Figma.scrollVerticalPad,
            ),
            child: Center(
              child: SizedBox(
                width: _Figma.designW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(),

                    SizedBox(height: _Figma.gapAfterTopBar),

                    Center(
                      child: Text(
                        'HI, USER',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: _Figma.hiUserFontSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: _Figma.hiUserLetterSpacing,
                          shadows: [
                            Shadow(
                              color: AppColors.cyan.withAlpha(
                                _Figma.hiUserShadowAlpha,
                              ),
                              blurRadius: _Figma.hiUserShadowBlur,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: _Figma.gapAfterHiUser),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final state = await BraceletChannel().getConnectionState();
                                if (!context.mounted) return;
                                final connected = state['connected'] == true;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => connected
                                        ? const BraceletScreen()
                                        : const BraceletSearchScreen(),
                                  ),
                                );
                              },
                              child: _Bracelet24Card(
                                width: _Figma.col2,
                                height: _Figma.bigTileHeight,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: _Figma.bigTileContentPadLeft,
                                          right: _Figma.bigTileContentPadRight,
                                          top: _Figma.bigTileContentPadVertical,
                                          bottom:
                                              _Figma.bigTileContentPadVertical,
                                        ),
                                        child: Image.asset(
                                          'assets/fonts/24bracelet.png',
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: _Figma.bigTileIconInset,
                                      right: _Figma.bigTileIconInset,
                                      child: SizedBox(
                                        width: _Figma.bigTileIconSize,
                                        height: _Figma.bigTileIconSize,
                                        child: Image.asset(
                                          'assets/fonts/bracelet.png',
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: _Figma.gapBetweenLeftTiles),
                            GestureDetector(
                              onTap: () => _go('24 Challenge'),
                              child: _ChallengeZoneCard(
                                width: _Figma.col2,
                                height: _Figma.bigTileHeight,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              _Figma.bigTileContentPadRight,
                                          vertical:
                                              _Figma.bigTileContentPadVertical,
                                        ),
                                        child: Image.asset(
                                          'assets/fonts/challenge.png',
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: _Figma.bigTileIconInset,
                                      left: _Figma.bigTileContentPadLeft,
                                      child: SizedBox(
                                        width: _Figma.bigTileIconSize,
                                        height: _Figma.bigTileIconSize,
                                        child: Image.asset(
                                          'assets/fonts/challenge_icon.png',
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _go('C By AI'),
                          child: _CByAiCard(
                            width: _Figma.col2,
                            height: _Figma.cByAiHeight,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                _Figma.bigTileContentPadLeft,
                                _Figma.bigTileIconInset,
                                _Figma.bigTileContentPadRight,
                                _Figma.bigTileIconInset,
                              ),
                              child: Image.asset(
                                'assets/fonts/c_by_ai.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: _Figma.gapAfterBigRow),

                    Row(
                      children: [
                        _DeliveryChevronCard(
                          width: _Figma.col2,
                          height: _Figma.medTileHeight,
                          onTap: () => _go('Delivery'),
                        ),
                        _DietChevronCard(
                          width: _Figma.col2,
                          height: _Figma.medTileHeight,
                          onTap: () => _go('24 Diet'),
                        ),
                      ],
                    ),

                    SizedBox(height: _Figma.gapAfterMedRow),

                    _SmallGrid(
                      col3: _Figma.col3,
                      gap: _Figma.smallGridGap,
                      onTap: _go,
                    ),

                    SizedBox(height: _Figma.gapAfterGrid),

                    _BannerCard(width: _Figma.contentW),

                    SizedBox(height: _Figma.gapAfterBanner),

                    _BmiCard(
                      width: _Figma.contentW,
                      heightCtrl: _heightCtrl,
                      weightCtrl: _weightCtrl,
                    ),

                    SizedBox(height: _Figma.gapAfterBmi),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      ..arcToPoint(
        Offset(0, h - r),
        radius: Radius.circular(r),
        clockwise: false,
      )
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
  final double strokeWidth;
  final bool isLeft;
  final Color? strokeColor;
  const _ChevronBorderPainter({
    required this.cornerRadius,
    required this.arrowDepth,
    required this.strokeWidth,
    required this.isLeft,
    this.strokeColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final path = _chevronPath(size, cornerRadius, arrowDepth, isLeft);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    if (strokeColor != null) {
      paint.color = strokeColor!;
    } else {
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppGradients.smoothBorderColors,
        stops: AppGradients.smoothBorderStops,
      ).createShader(Offset.zero & size);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronBorderPainter old) =>
      old.cornerRadius != cornerRadius ||
      old.arrowDepth != arrowDepth ||
      old.strokeWidth != strokeWidth ||
      old.isLeft != isLeft ||
      old.strokeColor != strokeColor;
}

// ── Delivery chevron card: Figma fill + stroke 2.463 #00F0FF ───────────────────
class _DeliveryChevronCard extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _DeliveryChevronCard({
    required this.width,
    required this.height,
    this.onTap,
  });

  static const double _strokeWidth = 2.463;
  static const Color _strokeColor = Color(0xFF00F0FF);
  static const double _cornerRadius = 10.0;
  static const double _arrowDepth = 17.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ChevronBorderPainter(
            cornerRadius: _cornerRadius,
            arrowDepth: _arrowDepth,
            strokeWidth: _strokeWidth,
            isLeft: false,
            strokeColor: _strokeColor,
          ),
          child: ClipPath(
            clipper: _ChevronClipper(
              cornerRadius: _cornerRadius,
              arrowDepth: _arrowDepth,
              isLeft: false,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromRGBO(90, 137, 153, 0.10),
                          Color.fromRGBO(90, 137, 153, 0.10),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.067, 0.885),
                        radius: 1.25,
                        colors: [
                          Color.fromRGBO(255, 53, 130, 0.10),
                          Color.fromRGBO(255, 75, 149, 0.04),
                          Color.fromRGBO(255, 88, 160, 0.00),
                        ],
                        stops: const [0.0, 0.7596, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.4046, -0.4836),
                        radius: 1.55,
                        colors: [
                          Color.fromRGBO(51, 255, 232, 0.10),
                          Color.fromRGBO(110, 191, 244, 0.02),
                          Color.fromRGBO(70, 144, 212, 0.00),
                        ],
                        stops: const [0.0, 0.7708, 1.0],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(_Figma.medTileContentPad),
                    child: Image.asset(
                      'assets/fonts/delivery.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 24 Diet chevron card: Figma fill + stroke 2.463 #00F0FF ────────────────────
class _DietChevronCard extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _DietChevronCard({
    required this.width,
    required this.height,
    this.onTap,
  });

  static const double _strokeWidth = 2.463;
  static const Color _strokeColor = Color(0xFF00F0FF);
  static const double _cornerRadius = 10.0;
  static const double _arrowDepth = 17.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ChevronBorderPainter(
            cornerRadius: _cornerRadius,
            arrowDepth: _arrowDepth,
            strokeWidth: _strokeWidth,
            isLeft: true,
            strokeColor: _strokeColor,
          ),
          child: ClipPath(
            clipper: _ChevronClipper(
              cornerRadius: _cornerRadius,
              arrowDepth: _arrowDepth,
              isLeft: true,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromRGBO(90, 137, 153, 0.10),
                          Color.fromRGBO(90, 137, 153, 0.10),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.32, 0.885),
                        radius: 1.13,
                        colors: [
                          Color.fromRGBO(255, 53, 130, 0.10),
                          Color.fromRGBO(255, 75, 149, 0.04),
                          Color.fromRGBO(255, 88, 160, 0.00),
                        ],
                        stops: const [0.0, 0.7596, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.0228, -0.4836),
                        radius: 1.38,
                        colors: [
                          Color.fromRGBO(51, 255, 232, 0.10),
                          Color.fromRGBO(110, 191, 244, 0.02),
                          Color.fromRGBO(70, 144, 212, 0.00),
                        ],
                        stops: const [0.0, 0.7708, 1.0],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(_Figma.medTileContentPad),
                    child: Image.asset(
                      'assets/fonts/diet.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronTile extends StatelessWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final double arrowDepth;
  final double strokeWidth;
  final bool isLeft;
  final Widget child;
  final VoidCallback? onTap;

  const _ChevronTile({
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.arrowDepth,
    required this.strokeWidth,
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
            strokeWidth: strokeWidth,
            isLeft: isLeft,
          ),
          child: ClipPath(
            clipper: _ChevronClipper(
              cornerRadius: cornerRadius,
              arrowDepth: arrowDepth,
              isLeft: isLeft,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1520), Color(0xFF1B1F2B)],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

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
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1520), Color(0xFF1B1F2B)],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _Figma.topBarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_Figma.topBarRadius),
        gradient: const LinearGradient(
          colors: [Color(0xFF00FFF0), Color(0xFFB16DFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFF0).withAlpha(_Figma.topBarShadowAlpha),
            blurRadius: _Figma.topBarShadowBlur,
            spreadRadius: _Figma.topBarShadowSpread,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_Figma.topBarStroke),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              _Figma.topBarRadius - _Figma.topBarStroke,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1520), Color(0xFF1B1F2B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF00FFF0),
                  size: _Figma.topBarIconSize,
                  shadows: [
                    Shadow(
                      color: const Color(
                        0xFF00FFF0,
                      ).withAlpha(_Figma.topBarIconShadowAlpha),
                      blurRadius: _Figma.topBarIconShadowBlur,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/24 logo.png',
                height: _Figma.topBarLogoHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Log out',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.labelDim,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                width: _Figma.topBarAvatarSize,
                height: _Figma.topBarAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFF0), Color(0xFFB16DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFB16DFF,
                      ).withAlpha(_Figma.topBarShadowAlpha),
                      blurRadius: _Figma.topBarIconShadowBlur,
                      spreadRadius: _Figma.topBarShadowSpread,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(_Figma.topBarAvatarStroke),
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
}

class _MediumTileContent extends StatelessWidget {
  final double padding;
  final String imagePath;

  const _MediumTileContent({required this.padding, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _SmallGrid extends StatelessWidget {
  final double col3;
  final double gap;
  final void Function(String) onTap;

  const _SmallGrid({
    required this.col3,
    required this.gap,
    required this.onTap,
  });

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
          if (i > 0) SizedBox(width: gap),
          _SmallTile(
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
        SizedBox(height: gap),
        _row(_items.sublist(3, 6)),
      ],
    );
  }
}

class _SmallTile extends StatelessWidget {
  final double width;
  final String label;
  final VoidCallback onTap;

  const _SmallTile({
    required this.width,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GTile(
      width: width,
      height: _Figma.smallTileHeight,
      radius: _Figma.smallTileRadius,
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: _Figma.smallTileFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.4,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: AppColors.cyan.withAlpha(_Figma.smallTileShadowAlpha),
                blurRadius: _Figma.smallTileShadowBlur,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final double width;

  const _BannerCard({required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StubScreen(title: 'Banner')),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_Figma.bannerRadius),
        child: SizedBox(
          width: width,
          height: _Figma.bannerHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/fonts/bannerad.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(60),
                        Colors.transparent,
                        Colors.black.withAlpha(120),
                      ],
                      stops: const [0.0, 0.4, 1.0],
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
}

class _BmiCard extends StatelessWidget {
  final double width;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;

  const _BmiCard({
    required this.width,
    required this.heightCtrl,
    required this.weightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: _Figma.bmiCardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_Figma.bmiCardRadius),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A1520), Color(0xFF0F1820)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _Figma.bmiCardPaddingH,
                vertical: _Figma.bmiCardPaddingV,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BmiField(
                          ctrl: heightCtrl,
                          hint: 'enter your height',
                          iconPath: 'assets/fonts/hieght.png',
                        ),
                        const SizedBox(height: 12.0),
                        _BmiField(
                          ctrl: weightCtrl,
                          hint: 'enter your weight',
                          iconPath: 'assets/fonts/weight.png',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Image.asset(
                    'assets/fonts/male.png',
                    height: 120.0,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: SizedBox(
                      width: 10.0,
                      height: 120.0,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFFFFB6C1),
                              Color(0xFFFF69B4),
                              Color(0xFFFF1493),
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
  final TextEditingController ctrl;
  final String hint;
  final String iconPath;

  const _BmiField({
    required this.ctrl,
    required this.hint,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_Figma.bmiFieldRadius),
        border: Border.all(
          color: AppColors.cyan.withAlpha(90),
          width: _Figma.bmiFieldBorderWidth,
        ),
        color: const Color(0xFF0A1820),
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 20.0,
            height: 20.0,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF8A9AA4),
              ),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 12.0,
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

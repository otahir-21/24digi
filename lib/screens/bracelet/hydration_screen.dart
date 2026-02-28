import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HydrationScreen
// ─────────────────────────────────────────────────────────────────────────────
class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _periodIndex = 0; // 0=Daily 1=Weekly 2=Monthly

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ──────────────────────────────────────────
                _TopBar(s: s),
                SizedBox(height: 6 * s),

                // ── HI, USER ─────────────────────────────────────────
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

                // ── Current Hydration Level + person ─────────────────
                _HydrationTopCard(
                  s: s,
                  hydrationPercent: -1.0,
                  currentLiters: -1.0,
                  goalLiters: -1.0,
                ),
                SizedBox(height: 16 * s),

                // ── Water gauge card ──────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GaugeCard(s: s, cw: cw),
                ),
                SizedBox(height: 14 * s),

                // ── Period toggle ─────────────────────────────────────
                _PeriodToggle(
                  s: s,
                  selected: _periodIndex,
                  onTap: (i) => setState(() => _periodIndex = i),
                ),
                SizedBox(height: 14 * s),

                // ── Daily Graph card ──────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GraphCard(s: s, cw: cw, period: _periodIndex),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight card ───────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _AiInsightCard(s: s),
                ),
                SizedBox(height: 24 * s),
              ],
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
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.cyan, size: 20 * s),
                  ),
                  const Spacer(),
                  Image.asset('assets/24 logo.png',
                      height: 40 * s, fit: BoxFit.contain),
                  const Spacer(),
                  CustomPaint(
                    painter: SmoothGradientBorder(radius: 22 * s),
                    child: ClipOval(
                      child: SizedBox(
                        width: 42 * s,
                        height: 42 * s,
                        child: Image.asset('assets/fonts/male.png',
                            fit: BoxFit.cover),
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
// Gradient-border card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  const _BorderCard({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hydration top card: header + neon pills + person painter
// ─────────────────────────────────────────────────────────────────────────────
class _HydrationTopCard extends StatelessWidget {
  final double s;
  final double hydrationPercent;
  final double currentLiters;
  final double goalLiters;
  const _HydrationTopCard({
    required this.s,
    required this.hydrationPercent,
    required this.currentLiters,
    required this.goalLiters,
  });

  @override
  Widget build(BuildContext context) {
    final p = hydrationPercent.clamp(0.0, 1.0);
    final percentText = (p * 100).round();

    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
            color: const Color(0xFF00F0FF).withAlpha(40), width: 1),
      ),
      child: Row(
        children: [
          // ── LEFT stats ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Hydration Level',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13 * s,
                  ),
                ),
                SizedBox(height: 12 * s),
                _NeonPill(
                  s: s,
                  height: 54 * s,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: Row(
                      children: [
                        Text(
                          '% ',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18 * s,
                          ),
                        ),
                        Text(
                          '$percentText',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26 * s,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Progress Towards Goal',
                  style: GoogleFonts.inter(
                    color: AppColors.labelDim,
                    fontSize: 11 * s,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 8 * s),
                _NeonPill(
                  s: s,
                  height: 52 * s,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${currentLiters.toStringAsFixed(1)}L / ${goalLiters.toStringAsFixed(1)}L',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18 * s,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14 * s),
          // ── RIGHT person ──
          HydrationBodyWidget(
            progress: p,
            size: 220 * s,
          ),
        ],
      ),
    );
  }
}

// Neon bordered pill container
class _NeonPill extends StatelessWidget {
  final double s;
  final Widget child;
  final double height;
  const _NeonPill(
      {required this.s, required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * s),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1320), Color(0xFF0D1A2A)],
        ),
        border: Border.all(
          color: const Color(0xFF00F0FF).withAlpha(140),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withAlpha(46),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hydration body widget: SVG-path silhouette with wave fill
// ─────────────────────────────────────────────────────────────────────────────
class HydrationBodyWidget extends StatelessWidget {
  final double progress;
  final double size;

  const HydrationBodyWidget({
    super.key,
    required this.progress,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // SVG canvas: body=173×292, head=89.9×89.9 placed above body
    // Combined logical canvas: 173 wide, 380 tall (head@y=0, body@y=88)
    return SizedBox(
      width: size * 0.455,  // 173/380
      height: size,
      child: CustomPaint(
        painter: _HydrationBodyPainter(progress: progress),
      ),
    );
  }
}

class _HydrationBodyPainter extends CustomPainter {
  final double progress;
  _HydrationBodyPainter({required this.progress});

  // SVG logical dimensions
  static const double _svgW = 173;
  static const double _svgH = 380; // head(88) + body(292)
  static const double _bodyOffsetY = 88; // body starts at this y in combined canvas

  // Head circle: center ~(44.95, 44.95), r~41.45 in its own 89.9×89.9 space
  // Centered in 173-wide canvas: translate x by (173/2 - 44.95) = 41.55
  static final Path _headPath = parseSvgPathData(
    'M44.9546 86.4093C67.8494 86.4093 86.4093 67.8494 86.4093 44.9546'
    'C86.4093 22.0599 67.8494 3.5 44.9546 3.5C22.0599 3.5 3.5 22.0599'
    ' 3.5 44.9546C3.5 67.8494 22.0599 86.4093 44.9546 86.4093Z',
  );

  static final Path _bodyPath = parseSvgPathData(
    'M121.942 3.5H50.8767C38.323 3.5371 26.2941 8.54048 17.4173 17.4173'
    'C8.54048 26.2941 3.5371 38.323 3.5 50.8767V130.47C3.5 138.501 9.74041'
    ' 145.334 17.7648 145.623C19.7535 145.695 21.7363 145.366 23.5949 144.655'
    'C25.4535 143.944 27.1497 142.866 28.5822 141.485C30.0146 140.103 31.1539'
    ' 138.448 31.9319 136.616C32.71 134.784 33.1108 132.815 33.1105 130.825'
    'V56.9987C33.0916 55.4709 33.6511 53.9924 34.6766 52.8597C35.7022 51.7271'
    ' 37.118 51.024 38.6402 50.8915C39.4503 50.8377 40.2627 50.9511 41.0272'
    ' 51.2245C41.7916 51.498 42.4916 51.9256 43.0838 52.481C43.6759 53.0364'
    ' 44.1476 53.7076 44.4694 54.4529C44.7913 55.1982 44.9564 56.0018 44.9546'
    ' 56.8136V270.734C44.9546 275.25 46.7484 279.581 49.9414 282.774C53.1344'
    ' 285.967 57.4651 287.76 61.9806 287.76C66.4962 287.76 70.8269 285.967'
    ' 74.0199 282.774C77.2129 279.581 79.0067 275.25 79.0067 270.734V165.129'
    'C78.9804 163.217 79.6776 161.366 80.9583 159.947C82.2391 158.527 84.009'
    ' 157.644 85.9133 157.474C86.9263 157.406 87.9425 157.547 88.8987 157.889'
    'C89.8549 158.23 90.7306 158.765 91.4714 159.459C92.2122 160.153 92.8023'
    ' 160.993 93.2049 161.925C93.6076 162.857 93.8142 163.862 93.8119 164.877'
    'V270.734C93.8119 275.25 95.6057 279.581 98.7987 282.774C101.992 285.967'
    ' 106.322 287.76 110.838 287.76C115.353 287.76 119.684 285.967 122.877'
    ' 282.774C126.07 279.581 127.864 275.25 127.864 270.734V56.9987C127.845'
    ' 55.4709 128.405 53.9924 129.43 52.8597C130.456 51.7271 131.871 51.024'
    ' 133.394 50.8915C134.204 50.8377 135.016 50.9511 135.781 51.2245C136.545'
    ' 51.498 137.245 51.9256 137.837 52.481C138.429 53.0364 138.901 53.7076'
    ' 139.223 54.4529C139.545 55.1982 139.71 56.0018 139.708 56.8136V130.484'
    'C139.708 138.516 145.948 145.349 153.973 145.638C155.963 145.71 157.947'
    ' 145.381 159.806 144.669C161.666 143.957 163.363 142.877 164.796 141.494'
    'C166.228 140.112 167.367 138.454 168.144 136.621C168.921 134.787 169.321'
    ' 132.816 169.319 130.825V50.8767C169.281 38.323 164.278 26.2941 155.401'
    ' 17.4173C146.524 8.54048 134.495 3.5371 121.942 3.5Z',
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final scaleX = size.width / _svgW;
    final scaleY = size.height / _svgH;

    // Scale + position head: center it in the 173-wide canvas, place at top
    final headMatrix = Matrix4.identity()
      ..translate(41.55 * scaleX, 0.0)
      ..scale(scaleX, scaleY);
    final scaledHead =
        _headPath.transform(headMatrix.storage);

    // Scale + position body: shifted down by _bodyOffsetY in SVG space
    final bodyMatrix = Matrix4.identity()
      ..translate(0.0, _bodyOffsetY * scaleY)
      ..scale(scaleX, scaleY);
    final scaledBody =
        _bodyPath.transform(bodyMatrix.storage);

    // Combine both into one path for clipping + outline
    final combinedPath = Path.combine(
        PathOperation.union, scaledHead, scaledBody);

    // ── Water fill clipped to combined silhouette ──
    canvas.save();
    canvas.clipPath(combinedPath);

    final waterLevel = size.height - (size.height * progress.clamp(0.0, 1.0));
    final wavePath = Path()..moveTo(0, waterLevel);
    for (double i = 0; i <= size.width; i++) {
      wavePath.lineTo(
          i, waterLevel + math.sin((i / size.width * 2 * math.pi)) * 6 * scaleY);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    canvas.drawPath(wavePath,
        Paint()..color = const Color(0xFF35B1DC));

    // Shimmer on wave crest
    final crestPath = Path()..moveTo(0, waterLevel);
    for (double i = 0; i <= size.width; i++) {
      crestPath.lineTo(
          i, waterLevel + math.sin((i / size.width * 2 * math.pi)) * 6 * scaleY);
    }
    canvas.drawPath(
      crestPath,
      Paint()
        ..color = Colors.white.withAlpha(90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();

    // ── Outline on top ──
    canvas.drawPath(
      combinedPath,
      Paint()
        ..color = const Color(0xFF2B3143)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 * scaleX
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HydrationBodyPainter old) =>
      old.progress != progress;
}

class _BodyProgressPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color outlineColor;

  const _BodyProgressPainter({
    required this.progress,
    required this.fillColor,
    required this.outlineColor,
  });

  /// Builds the full outer silhouette as a single closed path.
  /// The shape: head circle, neck, shoulders, arms (hanging at sides with a
  /// small gap from the torso), torso, two separate legs with rounded feet.
  Path _buildBodyPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // ── Head ──
    final headCx = w * 0.50;
    final headCy = h * 0.085;
    final headR  = w * 0.145;
    path.addOval(Rect.fromCircle(center: Offset(headCx, headCy), radius: headR));

    // ── Neck ──
    final neckW = w * 0.12;
    path.addRect(Rect.fromCenter(
      center: Offset(headCx, h * 0.175),
      width: neckW,
      height: h * 0.04,
    ));

    // ── Torso (rounded rect) ──
    final torsoL = w * 0.22;
    final torsoR = w * 0.78;
    final torsoT = h * 0.19;
    final torsoB = h * 0.52;
    final tCorner = w * 0.09;
    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTRB(torsoL, torsoT, torsoR, torsoB),
      topLeft: Radius.circular(tCorner),
      topRight: Radius.circular(tCorner),
      bottomLeft: Radius.circular(tCorner * 0.6),
      bottomRight: Radius.circular(tCorner * 0.6),
    ));

    // ── Left arm ── (slightly separated from torso)
    final armW   = w * 0.11;
    final armGap = w * 0.025;
    final armT   = h * 0.215;
    final armB   = h * 0.48;
    final armR2  = armW / 2;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(torsoL - armW - armGap, armT, armW, armB - armT),
      Radius.circular(armR2),
    ));

    // ── Right arm ──
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(torsoR + armGap, armT, armW, armB - armT),
      Radius.circular(armR2),
    ));

    // ── Left leg ──
    final legGap   = w * 0.035;
    final legW     = (torsoR - torsoL - legGap) / 2;
    final legT     = h * 0.535;
    final legB     = h * 0.98;
    final legR     = legW / 2;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(torsoL + w * 0.02, legT, legW, legB - legT),
      Radius.circular(legR),
    ));

    // ── Right leg ──
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(torsoR - legW - w * 0.02, legT, legW, legB - legT),
      Radius.circular(legR),
    ));

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPath = _buildBodyPath(size);
    final strokeW = size.width * 0.038;
    final waterY = size.height * (1.0 - progress.clamp(0.0, 1.0));

    // 1. Wave fill path clipped to body
    canvas.save();
    canvas.clipPath(bodyPath);

    // Build wave path: wavy top edge at waterY, filled down to bottom
    final wavePath = Path();
    wavePath.moveTo(0, waterY);
    final waveAmp = size.height * 0.018;
    final waveLen = size.width / 2;
    double x = 0;
    while (x <= size.width) {
      final y1 = waterY - waveAmp * math.sin((x / waveLen) * math.pi);
      final y2 = waterY - waveAmp * math.sin(((x + waveLen / 2) / waveLen) * math.pi);
      wavePath.cubicTo(
        x + waveLen / 4, y1,
        x + waveLen * 3 / 4, y2,
        x + waveLen, waterY,
      );
      x += waveLen;
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, Paint()..color = fillColor);

    // Subtle wave crest glow
    final waveCrestPaint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final crestPath = Path();
    crestPath.moveTo(0, waterY);
    x = 0;
    while (x <= size.width) {
      final y1 = waterY - waveAmp * math.sin((x / waveLen) * math.pi);
      final y2 = waterY - waveAmp * math.sin(((x + waveLen / 2) / waveLen) * math.pi);
      crestPath.cubicTo(
        x + waveLen / 4, y1,
        x + waveLen * 3 / 4, y2,
        x + waveLen, waterY,
      );
      x += waveLen;
    }
    canvas.drawPath(crestPath, waveCrestPaint);

    canvas.restore();

    // 2. Dark grey uniform outline (drawn on top, transparent interior = no fill)
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = const Color(0xFF4A5568)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BodyProgressPainter old) =>
      old.progress != progress ||
      old.fillColor != fillColor ||
      old.outlineColor != outlineColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gauge card: circular water fill + cup buttons
// ─────────────────────────────────────────────────────────────────────────────
class _GaugeCard extends StatelessWidget {
  final double s;
  final double cw;
  const _GaugeCard({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final gaugeSize = 130.0 * s;
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Column(
        children: [
          // ── 1.0 CUPS / 8 CUPS label ──
          Text(
            '1.0 CUPS / 8 CUPS',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 12 * s),

          // ── Gauge + buttons row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Water gauge
              SizedBox(
                width: gaugeSize,
                height: gaugeSize,
                child: CustomPaint(
                  painter: _WaterGaugePainter(pct: 0.22),
                  child: Center(
                    child: Text(
                      '22%',
                      style: GoogleFonts.inter(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20 * s),

              // Cup buttons column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CupButton(
                      s: s,
                      label: '+1 CUP',
                      sub: '252 ml',
                      cups: 1,
                    ),
                    SizedBox(height: 8 * s),
                    _CupButton(
                      s: s,
                      label: '+2 CUP',
                      sub: '355 ml',
                      cups: 2,
                    ),
                    SizedBox(height: 8 * s),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Custom',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: AppColors.cyan,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.cyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Circular water-fill gauge painter
class _WaterGaugePainter extends CustomPainter {
  final double pct;
  const _WaterGaugePainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background arc
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF0D1F30)
        ..style = PaintingStyle.fill,
    );

    // Water fill (bottom slice)
    final fillH = size.height * pct;
    final waterRect = Rect.fromLTWH(0, size.height - fillH, size.width, fillH);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    // Wave paint
    final wavePath = Path();
    wavePath.moveTo(0, size.height - fillH);
    for (double x = 0; x <= size.width; x++) {
      final y =
          (size.height - fillH) + math.sin((x / size.width) * 2 * math.pi) * 4;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(
      wavePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00BCD4).withAlpha(200),
            const Color(0xFF006080),
          ],
        ).createShader(waterRect),
    );
    canvas.restore();

    // Border ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF00BCD4).withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Arc progress
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      Paint()
        ..color = const Color(0xFF00BCD4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaterGaugePainter old) => old.pct != pct;
}

// Cup add button
class _CupButton extends StatelessWidget {
  final double s;
  final String label;
  final String sub;
  final int cups;
  const _CupButton(
      {required this.s,
      required this.label,
      required this.sub,
      required this.cups});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 10 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10 * s),
          child: ColoredBox(
            color: const Color(0xFF0D1F30),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
              child: Row(
                children: [
                  // Water cup icons
                  Row(
                    children: List.generate(
                      cups,
                      (_) => Padding(
                        padding: EdgeInsets.only(right: 3 * s),
                        child: Icon(Icons.water_drop_rounded,
                            color: AppColors.cyan, size: 16 * s),
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        sub,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    ],
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
// Period toggle: Daily / Weekly / Monthly
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodToggle extends StatelessWidget {
  final double s;
  final int selected;
  final ValueChanged<int> onTap;
  const _PeriodToggle(
      {required this.s, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Weekly', 'Monthly'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final active = i == selected;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 6 * s),
            padding:
                EdgeInsets.symmetric(horizontal: 18 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.cyan.withAlpha(30)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: active ? AppColors.cyan : AppColors.divider,
                width: 1,
              ),
            ),
            child: Text(
              labels[i],
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.cyan : AppColors.labelDim,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily graph card
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  const _GraphCard(
      {required this.s, required this.cw, required this.period});

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels[period],
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10 * s),
          SizedBox(
            width: double.infinity,
            height: 110 * s,
            child: CustomPaint(
              painter: _HydrationBarPainter(s: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationBarPainter extends CustomPainter {
  final double s;
  const _HydrationBarPainter({required this.s});

  // Normalised bar heights (0..1) — 24 bars for daily
  static const _values = [
    0.30, 0.50, 0.40, 0.60, 0.45, 0.70, 0.35, 0.55,
    0.80, 0.65, 0.50, 0.75, 0.90, 0.60, 0.45, 0.70,
    0.55, 0.40, 0.65, 0.50, 0.35, 0.60, 0.45, 0.55,
  ];
  static const _labels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final n = _values.length;
    final barW = (size.width - (n - 1) * 2) / n;
    final maxH = size.height - 18 * s;

    // Dashed horizontal guide line at 50%
    final dashY = size.height - maxH * 0.5 - 18 * s;
    final dashPaint = Paint()
      ..color = AppColors.cyan.withAlpha(60)
      ..strokeWidth = 1;
    double dx = 0;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, dashY), Offset(dx + 6, dashY), dashPaint);
      dx += 10;
    }

    for (int i = 0; i < n; i++) {
      final x = i * (barW + 2);
      final bH = maxH * _values[i];
      final top = size.height - bH - 18 * s;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, bH),
        Radius.circular(barW / 2),
      );

      // Glow
      canvas.drawRRect(
        rRect,
        Paint()
          ..color = AppColors.cyan.withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Bar fill
      canvas.drawRRect(
        rRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cyan, AppColors.cyan.withAlpha(160)],
          ).createShader(Rect.fromLTWH(x, top, barW, bH)),
      );
    }

    // X-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < _labels.length; i++) {
      final xPos = (size.width / (_labels.length - 1)) * i;
      tp
        ..text = TextSpan(
          text: _labels[i],
          style: TextStyle(
            fontSize: 8 * s,
            color: AppColors.labelDim,
          ),
        )
        ..layout();
      tp.paint(
          canvas, Offset(xPos - tp.width / 2, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_HydrationBarPainter old) => old.s != s;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  const _AiInsightCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: AppColors.cyan, size: 22 * s),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  'Hydration markers suggest you may be mildly dehydrated. '
                  'Increasing fluid intake now can support circulation, '
                  'energy levels, and temperature regulation.',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/bracelet/bracelet_channel.dart';

import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SleepScreen
// ─────────────────────────────────────────────────────────────────────────────
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _overviewTab = 0;
  static final BraceletChannel _channel = BraceletChannel();

  @override
  void initState() {
    super.initState();
    _requestSleepData();
  }

  Future<void> _requestSleepData() async {
    try {
      await _channel.requestSleepData();
      if (kDebugMode) {
        debugPrint(
          '[SleepScreen] requestSleepData() sent — watch for [Bracelet SDK] SleepData (27) in console',
        );
      }
    } on MissingPluginException catch (_) {
      if (kDebugMode) {
        debugPrint('[SleepScreen] requestSleepData not available');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
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
                SizedBox(height: 14 * s),

                // ── HI, USER ─────────────────────────────────────────
                Center(
                  child: Text(
                    'HI, USER',
                    style: AppStyles.lemon10(
                      s,
                    ).copyWith(color: AppColors.labelDim, letterSpacing: 2.0),
                  ),
                ),
                SizedBox(height: 12 * s),

                // ── Moon score hero ───────────────────────────────
                _MoonHero(s: s),
                SizedBox(height: 24 * s),

                // ── 3 stat cards row ────────────────────────────
                _StatCards(s: s, cw: cw),
                SizedBox(height: 28 * s),

                // ── Sleep Cycle ─────────────────────────────
                _SectionTitle(s: s, title: 'Sleep Cycle'),
                SizedBox(height: 14 * s),
                _SleepCycle(s: s),
                SizedBox(height: 28 * s),

                // ── Sleep Overview ───────────────────────────
                _SectionTitle(s: s, title: 'Sleep Overview'),
                SizedBox(height: 14 * s),
                _SleepOverview(
                  s: s,
                  cw: cw,
                  activeTab: _overviewTab,
                  onTabChanged: (i) => setState(() => _overviewTab = i),
                ),
                SizedBox(height: 24 * s),

                // ── AI Insight ───────────────────────────────
                _BorderCard(
                  s: s,
                  width: cw,
                  child: _AiInsightCard(s: s),
                ),
                SizedBox(height: 32 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.cyan,
                      size: 20 * s,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/24 logo.png',
                    height: 40 * s,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  CustomPaint(
                    painter: SmoothGradientBorder(radius: 22 * s),
                    child: ClipOval(
                      child: SizedBox(
                        width: 44 * s,
                        height: 44 * s,
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

class _BorderCard extends StatelessWidget {
  final double s;
  final double width;
  final Widget child;
  const _BorderCard({
    required this.s,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 16 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: ColoredBox(color: const Color(0xFF060E16), child: child),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final double s;
  final String title;
  const _SectionTitle({required this.s, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppStyles.lemon12(
        s,
      ).copyWith(color: Colors.white, letterSpacing: 0.5),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moon hero
// ─────────────────────────────────────────────────────────────────────────────
class _MoonHero extends StatelessWidget {
  final double s;
  const _MoonHero({required this.s});

  @override
  Widget build(BuildContext context) {
    final cw = MediaQuery.of(context).size.width - 32 * s;
    return Center(
      child: SizedBox(
        width: cw,
        height: 240 * s,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Enhanced Multi-Layer Glow ---
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 75 * s, sigmaY: 75 * s),
              child: Container(
                width: 210 * s,
                height: 210 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ACFFF).withAlpha(35),
                ),
              ),
            ),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35 * s, sigmaY: 35 * s),
              child: Container(
                width: 140 * s,
                height: 140 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ACFFF).withAlpha(55),
                ),
              ),
            ),

            // --- Background Stars ---
            CustomPaint(
              size: Size(cw, 240 * s),
              painter: _MoonPainter(s: s),
            ),

            // --- Moon Icon (Centered) ---
            CustomPaint(
              size: Size(130 * s, 130 * s),
              painter: _CrescentPainter(s: s),
            ),

            // --- Score Text (Positioned closely to the right) ---
            Transform.translate(
              offset: Offset(84 * s, 0), // Positioned right next to the moon
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '56',
                    style: GoogleFonts.inter(
                      fontSize: 84 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24 * s),
                    child: Text(
                      '%',
                      style: GoogleFonts.inter(
                        fontSize: 26 * s,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
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

class _CrescentPainter extends CustomPainter {
  final double s;
  _CrescentPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final color = const Color(0xFF4ACFFF);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final cutout = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(radius * 0.45, 0),
          radius: radius,
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, path, cutout),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MoonPainter extends CustomPainter {
  final double s;
  _MoonPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    const starColor = Color(0xFF4ACFFF);
    final center = Offset(size.width / 2, size.height / 2);

    // Distribute stars more uniformly around the moon center
    final stars = [
      Offset(center.dx - 120 * s, center.dy - 80 * s),
      Offset(center.dx - 80 * s, center.dy - 110 * s),
      Offset(center.dx + 60 * s, center.dy - 95 * s),
      Offset(center.dx + 130 * s, center.dy - 40 * s),
      Offset(center.dx + 110 * s, center.dy + 70 * s),
      Offset(center.dx - 40 * s, center.dy + 90 * s),
      Offset(center.dx - 110 * s, center.dy + 40 * s),
      Offset(center.dx + 30 * s, center.dy + 105 * s),
      Offset(center.dx - 140 * s, center.dy + 10 * s),
    ];
    final starSizes = [12.0, 26.0, 18.0, 10.0, 22.0, 12.0, 10.0, 14.0, 10.0];
    final paint = Paint()..color = starColor.withAlpha(180);
    for (int i = 0; i < stars.length; i++) {
      _drawStar(canvas, stars[i], starSizes[i] * s, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    const pts = 5;
    const angle = (2 * math.pi) / pts;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final r = i.isEven ? size / 2 : size / 4.5;
      final x = center.dx + r * math.cos(i * angle / 2 - math.pi / 2);
      final y = center.dy + r * math.sin(i * angle / 2 - math.pi / 2);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat cards
// ─────────────────────────────────────────────────────────────────────────────
class _StatCards extends StatelessWidget {
  final double s;
  final double cw;
  const _StatCards({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final gap = 10.0 * s;
    final w = (cw - gap * 2) / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatCard(s: s, width: w, label: 'Sleep Time', value: '7:55'),
        _StatCard(s: s, width: w, label: 'Sleep Latency', value: '2:25'),
        _StatCard(s: s, width: w, label: 'Nap', value: '1:55'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final double s, width;
  final String label, value;
  const _StatCard({
    required this.s,
    required this.width,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * s),
        child: Column(
          children: [
            Text(
              label,
              style: AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
            ),
            SizedBox(height: 10 * s),
            Text(value, style: AppStyles.bold22(s).copyWith(fontSize: 22 * s)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Cycle
// ─────────────────────────────────────────────────────────────────────────────
class _SleepCycle extends StatelessWidget {
  final double s;
  const _SleepCycle({required this.s});

  static const _data = [
    (
      label: 'AMS',
      pct: 0.25,
      time: '00:06',
      total: '00:24',
      color: Color(0xFF4EE25E),
    ),
    (
      label: 'Light',
      pct: 0.53,
      time: '02:16',
      total: '04:00',
      color: Color(0xFF329CF3),
    ),
    (
      label: 'Deep',
      pct: 0.24,
      time: '00:35',
      total: '01:48',
      color: Color(0xFFD81B60),
    ),
    (
      label: 'REM',
      pct: 0.12,
      time: '00:17',
      total: '01:48',
      color: Color(0xFFFBDB47),
    ),
    (
      label: 'S. E',
      pct: 0.37,
      time: '00:17',
      total: '01:48',
      color: Color(0xFFA135FD),
    ),
    (
      label: 'Sleep Dept',
      pct: 0.32,
      time: '00:17',
      total: '01:48',
      color: Color(0xFFFF5252),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _data.map((st) => _CycleRow(s: s, st: st)).toList(),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final double s;
  final dynamic st;
  const _CycleRow({required this.s, required this.st});

  @override
  Widget build(BuildContext context) {
    final ringS = 54.0 * s;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Row(
        children: [
          // Ring + Pct
          SizedBox(
            width: ringS,
            height: ringS,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(ringS, ringS),
                  painter: _RingPainter(pct: st.pct, color: st.color, s: s),
                ),
                Text(
                  '${(st.pct * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 24 * s),
          // Label
          SizedBox(
            width: 70 * s, // Fixed width for alignment
            child: Text(
              st.label,
              style: AppStyles.reg12(s).copyWith(
                color: Colors.white,
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          // Obtained Time
          SizedBox(
            width: 45 * s,
            child: Text(
              st.time,
              textAlign: TextAlign.right,
              style: AppStyles.bold12(s).copyWith(fontSize: 14 * s),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            child: Text(
              '/',
              style: AppStyles.reg12(s).copyWith(color: AppColors.labelDim),
            ),
          ),
          // Total Time
          SizedBox(
            width: 45 * s,
            child: Text(
              st.total,
              textAlign: TextAlign.left,
              style: AppStyles.reg12(
                s,
              ).copyWith(color: AppColors.labelDim, fontSize: 14 * s),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct, s;
  final Color color;
  _RingPainter({required this.pct, required this.color, required this.s});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5 * s
      ..strokeCap = StrokeCap.round;
    final r = (size.width - 7 * s) / 2;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: r,
      ),
      0,
      2 * math.pi,
      false,
      paint..color = const Color(0xFF1E2E3A),
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: r,
      ),
      -math.pi / 2,
      2 * math.pi * pct, // Clockwise sweep
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Overview
// ─────────────────────────────────────────────────────────────────────────────
class _SleepOverview extends StatelessWidget {
  final double s, cw;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  const _SleepOverview({
    required this.s,
    required this.cw,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF16202A),
            borderRadius: BorderRadius.circular(19 * s),
          ),
          child: Row(
            children: ['Daily', 'Weekly', 'Monthly'].asMap().entries.map((e) {
              final active = e.key == activeTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(e.key),
                  child: Container(
                    margin: EdgeInsets.all(2 * s),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF145E73)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18 * s),
                    ),
                    child: Text(
                      e.value,
                      style: AppStyles.reg10(s).copyWith(
                        color: active ? Colors.white : AppColors.labelDim,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 34 * s),
        SizedBox(
          height: 160 * s,
          width: double.infinity,
          child: CustomPaint(painter: _OverviewChartPainter(s: s)),
        ),
      ],
    );
  }
}

class _OverviewChartPainter extends CustomPainter {
  final double s;
  _OverviewChartPainter({required this.s});
  @override
  void paint(Canvas canvas, Size size) {
    final gridP = Paint()
      ..color = const Color(0xFF1E3040)
      ..strokeWidth = 0.5 * s;
    final txtS = GoogleFonts.inter(fontSize: 10 * s, color: AppColors.labelDim);
    final lPad = 40.0 * s,
        bPad = 25.0 * s,
        cW = size.width - lPad,
        cH = size.height - bPad;

    final yLines = [
      (label: '9:00', p: 0.0),
      (label: '6:00', p: 0.33),
      (label: '4:00', p: 0.55),
      (label: '0:00', p: 1.0),
    ];
    for (var l in yLines) {
      canvas.drawLine(
        Offset(lPad, cH * l.p),
        Offset(size.width, cH * l.p),
        gridP,
      );
      _drawTxt(canvas, l.label, Offset(0, cH * l.p - 6 * s), txtS);
    }

    final dotP = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    for (double x = lPad; x < size.width; x += 8 * s) {
      canvas.drawLine(
        Offset(x, cH + 4 * s),
        Offset(x + 4 * s, cH + 4 * s),
        dotP,
      );
    }

    final xL = ['00', '06', '12', '18', '00'], xP = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (int i = 0; i < xL.length; i++) {
      _drawTxt(
        canvas,
        xL[i],
        Offset(lPad + xP[i] * cW - 6 * s, cH + 12 * s),
        txtS,
      );
    }

    final bars = [
      (x: 0.44, h: 0.46),
      (x: 0.55, h: 0.64),
      (x: 0.65, h: 0.8),
      (x: 0.75, h: 0.54),
      (x: 0.86, h: 0.7),
    ];
    for (var b in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            lPad + b.x * cW - 10 * s,
            cH - cH * b.h,
            20 * s,
            cH * b.h,
          ),
          Radius.circular(6 * s),
        ),
        Paint()..color = const Color(0xFF4ACFFF),
      );
    }
  }

  void _drawTxt(Canvas canvas, String t, Offset o, TextStyle st) {
    TextPainter(
        text: TextSpan(text: t, style: st),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, o);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  const _AiInsightCard({required this.s});
  @override
  Widget build(BuildContext context) {
    const g = LinearGradient(colors: [Color(0xFF00F0FF), Color(0xFF00E676)]);
    return Padding(
      padding: EdgeInsets.all(20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (r) => g.createShader(r),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 22 * s,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10 * s),
              ShaderMask(
                shaderCallback: (r) => g.createShader(r),
                child: Text('AI INSIGHT', style: AppStyles.lemon12(s)),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          _Bullet(
            s: s,
            t: '"You fall asleep 30% faster on days when you walk at least 8,000 steps."',
          ),
          SizedBox(height: 16 * s),
          _Bullet(
            s: s,
            t: '"Your REM sleep is consistently lower on nights when you consume caffeine after 4 PM."',
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final double s;
  final String t;
  const _Bullet({required this.s, required this.t});
  @override
  Widget build(BuildContext context) {
    return Text(
      t,
      style: AppStyles.reg12(s).copyWith(
        color: AppColors.textLight,
        height: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// For image overlays
import 'package:flutter/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SleepScreen
// ─────────────────────────────────────────────────────────────────────────────
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _overviewTab = 0; // 0=Daily 1=Weekly 2=Monthly

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(s: s),
                SizedBox(height: 6 * s),

                // HI, USER
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

                // Moon score hero
                _MoonHero(s: s),
                SizedBox(height: 18 * s),

                // 3 stat cards row
                _StatCards(s: s, cw: cw),
                SizedBox(height: 16 * s),

                // Sleep Cycle
                _SectionTitle(s: s, title: 'Sleep Cycle'),
                SizedBox(height: 10 * s),
                _BorderCard(
                  s: s,
                  width: cw,
                  child: _SleepCycle(s: s),
                ),
                SizedBox(height: 16 * s),

                // Sleep Overview
                _SectionTitle(s: s, title: 'Sleep Overview'),
                SizedBox(height: 10 * s),
                _BorderCard(
                  s: s,
                  width: cw,
                  child: _SleepOverview(
                    s: s,
                    cw: cw,
                    activeTab: _overviewTab,
                    onTabChanged: (i) => setState(() => _overviewTab = i),
                  ),
                ),
                SizedBox(height: 14 * s),

                // AI Insight
                _BorderCard(
                  s: s,
                  width: cw,
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

class _BorderCard extends StatelessWidget {
  final double s;
  final double width;
  final Widget child;
  const _BorderCard(
      {required this.s, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 16 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: child,
          ),
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
      style: GoogleFonts.inter(
        fontSize: 14 * s,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moon hero — fully custom-painted (crescent + 5-point stars + % score)
// ─────────────────────────────────────────────────────────────────────────────
class _MoonHero extends StatelessWidget {
  final double s;
  const _MoonHero({required this.s});

  @override
  Widget build(BuildContext context) {
    final cw = MediaQuery.of(context).size.width - 32.0 * s;
    final heroH = cw * 0.72;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: SizedBox(
        width: cw,
        height: heroH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Night background color
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [Color(0xFF1A3A55), Color(0xFF060E16)],
                ),
              ),
            ),
            // Moon image
            Align(
              alignment: const Alignment(0.0, 0.05),
              child: FractionallySizedBox(
                widthFactor: 0.45,
                child: Image.asset(
                  'assets/fonts/moon.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            // More stars (5 total, scattered)
            Positioned(
              left: cw * 0.18,
              top: heroH * 0.18,
              child: SizedBox(
                width: s * 38,
                child: Image.asset(
                  'assets/fonts/star.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(
              right: cw * 0.13,
              top: heroH * 0.13,
              child: SizedBox(
                width: s * 28,
                child: Image.asset(
                  'assets/fonts/star.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(
              left: cw * 0.08,
              top: heroH * 0.38,
              child: SizedBox(
                width: s * 22,
                child: Image.asset(
                  'assets/fonts/star.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(
              right: cw * 0.22,
              top: heroH * 0.32,
              child: SizedBox(
                width: s * 18,
                child: Image.asset(
                  'assets/fonts/star.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(
              left: cw * 0.38,
              bottom: heroH * 0.10,
              child: SizedBox(
                width: s * 16,
                child: Image.asset(
                  'assets/fonts/star.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            // Score text
            Align(
              alignment: const Alignment(0.13, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '%56',
                    style: TextStyle(
                      fontSize: s * 46,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF5AC8FA).withAlpha(180),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: s * 8),
                  Text(
                    'Sleep Score',
                    style: TextStyle(
                      fontSize: s * 11,
                      color: const Color(0xFF5AC8FA).withAlpha(200),
                      letterSpacing: 1.2,
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

// Custom painter: radial night bg + crescent moon + 5-point stars + text
class _NightPainter extends CustomPainter {
  final int seed;
  final double s;
  _NightPainter({required this.seed, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rng = math.Random(seed);

    // ── Radial background ──────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        radius: 0.9,
        colors: [Color(0xFF1A3A55), Color(0xFF060E16)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // ── Crescent moon ──────────────────────────────────────────────────────
    // Large moon, centered in card
    final moonR = size.width * 0.30;
    final moonC = Offset(size.width * 0.50, size.height * 0.52);

    canvas.saveLayer(rect, Paint());

    // Full circle (cyan)
    canvas.drawCircle(
      moonC,
      moonR,
      Paint()..color = const Color(0xFF5AC8FA),
    );

    // Cut circle shifted right → crescent opens to the right
    canvas.drawCircle(
      moonC.translate(moonR * 0.50, 0),
      moonR,
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.clear,
    );

    canvas.restore();

    // ── Stars — scattered freely around the card ───────────────────────────
    // Avoid only the painted solid crescent body
    final solidCrescent = Rect.fromCenter(
      center: Offset(moonC.dx - moonR * 0.15, moonC.dy),
      width: moonR * 1.2,
      height: moonR * 2.0,
    );

    // Brighter large stars
    final brightPaint = Paint()..color = const Color(0xFF5AC8FA).withAlpha(230);
    // Dimmer small stars
    final dimPaint = Paint()..color = const Color(0xFF5AC8FA).withAlpha(130);

    for (int i = 0; i < 20; i++) {
      final isBig = i < 8;
      final starSize = isBig
          ? rng.nextDouble() * 7 + 8   // 8–15 px
          : rng.nextDouble() * 4 + 3;  // 3–7 px
      double dx, dy;
      int tries = 0;
      do {
        dx = rng.nextDouble() * size.width;
        dy = rng.nextDouble() * size.height;
        tries++;
      } while (tries < 30 && solidCrescent.contains(Offset(dx, dy)));
      _drawStar(canvas, Offset(dx, dy), starSize, isBig ? brightPaint : dimPaint);
    }

    // ── %56 + "Sleep Score" drawn on canvas ────────────────────────────────
    // Text sits in the concave opening of the crescent (right-of-center area)
    final textCx = moonC.dx + moonR * 0.08;
    final textCy = moonC.dy;

    _paintCenteredText(
      canvas,
      '%56',
      textCx,
      textCy - s * 14,
      TextStyle(
        fontSize: s * 46,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        shadows: [
          Shadow(
            color: const Color(0xFF5AC8FA).withAlpha(180),
            blurRadius: 20,
          ),
        ],
      ),
    );

    _paintCenteredText(
      canvas,
      'Sleep Score',
      textCx,
      textCy + s * 34,
      TextStyle(
        fontSize: s * 11,
        color: const Color(0xFF5AC8FA).withAlpha(200),
        letterSpacing: 1.2,
      ),
    );
  }

  void _paintCenteredText(
      Canvas canvas, String text, double cx, double cy, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    const points = 5;
    const angle = (2 * math.pi) / points;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? size : size / 2.2;
      final x = center.dx + r * math.cos(i * angle / 2 - math.pi / 2);
      final y = center.dy + r * math.sin(i * angle / 2 - math.pi / 2);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NightPainter old) => old.seed != seed || old.s != s;
}



// ─────────────────────────────────────────────────────────────────────────────
// 3 mini stat cards
// ─────────────────────────────────────────────────────────────────────────────
class _StatCards extends StatelessWidget {
  final double s;
  final double cw;
  const _StatCards({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final gap = 8.0 * s;
    final cardW = (cw - gap * 2) / 3;
    final cards = [
      ('Sleep Time', '7:55'),
      ('Sleep Latency', '2:25'),
      ('Nap', '1:55'),
    ];
    return Row(
      children: cards.asMap().entries.map((e) {
        final isLast = e.key == cards.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatCard(s: s, width: cardW, label: e.value.$1, value: e.value.$2),
            if (!isLast) SizedBox(width: gap),
          ],
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double s;
  final double width;
  final String label;
  final String value;
  const _StatCard(
      {required this.s,
      required this.width,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 12 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 10 * s, horizontal: 8 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      color: AppColors.labelDim,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
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
// Sleep Cycle rows
// ─────────────────────────────────────────────────────────────────────────────
class _SleepCycle extends StatelessWidget {
  final double s;
  const _SleepCycle({required this.s});

  static const _stages = [
    (label: 'AMS',        pct: 0.26, pctLabel: '26%', duration: '00:06', total: '/ 00:24', color: Color(0xFF00F0FF)),
    (label: 'Light',      pct: 0.53, pctLabel: '53%', duration: '02:15', total: '/ 04:00', color: Color(0xFF7C4DFF)),
    (label: 'Deep',       pct: 0.24, pctLabel: '24%', duration: '00:35', total: '/ 01:48', color: Color(0xFF00C853)),
    (label: 'REM',        pct: 0.12, pctLabel: '12%', duration: '00:17', total: '/ 01:48', color: Color(0xFFFFB300)),
    (label: 'S. E',       pct: 0.37, pctLabel: '37%', duration: '00:17', total: '/ 01:48', color: Color(0xFFE53935)),
    (label: 'Sleep\nDept',pct: 0.32, pctLabel: '32%', duration: '00:17', total: '/ 01:48', color: Color(0xFFCE6AFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14 * s),
      child: Column(
        children: _stages.asMap().entries.map((e) {
          final isLast = e.key == _stages.length - 1;
          final st = e.value;
          return Column(
            children: [
              _StageTile(
                s: s,
                label: st.label,
                pct: st.pct,
                pctLabel: st.pctLabel,
                duration: st.duration,
                total: st.total,
                color: st.color,
              ),
              if (!isLast) ...[
                SizedBox(height: 6 * s),
                Divider(color: AppColors.divider, height: 1),
                SizedBox(height: 6 * s),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final double s;
  final String label;
  final double pct;
  final String pctLabel;
  final String duration;
  final String total;
  final Color color;

  const _StageTile({
    required this.s,
    required this.label,
    required this.pct,
    required this.pctLabel,
    required this.duration,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = 44.0 * s;
    return Row(
      children: [
        // Ring
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: CustomPaint(
            painter: _RingPainter(progress: pct, color: color),
            child: Center(
              child: Text(
                pctLabel,
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        // Stage label
        SizedBox(
          width: 42 * s,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const Spacer(),
        // Duration
        Text(
          duration,
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4 * s),
        Text(
          total,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // Track
    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withAlpha(35)
        ..strokeCap = StrokeCap.round,
    );
    // Progress
    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * progress, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Overview — bar chart + tab switcher
// ─────────────────────────────────────────────────────────────────────────────
class _SleepOverview extends StatelessWidget {
  final double s;
  final double cw;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  const _SleepOverview({
    required this.s,
    required this.cw,
    required this.activeTab,
    required this.onTabChanged,
  });

  static const _tabs = ['Daily', 'Weekly', 'Monthly'];

  // Hours of sleep per day (last 7 days trending)
  static const _dailyData = [5.0, 6.5, 4.5, 7.5, 8.0, 6.0, 7.0];
  static const _weeklyData = [6.0, 7.2, 5.5, 6.8, 7.5, 7.0, 6.5];
  static const _monthlyData = [5.5, 6.0, 6.8, 7.2, 7.5, 7.0, 6.5];

  List<double> get _data =>
      activeTab == 0 ? _dailyData : activeTab == 1 ? _weeklyData : _monthlyData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab row
          Row(
            children: _tabs.asMap().entries.map((e) {
              final active = e.key == activeTab;
              return GestureDetector(
                onTap: () => onTabChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: 8 * s),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14 * s, vertical: 6 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * s),
                    color: active
                        ? AppColors.cyan
                        : const Color(0xFF0A1820),
                    border: Border.all(
                      color: active
                          ? AppColors.cyan
                          : const Color(0xFF1E3040),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: active ? Colors.black : AppColors.labelDim,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14 * s),

          // Bar chart
          SizedBox(
            width: double.infinity,
            height: 130 * s,
            child: CustomPaint(
              painter: _BarChartPainter(data: _data, s: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final double s;
  const _BarChartPainter({required this.data, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    const maxVal = 9.0;
    final leftPad = 0.0;
    final bottomPad = 24.0 * s;
    final chartW = size.width;
    final chartH = size.height - bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFF2B3A43)
      ..strokeWidth = 1.1;

    final labelStyle = GoogleFonts.inter(
      fontSize: 15 * s,
      color: Colors.white.withOpacity(0.7),
      fontWeight: FontWeight.w500,
    );

    // Y-axis grid lines (4 lines)
    for (final y in [9.0, 6.0, 3.0, 0.0]) {
      final yPos = chartH * (1 - y / maxVal);
      canvas.drawLine(
          Offset(leftPad, yPos), Offset(size.width, yPos), gridPaint);
    }

    // Bars
    final barCount = data.length;
    final barGap = chartW / (barCount * 2.0 + 1);
    final barW = barGap * 1.6;

    final barPaint = Paint()
      ..color = const Color(0xFF8ED6F9)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final x = leftPad + barGap + i * (barW + barGap);
      final barH = (data[i] / maxVal) * chartH;
      final top = chartH - barH;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, barH),
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(rect, barPaint);
    }

    // X-axis labels (00, 06, 12, 18, 00)
    final xLabels = ['00', '06', '12', '18', '00'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPad + i * (chartW / (xLabels.length - 1));
      _drawText(canvas, xLabels[i],
          Offset(x - 12 * s, size.height - 18 * s), labelStyle, 30 * s);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset,
      TextStyle style, double maxW) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxW);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.data != data || old.s != s;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purple],
                ).createShader(bounds),
                child: Icon(Icons.auto_awesome_rounded,
                    size: 18 * s, color: Colors.white),
              ),
              SizedBox(width: 8 * s),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purple],
                ).createShader(bounds),
                child: Text(
                  'AI INSIGHT',
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            'You fall asleep 30% faster on days when you walk at least 6,000 steps.',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            '"Your REM sleep is consistently lower on nights when you consume caffeine after 4 PM."',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: AppColors.labelDim,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

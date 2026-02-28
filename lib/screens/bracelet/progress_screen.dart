import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProgressScreen  (Steps / Distance / Calories)
// ─────────────────────────────────────────────────────────────────────────────
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _tab = 0; // 0=Steps  1=Distance  2=Calories
  int _periodIndex = 0;

  // ── per-tab config ──────────────────────────────────────────────────────
  static const _tabs = ['Steps', 'Distance', 'Calories'];

  static const _values   = ['-1',    '-1',    '-1'];
  static const _maxes    = ['/-1',   '/-1',   '/-1'];
  static const _units    = ['Steps', 'Km', 'Kcal'];
  static const _progress = [0.0, 0.0, 0.0];

  // Ring / bar colors
  static const _ringColors = [
    [Color(0xFF43C6E4), Color(0xFF0066FF)], // cyan–blue
    [Color(0xFF69F0AE), Color(0xFF00C853)], // light green–dark green
    [Color(0xFFFF8A80), Color(0xFFE53935)], // salmon–red
  ];

  // Weekly bar data (Sun→Sat) per tab
  static const _barData = [
    [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0],
    [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0],
    [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0],
  ];

  static const _barMaxes = [-1.0, -1.0, -1.0];

  static const _yTickSets = [
    ['10,000', '7,500', '5,000', '2,500', '00'],
    ['6,000',  '4,500', '3,000', '1,500', '00'],
    ['1,200',  '900',   '600',   '300',   '00'],
  ];

  static const _icons = [
    Icons.directions_walk_rounded,
    Icons.route_rounded,
    Icons.local_fire_department_rounded,
  ];

  static const _aiTexts = [
    'Your step count is below your usual movement pattern today. A short walk or light activity can help reactivate circulation, improve focus, and support overall recovery.',
    'Your total distance covered today is lower than your recent average. Gradually increasing movement throughout the day can support endurance and joint mobility without overloading the body.',
    'Your calorie burn is trending below your expected range. The AI suggests light-to-moderate activity to align energy output with your daily balance and recovery goals.',
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;
    final primaryColor = _ringColors[_tab][0];
    final secondaryColor = _ringColors[_tab][1];

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
                _TopBar(s: s),
                SizedBox(height: 6 * s),
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

                // ── Tab selector ─────────────────────────────────────
                _TabBar(
                  s: s,
                  selected: _tab,
                  onTap: (i) => setState(() => _tab = i),
                ),
                SizedBox(height: 16 * s),

                // ── Ring gauge hero ──────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _RingHero(
                    s: s,
                    cw: cw,
                    progress: _progress[_tab],
                    value: _values[_tab],
                    maxLabel: _maxes[_tab],
                    unit: _units[_tab],
                    topColor: primaryColor,
                    bottomColor: secondaryColor,
                    icon: _icons[_tab],
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Period toggle ────────────────────────────────────
                _PeriodToggle(
                  s: s,
                  selected: _periodIndex,
                  primaryColor: primaryColor,
                  onTap: (i) => setState(() => _periodIndex = i),
                ),
                SizedBox(height: 14 * s),

                // ── Bar chart ────────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GraphCard(
                    s: s,
                    cw: cw,
                    tab: _tab,
                    period: _periodIndex,
                    barData: _barData[_tab],
                    barMax: _barMaxes[_tab],
                    yTicks: _yTickSets[_tab],
                    topColor: primaryColor,
                    bottomColor: secondaryColor,
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight ───────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _AiInsightCard(s: s, text: _aiTexts[_tab]),
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
// Card wrapper
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
// Steps / Distance / Calories tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final double s;
  final int selected;
  final ValueChanged<int> onTap;
  const _TabBar(
      {required this.s, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Steps', 'Distance', 'Calories'];
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 26 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(
            padding: EdgeInsets.all(3 * s),
            child: Row(
              children: List.generate(labels.length, (i) {
                final active = i == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 9 * s),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.cyan.withAlpha(30)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22 * s),
                        border: active
                            ? Border.all(color: AppColors.cyan, width: 1)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        labels[i],
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color:
                              active ? AppColors.cyan : AppColors.labelDim,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ring gauge hero
// ─────────────────────────────────────────────────────────────────────────────
class _RingHero extends StatelessWidget {
  final double s;
  final double cw;
  final double progress;
  final String value;
  final String maxLabel;
  final String unit;
  final Color topColor;
  final Color bottomColor;
  final IconData icon;
  const _RingHero({
    required this.s,
    required this.cw,
    required this.progress,
    required this.value,
    required this.maxLabel,
    required this.unit,
    required this.topColor,
    required this.bottomColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = cw * 0.52;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22 * s),
      child: Center(
        child: SizedBox(
          width: ringSize,
          height: ringSize,
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress,
              topColor: topColor,
              bottomColor: bottomColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: topColor, size: 28 * s,
                      shadows: [
                        Shadow(color: topColor.withAlpha(150), blurRadius: 12)
                      ]),
                  SizedBox(height: 6 * s),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 30 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                            color: topColor.withAlpha(120), blurRadius: 16)
                      ],
                    ),
                  ),
                  Text(
                    maxLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: AppColors.labelDim,
                    ),
                  ),
                  Text(
                    unit,
                    style: GoogleFonts.inter(
                      fontSize: 9 * s,
                      color: AppColors.labelDim,
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

class _RingPainter extends CustomPainter {
  final double progress;
  final Color topColor;
  final Color bottomColor;
  const _RingPainter(
      {required this.progress,
      required this.topColor,
      required this.bottomColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final strokeW = size.width * 0.085;
    final radius = (size.width - strokeW) / 2;

    final trackPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc — start at top (-90°), sweep clockwise
    final sweepAngle = 2 * math.pi * progress;
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [topColor, bottomColor, topColor],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    final arcPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    // Glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = topColor.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW * 1.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.topColor != topColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Period toggle
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodToggle extends StatelessWidget {
  final double s;
  final int selected;
  final Color primaryColor;
  final ValueChanged<int> onTap;
  const _PeriodToggle(
      {required this.s,
      required this.selected,
      required this.primaryColor,
      required this.onTap});

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
              color: active ? primaryColor.withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: active ? primaryColor : AppColors.divider,
                width: 1,
              ),
            ),
            child: Text(
              labels[i],
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? primaryColor : AppColors.labelDim,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Graph card
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int tab;
  final int period;
  final List<double> barData;
  final double barMax;
  final List<String> yTicks;
  final Color topColor;
  final Color bottomColor;
  const _GraphCard({
    required this.s,
    required this.cw,
    required this.tab,
    required this.period,
    required this.barData,
    required this.barMax,
    required this.yTicks,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    const titles = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8 * s),
          SizedBox(
            width: double.infinity,
            height: 185 * s,
            child: CustomPaint(
              painter: _ProgressBarPainter(
                s: s,
                barData: barData,
                barMax: barMax,
                yTickLabels: yTicks,
                topColor: topColor,
                bottomColor: bottomColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double s;
  final List<double> barData;
  final double barMax;
  final List<String> yTickLabels; // top→bottom, 5 items including '00'
  final Color topColor;
  final Color bottomColor;

  const _ProgressBarPainter({
    required this.s,
    required this.barData,
    required this.barMax,
    required this.yTickLabels,
    required this.topColor,
    required this.bottomColor,
  });

  static const _xLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 40.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // ── Y labels + dashed guide lines ──
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 1;

    // 5 ticks: top label (max), then 75%, 50%, 25%, 00 at bottom
    final yFracs = [0.0, 0.25, 0.50, 0.75, 1.0];

    for (int i = 0; i < yTickLabels.length; i++) {
      final y = chartH * yFracs[i];
      tp
        ..text = TextSpan(
            text: yTickLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Dashed line
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // ── Bars ──
    final n = barData.length; // 7
    const slotGap = 6.0;
    final barW = (chartW - (n - 1) * slotGap) / n;

    for (int i = 0; i < n; i++) {
      final norm = barData[i] / barMax;
      final bH = chartH * norm;
      final x = yLabelW + i * (barW + slotGap);
      final top = chartH - bH;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, bH),
        Radius.circular(barW / 2),
      );

      // Glow
      canvas.drawRRect(
        rRect,
        Paint()
          ..color = topColor.withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      // Gradient bar
      canvas.drawRRect(
        rRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ).createShader(Rect.fromLTWH(x, top, barW, bH)),
      );
    }

    // ── X labels (Sun Mon Tue Wed Thu Fri Sat) ──
    for (int i = 0; i < _xLabels.length; i++) {
      final xPos = yLabelW + i * (barW + slotGap) + barW / 2;
      tp
        ..text = TextSpan(
            text: _xLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 3));
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) =>
      old.barData != barData || old.topColor != topColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final String text;
  const _AiInsightCard({required this.s, required this.text});

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
                  text,
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

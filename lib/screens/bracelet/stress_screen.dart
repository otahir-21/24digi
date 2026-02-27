import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../painters/stress_icon_painter.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StressScreen
// ─────────────────────────────────────────────────────────────────────────────
class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> {
  int _periodIndex = 0;

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
                SizedBox(height: 20 * s),

                // ── Meditation hero ──────────────────────────────────
                _BorderCard(s: s, child: _StressHero(s: s, cw: cw)),
                SizedBox(height: 14 * s),

                // ── Stress level gradient bar ────────────────────────
                _GradientBar(s: s, cw: cw, value: 0.22),
                SizedBox(height: 14 * s),

                // ── 3 stat tiles ─────────────────────────────────────
                _StatTiles(s: s, cw: cw),
                SizedBox(height: 14 * s),

                // ── Period toggle ────────────────────────────────────
                _PeriodToggle(
                  s: s,
                  selected: _periodIndex,
                  onTap: (i) => setState(() => _periodIndex = i),
                ),
                SizedBox(height: 14 * s),

                // ── Graph card ───────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GraphCard(s: s, cw: cw, period: _periodIndex),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight ───────────────────────────────────────
                _BorderCard(s: s, child: _AiInsightCard(s: s)),
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
// Stress hero: meditation figure + "57" + "Low"
// ─────────────────────────────────────────────────────────────────────────────
class _StressHero extends StatelessWidget {
  final double s;
  final double cw;
  const _StressHero({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final figH = cw * 0.45;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20 * s),
      child: Column(
        children: [
          StressIcon(size: figH),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '57',
                style: GoogleFonts.inter(
                  fontSize: 52 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF43C6E4).withAlpha(120),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),
              Padding(
                padding: EdgeInsets.only(bottom: 8 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward_rounded,
                        color: AppColors.cyan, size: 13 * s),
                    SizedBox(width: 2 * s),
                    Text(
                      'Low',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: AppColors.labelDim,
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

// Meditation figure: filled silhouette with detail cut, cyan→purple gradient
class _MeditationPainter extends CustomPainter {
  const _MeditationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // ── Head ──
    canvas.drawCircle(Offset(w * 0.5, h * 0.15), h * 0.12, paint);

    // ── Body, arms & legs ──
    final body = Path();
    body.moveTo(w * 0.5, h * 0.3);
    // Left shoulder → arm
    body.quadraticBezierTo(w * 0.35, h * 0.3, w * 0.25, h * 0.45);
    body.quadraticBezierTo(w * 0.1, h * 0.55, 0, h * 0.5);
    body.quadraticBezierTo(w * 0.1, h * 0.65, w * 0.3, h * 0.55);
    // Torso left
    body.lineTo(w * 0.4, h * 0.7);
    // Left leg
    body.lineTo(w * 0.1, h * 0.85);
    body.quadraticBezierTo(w * 0.3, h * 0.95, w * 0.5, h * 0.85);
    // Right leg
    body.quadraticBezierTo(w * 0.7, h * 0.95, w * 0.9, h * 0.85);
    body.lineTo(w * 0.6, h * 0.7);
    // Torso right → arm
    body.lineTo(w * 0.7, h * 0.55);
    body.quadraticBezierTo(w * 0.9, h * 0.65, w, h * 0.5);
    body.quadraticBezierTo(w * 0.9, h * 0.55, w * 0.75, h * 0.45);
    body.quadraticBezierTo(w * 0.65, h * 0.3, w * 0.5, h * 0.3);
    canvas.drawPath(body, paint);

    // ── Inner diamond cut (background color) to separate leg detail ──
    final bg = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF060E16);
    final cut = Path();
    cut.moveTo(w * 0.3, h * 0.75);
    cut.lineTo(w * 0.5, h * 0.82);
    cut.lineTo(w * 0.7, h * 0.75);
    cut.lineTo(w * 0.5, h * 0.65);
    cut.close();
    canvas.drawPath(cut, bg);
  }

  @override
  bool shouldRepaint(_MeditationPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal stress gradient bar: green→yellow→red, marker at value
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBar extends StatelessWidget {
  final double s;
  final double cw;
  final double value; // 0..1  (low = left/green)
  const _GradientBar(
      {required this.s, required this.cw, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cw,
      height: 18 * s,
      child: CustomPaint(painter: _GradientBarPainter(value: value)),
    );
  }
}

class _GradientBarPainter extends CustomPainter {
  final double value;
  const _GradientBarPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(r));

    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFFFFEB3B), Color(0xFFE53935)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final markerX = size.width * value;
    // White needle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(markerX - 2, -2, 4, size.height + 4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );
    // Dot above
    canvas.drawCircle(
      Offset(markerX, -6),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GradientBarPainter old) => old.value != value;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 stat tiles: Max 82 / Medium 61 / Min 45
// ─────────────────────────────────────────────────────────────────────────────
class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  const _StatTiles({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final gap = 8.0 * s;
    final tileW = (cw - gap * 2) / 3;
    const tiles = [
      (label: 'Max',    value: '82', icon: Icons.arrow_upward_rounded,
        color: Color(0xFFE53935)),
      (label: 'Medium', value: '61', icon: Icons.remove_rounded,
        color: Color(0xFF4CAF50)),
      (label: 'Min',    value: '45', icon: Icons.arrow_downward_rounded,
        color: Color(0xFF00F0FF)),
    ];
    return Row(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (i > 0) SizedBox(width: gap),
            SizedBox(
              width: tileW,
              child: CustomPaint(
                painter: SmoothGradientBorder(radius: 14 * s),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14 * s),
                  child: ColoredBox(
                    color: const Color(0xFF060E16),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * s, vertical: 12 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(t.icon, color: t.color, size: 13 * s),
                              SizedBox(width: 3 * s),
                              Text(
                                t.value,
                                style: GoogleFonts.inter(
                                  fontSize: 24 * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * s),
                          Text(
                            t.label,
                            style: GoogleFonts.inter(
                              fontSize: 9 * s,
                              color: AppColors.labelDim,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period toggle
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
              color: active ? AppColors.cyan.withAlpha(30) : Colors.transparent,
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
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
// Graph card: 3-series (Calm, Neutral, Stress Peaks) stacked bar chart
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  const _GraphCard({required this.s, required this.cw, required this.period});

  @override
  Widget build(BuildContext context) {
    const titles = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[period],
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 8 * s),
          // Legend row
          Row(
            children: [
              _LegendDot(
                  s: s, color: const Color(0xFF4CAF50), label: 'Calm Periods'),
              SizedBox(width: 12 * s),
              _LegendDot(
                  s: s, color: AppColors.cyan, label: 'Neutral'),
              SizedBox(width: 12 * s),
              _LegendDot(
                  s: s, color: const Color(0xFFE53935), label: 'Stress Peaks'),
            ],
          ),
          SizedBox(height: 10 * s),
          SizedBox(
            width: double.infinity,
            height: 180 * s,
            child: CustomPaint(painter: _StressBarPainter(s: s)),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final double s;
  final Color color;
  final String label;
  const _LegendDot(
      {required this.s, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * s),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 8.5 * s, color: AppColors.labelDim)),
      ],
    );
  }
}

// Background bands (green/teal/red) spanning full chart width,
// individual cyan bars drawn on top per time slot.
class _StressBarPainter extends CustomPainter {
  final double s;
  const _StressBarPainter({required this.s});

  // Height of each individual bar (0-100 scale)
  static const _barVals = [52.0, 76.0, 88.0, 65.0, 80.0, 62.0, 55.0, 76.0];

  // Background band boundaries (bottom → top, in 0-100 scale)
  // Calm: 0–40 (green), Neutral: 40–78 (teal), Stress: 78–100 (red)
  static const _calmTop   = 40.0;
  static const _neutralTop = 78.0;

  static const _yLabels = ['100', '75', '50', '25'];
  static const _yTicks  = [100.0, 75.0, 50.0, 25.0];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 28.0 * s;
    final xLabelH = 18.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;
    const maxVal = 100.0;

    final chartRect = Rect.fromLTWH(yLabelW, 0, chartW, chartH);

    // ── Background bands ──────────────────────────────────────────
    // Calm (green) band: y from calmTop to 100 in value → top portion in canvas coords
    void drawBand(double valBottom, double valTop, Color color) {
      final yTop    = chartH * (1.0 - valTop    / maxVal);
      final yBottom = chartH * (1.0 - valBottom / maxVal);
      canvas.drawRect(
        Rect.fromLTWH(yLabelW, yTop, chartW, yBottom - yTop),
        Paint()..color = color,
      );
    }

    // Clip to chart area
    canvas.save();
    canvas.clipRect(chartRect);

    drawBand(0,            _calmTop,    const Color(0xFF1B5E20)); // dark green
    drawBand(_calmTop,     _neutralTop, const Color(0xFF0D3B4F)); // dark teal
    drawBand(_neutralTop,  maxVal,      const Color(0xFF7B1515)); // dark red

    // Subtle horizontal stripes inside each band for texture
    final stripePaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..strokeWidth = 1;
    for (double v = 5; v < maxVal; v += 5) {
      final y = chartH * (1.0 - v / maxVal);
      canvas.drawLine(Offset(yLabelW, y), Offset(yLabelW + chartW, y), stripePaint);
    }

    canvas.restore();

    // ── Y labels + guide lines ───────────────────────────────────
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(35)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final y = chartH * (1.0 - _yTicks[i] / maxVal);
      tp
        ..text = TextSpan(
            text: _yLabels[i],
            style: TextStyle(
                fontSize: 8 * s,
                color: AppColors.labelDim,
                fontWeight: FontWeight.w600))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // ── Individual cyan bars on top ──────────────────────────────
    final n = _barVals.length;
    const slotGap = 7.0;
    final barW = (chartW - (n - 1) * slotGap) / n;

    for (int i = 0; i < n; i++) {
      final val = _barVals[i];
      final bH  = chartH * (val / maxVal);
      final x   = yLabelW + i * (barW + slotGap);
      final top = chartH - bH;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, bH),
        Radius.circular(barW / 2),
      );

      // Glow
      canvas.drawRRect(
        rRect,
        Paint()
          ..color = const Color(0xFF43C6E4).withAlpha(70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Bright cyan gradient bar
      canvas.drawRRect(
        rRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87E8F8), Color(0xFF43C6E4)],
          ).createShader(Rect.fromLTWH(x, top, barW, bH)),
      );
    }

    // ── X labels ─────────────────────────────────────────────────
    for (int i = 0; i < _xLabels.length; i++) {
      final xPos = yLabelW + (chartW / (_xLabels.length - 1)) * i;
      tp
        ..text = TextSpan(
            text: _xLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 2));
    }
  }

  @override
  bool shouldRepaint(_StressBarPainter old) => old.s != s;
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
                  'Your stress levels have remained elevated for extended periods. '
                  'The AI recommends a short recovery window — deep breathing, '
                  'a brief walk, or disengaging from screens — to help reset your system.',
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

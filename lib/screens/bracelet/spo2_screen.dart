import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Spo2Screen
// ─────────────────────────────────────────────────────────────────────────────
class Spo2Screen extends StatefulWidget {
  const Spo2Screen({super.key});

  @override
  State<Spo2Screen> createState() => _Spo2ScreenState();
}

class _Spo2ScreenState extends State<Spo2Screen> {
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

                // ── Lungs hero card ───────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _LungsHero(s: s, cw: cw),
                ),
                SizedBox(height: 14 * s),

                // ── Gradient bar ──────────────────────────────────────
                _GradientBar(s: s, cw: cw, value: 0.95),
                SizedBox(height: 14 * s),

                // ── 3 stat tiles ──────────────────────────────────────
                _StatTiles(s: s, cw: cw),
                SizedBox(height: 14 * s),

                // ── Period toggle ─────────────────────────────────────
                _PeriodToggle(
                  s: s,
                  selected: _periodIndex,
                  onTap: (i) => setState(() => _periodIndex = i),
                ),
                SizedBox(height: 14 * s),

                // ── Graph card ────────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GraphCard(s: s, cw: cw, period: _periodIndex),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight ────────────────────────────────────────
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
// Lungs hero: painted lungs + 95%
// ─────────────────────────────────────────────────────────────────────────────
class _LungsHero extends StatelessWidget {
  final double s;
  final double cw;
  const _LungsHero({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final lungsH = cw * 0.55;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20 * s),
      child: Column(
        children: [
          SizedBox(
            width: cw * 0.62,
            height: lungsH,
            child: CustomPaint(
              painter: _LungsPainter(),
            ),
          ),
          SizedBox(height: 12 * s),
          Text(
            '95%',
            style: GoogleFonts.inter(
              fontSize: 48 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
              shadows: [
                Shadow(
                  color: AppColors.cyan.withAlpha(140),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LungsPainter extends CustomPainter {
  const _LungsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF43C6E4).withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();

    // ── Left bronchus branch ──
    path.moveTo(w * 0.45, h * 0.2);
    path.quadraticBezierTo(w * 0.45, h * 0.4, w * 0.25, h * 0.55);

    // ── Left lung outer shell ──
    path.moveTo(w * 0.38, h * 0.15);
    path.cubicTo(w * 0.10, h * 0.10, w * 0.02, h * 0.50, w * 0.05, h * 0.85);
    path.quadraticBezierTo(w * 0.10, h * 0.95, w * 0.35, h * 0.85);
    path.quadraticBezierTo(w * 0.45, h * 0.75, w * 0.42, h * 0.55);

    // ── Right bronchus branch ──
    path.moveTo(w * 0.55, h * 0.2);
    path.quadraticBezierTo(w * 0.55, h * 0.4, w * 0.75, h * 0.55);

    // ── Right lung outer shell ──
    path.moveTo(w * 0.62, h * 0.15);
    path.cubicTo(w * 0.90, h * 0.10, w * 0.98, h * 0.50, w * 0.95, h * 0.85);
    path.quadraticBezierTo(w * 0.90, h * 0.95, w * 0.65, h * 0.85);
    path.quadraticBezierTo(w * 0.55, h * 0.75, w * 0.58, h * 0.55);

    // ── Trachea (center stem) ──
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.5, h * 0.1);

    // Glow pass first, then sharp stroke
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LungsPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient bar with indicator marker
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBar extends StatelessWidget {
  final double s;
  final double cw;
  final double value; // 0..1
  const _GradientBar({required this.s, required this.cw, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cw,
      height: 18 * s,
      child: CustomPaint(
        painter: _GradientBarPainter(value: value),
      ),
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

    // Gradient: red → yellow → green
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFFEB3B),
            Color(0xFF4CAF50),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // White marker needle at value position
    final markerX = size.width * value;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(markerX - 2, -2, 4, size.height + 4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );

    // Small label dot above marker
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
// 3 stat tiles
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
      (label: 'Highest', value: '98%', icon: Icons.arrow_upward_rounded,
        color: Color(0xFF4CAF50)),
      (label: 'Lowest',  value: '94%', icon: Icons.arrow_downward_rounded,
        color: Color(0xFFE53935)),
      (label: 'Average', value: '98%', icon: Icons.remove_rounded,
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
                              Icon(t.icon, color: t.color, size: 14 * s),
                              SizedBox(width: 4 * s),
                              Text(
                                t.value,
                                style: GoogleFonts.inter(
                                  fontSize: 20 * s,
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
// Graph card
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  const _GraphCard({required this.s, required this.cw, required this.period});

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
            height: 140 * s,
            child: CustomPaint(
              painter: _Spo2BarPainter(s: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spo2BarPainter extends CustomPainter {
  final double s;
  const _Spo2BarPainter({required this.s});

  // SpO2 values normalised within 90-100% range — so bars vary between 0..1
  static const _raw = [
    95, 97, 96, 98, 97, 95, 94, 96, 98, 97, 95, 96,
    97, 98, 97, 95, 94, 96, 98, 99, 97, 95, 96, 97,
  ];
  static const _yLabels = ['100 %', '97 %', '50 %', '25 %'];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 32.0 * s;
    final xLabelH = 16.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    // Y-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final yPositions = [0.0, 0.25, 0.67, 1.0];
    for (int i = 0; i < _yLabels.length; i++) {
      tp
        ..text = TextSpan(
            text: _yLabels[i],
            style: TextStyle(fontSize: 7.5 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas,
          Offset(0, chartH * yPositions[i] - tp.height / 2));
    }

    // Bars
    final n = _raw.length;
    const minVal = 90.0;
    const maxVal = 100.0;
    final barW = (chartW - (n - 1) * 2) / n;

    for (int i = 0; i < n; i++) {
      final norm = (_raw[i] - minVal) / (maxVal - minVal);
      final bH = chartH * norm;
      final x = yLabelW + i * (barW + 2);
      final top = chartH - bH;

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
      // Bar fill gradient
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

    // Dashed horizontal guide lines at y positions
    final dashPaint = Paint()
      ..color = AppColors.cyan.withAlpha(40)
      ..strokeWidth = 1;
    for (final yFrac in yPositions) {
      final y = chartH * yFrac;
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // X labels
    for (int i = 0; i < _xLabels.length; i++) {
      final xPos = yLabelW + (chartW / (_xLabels.length - 1)) * i;
      tp
        ..text = TextSpan(
            text: _xLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas,
          Offset(xPos - tp.width / 2, chartH + 2));
    }
  }

  @override
  bool shouldRepaint(_Spo2BarPainter old) => old.s != s;
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
                  'Your blood oxygen saturation is slightly below your typical range. '
                  'Improving airflow through deeper breathing, posture adjustment, '
                  'or rest may help optimize oxygen delivery.',
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

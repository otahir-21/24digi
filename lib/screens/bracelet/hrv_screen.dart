import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HrvScreen
// ─────────────────────────────────────────────────────────────────────────────
class HrvScreen extends StatefulWidget {
  const HrvScreen({super.key});

  @override
  State<HrvScreen> createState() => _HrvScreenState();
}

class _HrvScreenState extends State<HrvScreen> {
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

                // ── Heart hero ───────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _HrvHero(s: s, cw: cw),
                ),
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
// HRV hero: heart shape with ECG + "42 ms"
// ─────────────────────────────────────────────────────────────────────────────
class _HrvHero extends StatelessWidget {
  final double s;
  final double cw;
  const _HrvHero({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final heroH = cw * 0.62;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20 * s),
      child: Column(
        children: [
          SizedBox(
            width: cw * 0.70,
            height: heroH,
            child: CustomPaint(painter: const _HrvHeartPainter()),
          ),
          SizedBox(height: 10 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '42',
                style: GoogleFonts.inter(
                  fontSize: 52 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF43C6E4).withAlpha(140),
                      blurRadius: 22,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5 * s),
              Padding(
                padding: EdgeInsets.only(bottom: 6 * s),
                child: Text(
                  'ms',
                  style: GoogleFonts.inter(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelDim,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Heart outline with ECG spike drawn inside – cyan→purple gradient stroke
class _HrvHeartPainter extends CustomPainter {
  const _HrvHeartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final strokeW = w * 0.045;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF43C6E4).withAlpha(55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // ── Heart path (open on right side to allow ECG exit) ──
    final heartPath = Path();
    // Start at bottom tip
    heartPath.moveTo(w * 0.5, h * 0.9);
    // Left curve up
    heartPath.cubicTo(w * 0.2, h * 0.75, w * 0.05, h * 0.45, w * 0.1, h * 0.25);
    heartPath.cubicTo(w * 0.15, h * 0.05, w * 0.45, h * 0.05, w * 0.5, h * 0.25);
    // Right curve (stops where ECG exits)
    heartPath.cubicTo(w * 0.55, h * 0.05, w * 0.85, h * 0.05, w * 0.9, h * 0.25);
    heartPath.cubicTo(w * 0.95, h * 0.45, w * 0.85, h * 0.65, w * 0.82, h * 0.73);

    // ── ECG pulse path ──
    final ekgPath = Path();
    ekgPath.moveTo(w * 0.42, h * 0.55);
    ekgPath.lineTo(w * 0.52, h * 0.55); // flat start
    ekgPath.lineTo(w * 0.58, h * 0.68); // dip
    ekgPath.lineTo(w * 0.66, h * 0.42); // spike up
    ekgPath.lineTo(w * 0.72, h * 0.65); // back down
    ekgPath.lineTo(w * 0.78, h * 0.55); // level
    ekgPath.lineTo(w * 0.92, h * 0.55); // exit right

    // Glow passes first, then sharp strokes
    canvas.drawPath(heartPath, glowPaint);
    canvas.drawPath(ekgPath, glowPaint);
    canvas.drawPath(heartPath, paint);
    canvas.drawPath(ekgPath, paint);
  }

  @override
  bool shouldRepaint(_HrvHeartPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 stat tiles: Highest 68ms / Lowest 24ms / Average 42ms
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
      (label: 'Highest', value: '68', icon: Icons.arrow_upward_rounded,
        color: Color(0xFF4CAF50)),
      (label: 'Lowest',  value: '24', icon: Icons.arrow_downward_rounded,
        color: Color(0xFFE53935)),
      (label: 'Average', value: '42', icon: Icons.remove_rounded,
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(t.icon, color: t.color, size: 13 * s),
                              SizedBox(width: 3 * s),
                              Text(
                                t.value,
                                style: GoogleFonts.inter(
                                  fontSize: 22 * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(width: 2 * s),
                              Padding(
                                padding: EdgeInsets.only(bottom: 2 * s),
                                child: Text(
                                  'ms',
                                  style: GoogleFonts.inter(
                                    fontSize: 8 * s,
                                    color: AppColors.labelDim,
                                  ),
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
            height: 150 * s,
            child: CustomPaint(painter: _HrvBarPainter(s: s)),
          ),
        ],
      ),
    );
  }
}

class _HrvBarPainter extends CustomPainter {
  final double s;
  const _HrvBarPainter({required this.s});

  // HRV values in ms – vary around 20-75 range
  static const _raw = [
    28, 35, 30, 42, 55, 65, 70, 68, 62, 58, 42, 38,
    32, 36, 44, 52, 60, 68, 72, 65, 58, 45, 38, 30,
  ];
  static const _yLabels = ['80', '60', '40', '20'];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 24.0 * s;
    final xLabelH = 18.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    const minVal = 0.0;
    const maxVal = 80.0;
    const yTicks = [80.0, 60.0, 40.0, 20.0];

    // Y-axis labels + dashed guide lines
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final dashPaint = Paint()
      ..color = AppColors.cyan.withAlpha(35)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final yFrac = 1.0 - (yTicks[i] - minVal) / (maxVal - minVal);
      final y = chartH * yFrac;

      tp
        ..text = TextSpan(
            text: _yLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Dashed horizontal line
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // Bars
    final n = _raw.length;
    final barW = (chartW - (n - 1) * 2.0) / n;

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
      // Gradient fill
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

    // X labels
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
  bool shouldRepaint(_HrvBarPainter old) => old.s != s;
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
                  'Your HRV is lower than your personal baseline today, '
                  'suggesting your body is still under recovery. Prioritize '
                  'light activity, hydration, and quality sleep to restore balance.',
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

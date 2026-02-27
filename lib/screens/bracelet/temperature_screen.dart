import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TemperatureScreen
// ─────────────────────────────────────────────────────────────────────────────
class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
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

                // ── Thermometer hero ─────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _TempHero(s: s, cw: cw),
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
// Temperature hero: thermometer painter + "37 C  Low"
// ─────────────────────────────────────────────────────────────────────────────
class _TempHero extends StatelessWidget {
  final double s;
  final double cw;
  const _TempHero({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final thermoH = cw * 0.52;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22 * s),
      child: Column(
        children: [
          SizedBox(
            width: cw * 0.28,
            height: thermoH,
            child: const CustomPaint(painter: _ThermometerPainter()),
          ),
          SizedBox(height: 14 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '37 C',
                style: GoogleFonts.inter(
                  fontSize: 46 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF43C6E4).withAlpha(130),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),
              Padding(
                padding: EdgeInsets.only(bottom: 7 * s),
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

// Thermometer: bulb at bottom, vertical tube, gradient fill, heat lines right side
class _ThermometerPainter extends CustomPainter {
  const _ThermometerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient: cyan top → purple bottom
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final strokeW = w * 0.12;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 2.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF43C6E4).withAlpha(55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // ── Tube (vertical line, top portion only – simulates partial fill) ──
    final tubeTop = h * 0.12;
    final tubeBottom = h * 0.72; // bottom connects to bulb
    final cx = w * 0.42;

    canvas.drawLine(Offset(cx, tubeTop), Offset(cx, tubeBottom), glowPaint);
    canvas.drawLine(Offset(cx, tubeTop), Offset(cx, tubeBottom), paint);

    // ── Bulb (filled circle at bottom) ──
    final bulbR = w * 0.36;
    final bulbCenter = Offset(cx, h * 0.84);

    final bulbFill = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF9F56F5), Color(0xFF43C6E4)],
      ).createShader(Rect.fromCircle(center: bulbCenter, radius: bulbR));

    final bulbGlow = Paint()
      ..color = const Color(0xFF9F56F5).withAlpha(80)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(bulbCenter, bulbR * 1.3, bulbGlow);
    canvas.drawCircle(bulbCenter, bulbR, bulbFill);

    // ── Heat lines (3 horizontal dashes to the right of the tube) ──
    final linePaint = Paint()
      ..color = const Color(0xFF43C6E4).withAlpha(180)
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    final lineX = cx + w * 0.22;
    for (int i = 0; i < 3; i++) {
      final y = tubeTop + (tubeBottom - tubeTop) * (0.15 + i * 0.22);
      final lineLen = w * (0.28 - i * 0.04);
      canvas.drawLine(
        Offset(lineX, y),
        Offset(lineX + lineLen, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 stat tiles: Highest 38C / Lowest 34C / Average 36C
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
      (label: 'Highest', value: '38 C', icon: Icons.arrow_upward_rounded,
        color: Color(0xFF4CAF50)),
      (label: 'Lowest',  value: '34 C', icon: Icons.arrow_downward_rounded,
        color: Color(0xFFE53935)),
      (label: 'Average', value: '36 C', icon: Icons.remove_rounded,
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
                                  fontSize: 18 * s,
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
            child: CustomPaint(painter: _TempBarPainter(s: s)),
          ),
        ],
      ),
    );
  }
}

class _TempBarPainter extends CustomPainter {
  final double s;
  const _TempBarPainter({required this.s});

  // Temperature values in °C — vary around 32-40 range
  static const _raw = [
    33.0, 34.5, 35.0, 36.0, 37.5, 38.0, 37.8, 38.2, 37.5, 36.8,
    36.0, 35.5, 35.0, 35.8, 36.5, 37.0, 37.8, 38.0, 37.5, 37.0,
    36.5, 35.8, 35.0, 34.5,
  ];
  static const _yLabels = ['40 C', '36 C', '33 C', '32 C'];
  static const _yTicks = [40.0, 36.0, 33.0, 32.0];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 32.0 * s;
    final xLabelH = 18.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    const minVal = 31.0;
    const maxVal = 40.0;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final dashPaint = Paint()
      ..color = const Color(0xFFE53935).withAlpha(50)
      ..strokeWidth = 1;

    // Y labels + dashed lines
    for (int i = 0; i < _yLabels.length; i++) {
      final yFrac = 1.0 - (_yTicks[i] - minVal) / (maxVal - minVal);
      final y = chartH * yFrac;

      tp
        ..text = TextSpan(
            text: _yLabels[i],
            style: TextStyle(fontSize: 7.5 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // Bars — salmon/red color matching reference
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
          ..color = const Color(0xFFE57373).withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Gradient fill
      canvas.drawRRect(
        rRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEF9A9A), Color(0xFFE53935)],
          ).createShader(Rect.fromLTWH(x, 0, barW, chartH)),
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
  bool shouldRepaint(_TempBarPainter old) => old.s != s;
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
                  'Your skin temperature is trending above your normal range. '
                  'This can be an early signal of physical strain, dehydration, '
                  'or the body responding to internal stress.',
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

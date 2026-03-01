import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeartScreen – Heart Rate detail page
// ─────────────────────────────────────────────────────────────────────────────
class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

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
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
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

                // ── Glowing heart + BPM ───────────────────────────────
                _HeartBpm(s: s),
                SizedBox(height: 4 * s),

                // ── ECG waveform strip ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 130 * s,
                  child: CustomPaint(
                    painter: _EcgPainter(s: s),
                  ),
                ),
                SizedBox(height: 20 * s),

                // ── Stats table ───────────────────────────────────────
                _StatsTable(s: s),
                SizedBox(height: 16 * s),

                // ── Heart Rate History card ───────────────────────────
                _BorderCard(
                  s: s,
                  width: cw,
                  child: _HistoryCard(s: s, cw: cw),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight card ───────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Glowing heart + 72 BPM
// ─────────────────────────────────────────────────────────────────────────────
class _HeartBpm extends StatelessWidget {
  final double s;
  const _HeartBpm({required this.s});

  @override
  Widget build(BuildContext context) {
    const heartColor = Color(0xFFE83B5C);
    final heartSize = 130.0 * s; // Slightly smaller to make room for glow

    return Center(
      child: Container(
        width: 300 * s,
        height: 300 * s,
        decoration: BoxDecoration(
          // Atmospheric red fog glow
          gradient: RadialGradient(
            colors: [
              heartColor.withOpacity(0.25),
              heartColor.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Outer PNG Glow (layered)
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/fonts/heartglow(1).png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // ── Main heart ──
            _HeartShape(size: heartSize, color: heartColor),

            // ── BPM text ──
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '-1',
                      style: GoogleFonts.inter(
                        fontSize: 52 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      'BPM',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartShape extends StatelessWidget {
  final double size;
  final Color color;
  const _HeartShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HeartPainter(color),
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  const _HeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final path = Path();
    // Plumper, rounder heart for Figma style
    path.moveTo(w / 2, h * 0.82);
    path.cubicTo(w * 1.08, h * 0.52, w * 0.85, h * 0.08, w / 2, h * 0.28);
    path.cubicTo(w * 0.15, h * 0.08, w * -0.08, h * 0.52, w / 2, h * 0.82);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// ECG waveform painter
// ─────────────────────────────────────────────────────────────────────────────
class _EcgPainter extends CustomPainter {
  final double s;
  const _EcgPainter({required this.s});

  static const _pts = [
    Offset(0.00, 0.70), Offset(0.05, 0.25), Offset(0.08, 0.85),
    Offset(0.14, 0.65), Offset(0.22, 0.75), Offset(0.30, 0.68),
    Offset(0.38, 0.80), Offset(0.48, 0.72), Offset(0.55, 0.78),
    Offset(0.62, 0.20), Offset(0.66, 0.78), Offset(0.74, 0.72),
    Offset(0.82, 0.78), Offset(0.90, 0.74), Offset(1.00, 0.76),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scaled = _pts
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = Path()..moveTo(scaled.first.dx, scaled.first.dy);
    for (int i = 1; i < scaled.length; i++) {
      path.lineTo(scaled[i].dx, scaled[i].dy);
    }

    // Glow stroke
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10 * s
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE83B5C).withAlpha(90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Main stroke
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE83B5C),
    );

    // Glowing dot at peak
    final dot = scaled[(_pts.length * 0.65).floor()];
    canvas.drawCircle(
      dot,
      14 * s,
      Paint()
        ..color = const Color(0xFFE83B5C).withAlpha(77)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(dot, 5 * s, Paint()..color = const Color(0xFFE83B5C));
  }

  @override
  bool shouldRepaint(_EcgPainter old) => old.s != s;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats table
// ─────────────────────────────────────────────────────────────────────────────
class _StatsTable extends StatelessWidget {
  final double s;
  const _StatsTable({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HEART RATE',
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10 * s),
        Divider(color: AppColors.divider, height: 1),
        _StatLine(s: s, label: 'Average Rate', value: '-1', unit: 'BPM'),
        Divider(color: AppColors.divider, height: 1),
        _StatLine(s: s, label: 'Max Heart Rate', value: '-1', unit: 'BPM'),
        Divider(color: AppColors.divider, height: 1),
        _StatLine(s: s, label: 'Resting', value: '-1', unit: 'BPM'),
        Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final String unit;
  const _StatLine(
      {required this.s,
      required this.label,
      required this.value,
      required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * s),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: AppColors.textLight,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '  $unit',
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    color: AppColors.labelDim,
                    fontWeight: FontWeight.w400,
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

// ─────────────────────────────────────────────────────────────────────────────
// Heart Rate History chart card
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatefulWidget {
  final double s;
  final double cw;
  const _HistoryCard({required this.s, required this.cw});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  String _period = 'TODAY';

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final cw = widget.cw;
    return Padding(
      padding: EdgeInsets.all(14 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + period picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HEART RATE\nHISTORY',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                  letterSpacing: 0.4,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final options = ['TODAY', 'WEEK', 'MONTH'];
                  final next = options[
                      (options.indexOf(_period) + 1) % options.length];
                  setState(() => _period = next);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * s, vertical: 5 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6 * s),
                    color: const Color(0xFF0A1820),
                    border: Border.all(
                        color: const Color(0xFF1E3040), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _period,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.cyan, size: 13 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          // Chart
          SizedBox(
            width: cw - 28 * s,
            height: 140 * s,
            child: CustomPaint(
              painter: _ChartPainter(s: s),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line chart painter for history
// ─────────────────────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final double s;
  const _ChartPainter({required this.s});

  // Heart rate values across 24h (one per hour, 0..23 + closing 24)
  static const _data = [
    72.0, 68.0, 65.0, 63.0, 61.0, 60.0,   // 00-05 (sleeping, low)
    75.0, 90.0, 105.0, 118.0, 125.0, 130.0, // 06-11 (morning activity peak)
    115.0, 100.0, 95.0, 140.0, 138.0, 120.0, // 12-17 (afternoon, spike)
    105.0, 95.0, 88.0, 82.0, 78.0, 74.0,    // 18-23 (evening winding down)
    72.0,                                    // 24 (back to start)
  ];

  static const _yMin = 40.0;
  static const _yMax = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3040)
      ..strokeWidth = 0.8;

    final linePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.0 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0x55E53935)
      ..strokeWidth = 5.0 * s
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final labelStyle = GoogleFonts.inter(
      fontSize: 9 * s,
      color: AppColors.labelDim,
    );

    final leftPad = 30.0 * s;
    final bottomPad = 20.0 * s;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Y-axis grid lines + labels
    final yLabels = [200.0, 160.0, 120.0, 80.0, 40.0];
    for (final yVal in yLabels) {
      final y = chartH * (1 - (yVal - _yMin) / (_yMax - _yMin));
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );
      _drawText(canvas, '${yVal.toInt()}', Offset(0, y - 5 * s),
          labelStyle, size.width);
    }

    // X-axis labels
    final xLabels = ['00', '06', '12', '18', '00'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPad + (i / (xLabels.length - 1)) * chartW;
      _drawText(
          canvas, xLabels[i], Offset(x - 8 * s, size.height - 14 * s),
          labelStyle, size.width);
    }

    // Data path
    final path = Path();
    for (int i = 0; i < _data.length; i++) {
      final t = i / (_data.length - 1);
      final x = leftPad + t * chartW;
      final y = chartH * (1 - (_data[i] - _yMin) / (_yMax - _yMin));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth cubic bezier
        final prevT = (i - 1) / (_data.length - 1);
        final prevX = leftPad + prevT * chartW;
        final prevY =
            chartH * (1 - (_data[i - 1] - _yMin) / (_yMax - _yMin));
        final cp1x = prevX + (x - prevX) * 0.5;
        path.cubicTo(cp1x, prevY, cp1x, y, x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset,
      TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.s != s;
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
          // Title row
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
          // Insight text
          Text(
            'Your resting heart rate is higher than expected for this time of day. '
            'This may indicate fatigue, stress, or insufficient recovery. '
            'Consider slowing down and allowing your body to recalibrate.',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

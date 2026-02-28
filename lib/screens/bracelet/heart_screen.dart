import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeartScreen – Heart Rate detail page
// ─────────────────────────────────────────────────────────────────────────────
class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;

    return BraceletScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HI, USER ─────────────────────────────────────────
          Center(
            child: Text(
              'HI, USER',
              style: AppStyles.lemon10(
                s,
              ).copyWith(color: AppColors.labelDim, letterSpacing: 2.0),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Glowing heart + BPM ───────────────────────────────
          _HeartBpm(s: s),
          SizedBox(height: 4 * s),

          // ── ECG waveform strip ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 140 * s,
            child: CustomPaint(painter: _EcgPainter(s: s)),
          ),
          SizedBox(height: 20 * s),

          // ── Stats table ───────────────────────────────────────
          _StatsTable(s: s),
          SizedBox(height: 30 * s),

          // ── Heart Rate History card ───────────────────────────
          _BorderCard(
            s: s,
            child: _HistoryCard(s: s),
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
      painter: SmoothGradientBorder(radius: 25 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25 * s),
        child: Container(
          color: const Color(0xFF060E16).withValues(alpha: 0.8),
          child: child,
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
    const color = Color(0xFFE83B5C);

    // 🔥 Bigger heart
    final heartSize = 320.0 * s;

    return Center(
      child: SizedBox(
        width: heartSize * 1.5,
        height: heartSize * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// ─────────────────────────────────────────────
            /// LAYER 1 — Ambient Big Soft Glow
            /// ─────────────────────────────────────────────
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50 * s, sigmaY: 50 * s),
              child: Opacity(
                opacity: 0.25,
                child: _HeartShape(size: heartSize * 1.2, color: color),
              ),
            ),

            /// ─────────────────────────────────────────────
            /// LAYER 2 — Medium Glow
            /// ─────────────────────────────────────────────
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25 * s, sigmaY: 25 * s),
              child: Opacity(
                opacity: 0.45,
                child: _HeartShape(size: heartSize * 1.08, color: color),
              ),
            ),

            /// ─────────────────────────────────────────────
            /// LAYER 3 — Strong Inner Glow
            /// ─────────────────────────────────────────────
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
              child: Opacity(
                opacity: 0.7,
                child: _HeartShape(size: heartSize * 1.02, color: color),
              ),
            ),

            /// ─────────────────────────────────────────────
            /// MAIN HEART
            /// ─────────────────────────────────────────────
            _HeartShape(size: heartSize, color: color),

            /// ─────────────────────────────────────────────
            /// BPM TEXT (Centered Properly)
            /// ─────────────────────────────────────────────
            // Offset the text slightly to align with visual center
            Positioned(
              top: (heartSize * 1.1 - 100 * s) / 2 + 10 * s,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '89',
                    style: AppStyles.bold22(s).copyWith(
                      fontSize: 92 * s,
                      height: 1.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    'BPM',
                    style: AppStyles.lemon12(
                      s,
                    ).copyWith(color: Colors.white, letterSpacing: 2.0),
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

class _HeartShape extends StatelessWidget {
  final double size;
  final Color color;
  const _HeartShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _HeartPainter(color));
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
    path.moveTo(w / 2, h * 0.85);
    path.cubicTo(w * 1.05, h * 0.55, w * 0.85, h * 0.05, w / 2, h * 0.28);
    path.cubicTo(w * 0.15, h * 0.05, w * -0.05, h * 0.55, w / 2, h * 0.85);
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
    Offset(0.0, 0.7),
    Offset(0.05, 0.4),
    Offset(0.08, 0.8),
    Offset(0.12, 0.1),
    Offset(0.16, 0.9),
    Offset(0.2, 0.6),
    Offset(0.25, 0.75),
    Offset(0.3, 0.5),
    Offset(0.35, 0.8),
    Offset(0.4, 0.6),
    Offset(0.45, 0.7),
    Offset(0.5, 0.4),
    Offset(0.55, 0.8),
    Offset(0.6, 0.1),
    Offset(0.64, 0.95),
    Offset(0.68, 0.6),
    Offset(0.72, 0.7),
    Offset(0.76, 0.5),
    Offset(0.8, 0.8),
    Offset(0.84, 0.6),
    Offset(0.88, 0.7),
    Offset(0.92, 0.6),
    Offset(0.96, 0.75),
    Offset(1.0, 0.65),
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

    // Gradient stroke
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradient = LinearGradient(
      colors: [
        const Color(0xFFE83B5C),
        const Color(0xFFE83B5C).withValues(alpha: 0.3),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawPath(path, paint);

    // Glowing dot at a peak
    final peakIdx = 13; // Index in _pts representing a peak in the middle
    final dot = scaled[peakIdx];
    canvas.drawCircle(
      dot,
      8 * s,
      Paint()
        ..color = const Color(0xFFFF4D6D).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(dot, 4 * s, Paint()..color = const Color(0xFFFFFFFF));
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HEART RATE',
            style: AppStyles.lemon12(
              s,
            ).copyWith(color: Colors.white, letterSpacing: 0.5),
          ),
          SizedBox(height: 10 * s),
          _StatLine(s: s, label: 'Average Rate', value: '72', unit: 'BPM'),
          _StatLine(s: s, label: 'Max Heart Rate', value: '138', unit: 'BPM'),
          _StatLine(s: s, label: 'Resting', value: '49', unit: 'BPM'),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final String unit;
  const _StatLine({
    required this.s,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2C3E4A), width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(vertical: 10 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.reg12(s).copyWith(color: Colors.white)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppStyles.bold22(s).copyWith(fontSize: 20 * s),
              ),
              SizedBox(width: 4 * s),
              Text(unit, style: AppStyles.bold10(s).copyWith(fontSize: 8 * s)),
            ],
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
  const _HistoryCard({required this.s});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  String _period = 'TODAY';

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Padding(
      padding: EdgeInsets.all(20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HEART RATE\nHISTORY',
                style: AppStyles.lemon12(s).copyWith(height: 1.2),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * s),
                  color: const Color(0xFF2C3E4A).withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    Text(
                      _period,
                      style: AppStyles.bold10(s).copyWith(fontSize: 8 * s),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white,
                      size: 16 * s,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          AspectRatio(
            aspectRatio: 1.8,
            child: CustomPaint(painter: _ChartPainter(s: s)),
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

  static const _data = [
    72.0,
    85.0,
    160.0,
    140.0,
    100.0,
    80.0,
    100.0,
    85.0,
    95.0,
    110.0,
    120.0,
    180.0,
    140.0,
    100.0,
    80.0,
    90.0,
    100.0,
    110.0,
    120.0,
    180.0,
    160.0,
    120.0,
    100.0,
    80.0,
    160.0,
    140.0,
    100.0,
    80.0,
  ];

  static const _yMin = 40.0;
  static const _yMax = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    final gridBasePaint = Paint()
      ..color = const Color(0xFF1E2E3A).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    final linePaint = Paint()
      ..color = const Color(0xFFE83B5C)
      ..strokeWidth = 3.0 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftPad = 30.0 * s;
    final bottomPad = 25.0 * s;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Draw background grid (static as per screenshot)
    // Horizontal lines
    final yPoints = [0.0, 0.25, 0.5, 0.75, 1.0];
    final yLabels = ['200', '160', '120', '80', '40'];
    for (int i = 0; i < yPoints.length; i++) {
      final y = chartH * yPoints[i];
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridBasePaint);
      _drawText(
        canvas,
        yLabels[i],
        Offset(0, y - 6 * s),
        AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
        leftPad,
      );
    }

    // Vertical lines
    for (int i = 0; i < 6; i++) {
      final x = leftPad + (i / 5) * chartW;
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), gridBasePaint);
    }

    // X-axis labels
    final xLabels = ['00', '06', '12', '18', '00'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPad + (i / (xLabels.length - 1)) * chartW;
      _drawText(
        canvas,
        xLabels[i],
        Offset(x - 6 * s, chartH + 8 * s),
        AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
        40 * s,
      );
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
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    double maxWidth,
  ) {
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
      padding: EdgeInsets.all(20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purple],
                ).createShader(bounds),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20 * s,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8 * s),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purple],
                ).createShader(bounds),
                child: Text('AI INSIGHT', style: AppStyles.lemon12(s)),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            'Your resting heart rate is higher than expected for this time of day. '
            'This may indicate fatigue, stress, or insufficient recovery. '
            'Consider slowing down and allowing your body to recalibrate.',
            style: AppStyles.reg12(
              s,
            ).copyWith(color: AppColors.textLight, height: 1.6),
          ),
        ],
      ),
    );
  }
}

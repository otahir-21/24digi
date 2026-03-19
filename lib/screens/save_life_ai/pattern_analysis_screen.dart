import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _C {
  _C._();
  static const bg = Color(0xFF090910);
  static const card = Color(0xFF111118);
  static const cardBorder = Color(0xFF222230);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const orange = Color(0xFFFF8C00);
  static const blue = Color(0xFF5C8AFF);
  static const yellow = Color(0xFFFFB300);
  static const chartGrid = Color(0xFF1E1E2E);
}

class PatternAnalysisScreen extends StatelessWidget {
  final String riskType;
  const PatternAnalysisScreen({super.key, this.riskType = 'Metabolic Risk'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            const DigiPillHeader(),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('HI, USER',
                  style: TextStyle(
                      color: _C.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6)),
            ),
            const SizedBox(height: 16),
            _PageHeader(
              title: 'Pattern Analysis',
              subtitle: riskType,
              icon: Icons.bar_chart_rounded,
              iconColor: _C.blue,
            ),
            const SizedBox(height: 20),
            const _HistoricalPatterns(),
            const SizedBox(height: 16),
            const _DayNightComparison(),
            const SizedBox(height: 16),
            const _WeeklyPattern(),
            const SizedBox(height: 16),
            const _BehavioralCorrelations(),
            const SizedBox(height: 16),
            _PatternSummary(riskType: riskType),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _C.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: const TextStyle(color: _C.grey1, fontSize: 13)),
          ],
        ),
      ]),
    );
  }
}

class _HistoricalPatterns extends StatelessWidget {
  const _HistoricalPatterns();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historical Detection Patterns',
                style: TextStyle(
                    color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('30-day trend with baseline comparison',
                style: TextStyle(color: _C.grey1, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _LineChartPainter(),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _C.chartGrid
      ..strokeWidth = 1;

    final axisStyle = const TextStyle(color: _C.grey2, fontSize: 10);

    // Draw horizontal grid lines
    const ySteps = [0, 15, 30, 45, 60];
    for (var i = 0; i < ySteps.length; i++) {
      final y = size.height - (ySteps[i] / 60 * size.height);
      // Dashed grid line
      _drawDashedLine(canvas, Offset(30, y), Offset(size.width, y), gridPaint);
      
      final tp = TextPainter(
        text: TextSpan(text: '${ySteps[i]}', style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(25 - tp.width, y - tp.height / 2));
    }

    // Draw vertical grid lines
    const xLabels = ['25', '28', '31', '03', '06', '09', '11', '13', '15', '17', '20', '23'];
    final xStep = (size.width - 40) / (xLabels.length - 1);
    for (var i = 0; i < xLabels.length; i++) {
      final x = 30 + i * xStep;
      _drawVerticalDashedLine(canvas, Offset(x, 0), Offset(x, size.height), gridPaint);
      
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height + 5));
    }

    // Draw trend line
    final trendPaint = Paint()
      ..color = _C.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final data = [48, 45, 50, 49, 51, 47, 49, 52, 50, 48, 51, 50, 52, 49, 51, 53, 51, 54, 55, 53, 56, 54, 55];
    final dx = (size.width - 40) / (data.length - 1);
    for (var i = 0; i < data.length; i++) {
      final px = 30 + i * dx;
      final py = size.height - (data[i] / 60 * size.height);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, trendPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + dashWidth, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  void _drawVerticalDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashHeight = 4;
    const dashSpace = 4;
    double startY = p1.dy;
    while (startY < p2.dy) {
      canvas.drawLine(Offset(p1.dx, startY), Offset(p1.dx, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DayNightComparison extends StatelessWidget {
  const _DayNightComparison();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Day vs Night Comparison',
                style: TextStyle(
                    color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Metric variation across 24 hours',
                style: TextStyle(color: _C.grey1, fontSize: 12)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.wb_sunny_outlined, color: _C.orange, size: 14),
                          SizedBox(width: 4),
                          Text('Daytime (6AM-10PM)',
                              style: TextStyle(color: _C.white, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: CustomPaint(
                          painter: _SmallLineChartPainter(
                              data: [80, 85, 75, 70, 65, 60, 65],
                              yMax: 100,
                              ySteps: [0, 25, 50, 75, 100],
                              xLabels: ['6h', '10h', '14h', '18h'],
                              color: _C.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.nightlight_outlined, color: Color(0xFF9FA8DA), size: 14),
                          SizedBox(width: 4),
                          Text('Nighttime (10PM-6AM)',
                              style: TextStyle(color: _C.white, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: CustomPaint(
                          painter: _SmallLineChartPainter(
                              data: [60, 65, 70, 70, 68, 65, 60],
                              yMax: 80,
                              ySteps: [0, 20, 40, 60, 80],
                              xLabels: ['1h', '3h', '5h', '7h'],
                              color: Color(0xFF7E87FA)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallLineChartPainter extends CustomPainter {
  final List<double> data;
  final double yMax;
  final List<double> ySteps;
  final List<String> xLabels;
  final Color color;

  _SmallLineChartPainter({
    required this.data,
    required this.yMax,
    required this.ySteps,
    required this.xLabels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _C.chartGrid
      ..strokeWidth = 0.5;

    final axisStyle = const TextStyle(color: _C.grey2, fontSize: 8);

    for (var yVal in ySteps) {
      final y = size.height - (yVal / yMax * size.height);
      canvas.drawLine(Offset(20, y), Offset(size.width, y), gridPaint);
      
      final tp = TextPainter(
        text: TextSpan(text: '${yVal.toInt()}', style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(18 - tp.width, y - tp.height / 2));
    }

    canvas.drawLine(Offset(20, 0), Offset(20, size.height), gridPaint);

    final trendPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final dx = (size.width - 20) / (data.length - 1);
    for (var i = 0; i < data.length; i++) {
      final px = 20 + i * dx;
      final py = size.height - (data[i] / yMax * size.height);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, trendPaint);

    for (var i = 0; i < xLabels.length; i++) {
      final px = 20 + i * (size.width - 20) / (xLabels.length - 1);
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, size.height + 4));
    }
    
    // x axis labels
    for (var i = 0; i < xLabels.length; i++) {
        final x = 20 + i * (size.width - 20) / (xLabels.length - 1);
        canvas.drawLine(Offset(x, size.height), Offset(x, size.height + 3), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WeeklyPattern extends StatelessWidget {
  const _WeeklyPattern();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Pattern',
                style: TextStyle(
                    color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Average metric values by day of week',
                style: TextStyle(color: _C.grey1, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _BarChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _C.chartGrid
      ..strokeWidth = 1;

    final axisStyle = const TextStyle(color: _C.grey2, fontSize: 10);

    const ySteps = [0, 25, 50, 75, 100];
    for (var i = 0; i < ySteps.length; i++) {
      final y = size.height - (ySteps[i] / 100 * size.height);
      _drawDashedLine(canvas, Offset(25, y), Offset(size.width, y), gridPaint);
      
      final tp = TextPainter(
        text: TextSpan(text: '${ySteps[i]}', style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(22 - tp.width, y - tp.height / 2));
    }

    final barPaint = Paint()..color = const Color(0xFFAD5A1B);
    const data = [82.0, 78.0, 75.0, 68.0, 70.0, 65.0, 68.0];
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final barWidth = (size.width - 30) / (data.length) * 0.7;
    final spacing = (size.width - 30) / (data.length);

    for (var i = 0; i < data.length; i++) {
        final x = 30 + i * spacing + (spacing - barWidth) / 2;
        final y = size.height - (data[i] / 100 * size.height);
        
        canvas.drawRRect(
            RRect.fromRectAndCorners(
                Rect.fromLTWH(x, y, barWidth, size.height - y),
                topLeft: const Radius.circular(4),
                topRight: const Radius.circular(4),
            ),
            barPaint
        );

        final tp = TextPainter(
            text: TextSpan(text: labels[i], style: axisStyle),
            textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barWidth / 2 - tp.width / 2, size.height + 5));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + dashWidth, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BehavioralCorrelations extends StatelessWidget {
  const _BehavioralCorrelations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Behavioral Correlations',
                style: TextStyle(
                    color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('How different factors correlate with this condition',
                style: TextStyle(color: _C.grey1, fontSize: 12)),
            const SizedBox(height: 20),
            _correlationRow('Activity Level', 0.82, '82%', 'Inverse', _C.orange),
            const SizedBox(height: 12),
            _correlationRow('Sleep Quality', 0.71, '71%', 'Inverse', _C.orange),
            const SizedBox(height: 12),
            _correlationRow('Blood Pressure', 0.68, '68%', 'Direct', _C.yellow),
            const SizedBox(height: 12),
            _correlationRow('Sedentary Time', 0.75, '75%', 'Direct', _C.orange),
          ],
        ),
      ),
    );
  }

  Widget _correlationRow(String label, double val, String percent, String type, Color color) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: _C.white, fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 12,
              backgroundColor: _C.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(percent, style: const TextStyle(color: _C.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        SizedBox(width: 50, child: Text(type, style: const TextStyle(color: _C.grey1, fontSize: 11))),
      ],
    );
  }
}

class _PatternSummary extends StatelessWidget {
  final String riskType;
  const _PatternSummary({required this.riskType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF1A237E), fontSize: 14, height: 1.5),
            children: [
              const TextSpan(
                  text: 'SafeLife Pattern Summary: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'Based on pattern analysis, your ${riskType.toLowerCase()} indicators show some variation that warrants ongoing monitoring. The strongest correlation is with activity level '),
              TextSpan(
                  text: '(82% correlation).',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

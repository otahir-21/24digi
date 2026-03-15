import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeartScreen – Heart Rate detail page, shows live BPM from bracelet (type 24).
// ─────────────────────────────────────────────────────────────────────────────

/// Single timestamped HR reading collected during this screen session.
class _HrSample {
  final DateTime time;
  final int bpm;
  const _HrSample(this.time, this.bpm);
}

class HeartScreen extends StatefulWidget {
  const HeartScreen({super.key, this.channel, this.liveData});
  final BraceletChannel? channel;
  final Map<String, dynamic>? liveData;

  @override
  State<HeartScreen> createState() => _HeartScreenState();
}

class _HeartScreenState extends State<HeartScreen> {
  int? _currentBpm;
  StreamSubscription<BraceletEvent>? _subscription;

  /// All readings collected since the screen was opened (capped at ~10 min).
  final List<_HrSample> _hrReadings = [];

  // ── Computed stats ──────────────────────────────────────────────────────────
  int? get _avgBpm {
    if (_hrReadings.isEmpty) return _currentBpm;
    final sum = _hrReadings.fold(0, (a, b) => a + b.bpm);
    return (sum / _hrReadings.length).round();
  }

  int? get _maxBpm {
    if (_hrReadings.isEmpty) return null;
    return _hrReadings.map((s) => s.bpm).reduce(max);
  }

  /// Resting = lowest sustained reading (10th-percentile to avoid noise).
  int? get _restingBpm {
    if (_hrReadings.length < 5) return null;
    final sorted = _hrReadings.map((s) => s.bpm).toList()..sort();
    return sorted[(sorted.length * 0.1).floor()];
  }

  static int? _parseBpm(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _applyLiveData(widget.liveData);
    if (widget.channel != null) {
      _subscription = widget.channel!.events.listen((BraceletEvent e) {
        if (!mounted) return;

        // Handle disconnect → clear live BPM
        if (e.event == 'connectionState') {
          if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
            setState(() => _currentBpm = null);
          }
          return;
        }

        if (e.event != 'realtimeData') return;
        final dataType = e.data['dataType'];
        final dic = e.data['dicData'];
        if (dic == null || dic is! Map) return;

        final dicMap = Map<String, dynamic>.from(
          (dic as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );

        final type = dataType is int
            ? dataType
            : (dataType is num ? dataType.toInt() : null);
        if (type != 24) return;

        final hr = _parseBpm(dicMap['heartRate'] ?? dicMap['HeartRate']);
        if (hr != null && hr >= 30 && hr <= 250) {
          setState(() {
            _currentBpm = hr;
            _hrReadings.add(_HrSample(DateTime.now(), hr));
            // Keep ~10 min of data at ~1 reading/sec
            if (_hrReadings.length > 600) _hrReadings.removeAt(0);
          });
        }
      });
    }
  }

  void _applyLiveData(Map<String, dynamic>? data) {
    if (data == null) return;
    final hr = _parseBpm(data['heartRate'] ?? data['HeartRate']);
    if (hr != null && hr >= 30 && hr <= 250) {
      _currentBpm = hr;
      _hrReadings.add(_HrSample(DateTime.now(), hr));
    }
  }

  @override
  void dispose() {
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return BraceletScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HI, USER ─────────────────────────────────────────
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name?.trim();
              final greeting = (name != null && name.isNotEmpty)
                  ? 'HI, ${name.toUpperCase()}'
                  : 'HI';
              return Center(
                child: Text(
                  greeting,
                  style: AppStyles.lemon10(s).copyWith(
                    color: AppColors.labelDim,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20 * s),

          // ── Glowing heart + BPM ───────────────────────────────
          _HeartBpm(s: s, bpm: _currentBpm),
          SizedBox(height: 4 * s),

          // ── ECG waveform strip ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 140 * s,
            child: CustomPaint(painter: _EcgPainter(s: s)),
          ),
          SizedBox(height: 20 * s),

          // ── Stats table ───────────────────────────────────────
          _StatsTable(
            s: s,
            avgBpm: _avgBpm,
            maxBpm: _maxBpm,
            restingBpm: _restingBpm,
          ),
          SizedBox(height: 30 * s),

          // ── Heart Rate History card ───────────────────────────
          _BorderCard(
            s: s,
            child: _HistoryCard(s: s, readings: List.unmodifiable(_hrReadings)),
          ),
          SizedBox(height: 14 * s),

          // ── AI Insight card ───────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(s: s, bpm: _currentBpm),
          ),
          SizedBox(height: 24 * s),
          SizedBox(height: 40 * s),
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
// Glowing heart + live BPM
// ─────────────────────────────────────────────────────────────────────────────
class _HeartBpm extends StatelessWidget {
  final double s;
  final int? bpm;
  const _HeartBpm({required this.s, this.bpm});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFE83B5C);
    final heartSize = 320.0 * s;

    return Center(
      child: SizedBox(
        width: heartSize * 1.5,
        height: heartSize * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50 * s, sigmaY: 50 * s),
              child: Opacity(
                opacity: 0.25,
                child: _HeartShape(size: heartSize * 1.2, color: color),
              ),
            ),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25 * s, sigmaY: 25 * s),
              child: Opacity(
                opacity: 0.45,
                child: _HeartShape(size: heartSize * 1.08, color: color),
              ),
            ),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
              child: Opacity(
                opacity: 0.7,
                child: _HeartShape(size: heartSize * 1.02, color: color),
              ),
            ),
            _HeartShape(size: heartSize, color: color),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bpm != null ? bpm.toString() : '--',
                      style: AppStyles.bold22(s).copyWith(
                        fontSize: 92 * s,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'BPM',
                      style: AppStyles.lemon12(s).copyWith(
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
// ECG waveform painter (decorative)
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

    const peakIdx = 13;
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
// Stats table – real values computed from session readings
// ─────────────────────────────────────────────────────────────────────────────
class _StatsTable extends StatelessWidget {
  final double s;
  final int? avgBpm;
  final int? maxBpm;
  final int? restingBpm;

  const _StatsTable({
    required this.s,
    this.avgBpm,
    this.maxBpm,
    this.restingBpm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HEART RATE',
            style: AppStyles.lemon12(s).copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10 * s),
          _StatLine(
            s: s,
            label: 'Average Rate',
            value: avgBpm?.toString() ?? '--',
            unit: 'BPM',
          ),
          _StatLine(
            s: s,
            label: 'Max Heart Rate',
            value: maxBpm?.toString() ?? '--',
            unit: 'BPM',
          ),
          _StatLine(
            s: s,
            label: 'Resting',
            value: restingBpm?.toString() ?? '--',
            unit: 'BPM',
          ),
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
          Text(
            label,
            style: AppStyles.reg12(s).copyWith(color: Colors.white),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppStyles.bold22(s).copyWith(fontSize: 20 * s),
              ),
              SizedBox(width: 4 * s),
              Text(
                unit,
                style: AppStyles.bold10(s).copyWith(fontSize: 8 * s),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Heart Rate History chart card – real session data
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatefulWidget {
  final double s;
  final List<_HrSample> readings;
  const _HistoryCard({required this.s, required this.readings});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  String _period = 'TODAY';
  static const _periods = ['TODAY', 'WEEK', 'MONTH'];

  /// Downsample readings to at most [maxPoints] evenly spaced values.
  List<double> _chartData(int maxPoints) {
    final src = widget.readings;
    if (src.isEmpty) return [];
    if (src.length <= maxPoints) return src.map((s) => s.bpm.toDouble()).toList();
    final step = src.length / maxPoints;
    return List.generate(
      maxPoints,
      (i) => src[(i * step).floor()].bpm.toDouble(),
    );
  }

  String _xLabelStart() {
    if (widget.readings.isEmpty) return '--:--';
    final t = widget.readings.first.time;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _xLabelEnd() {
    if (widget.readings.isEmpty) return '--:--';
    final t = widget.readings.last.time;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _showPeriodMenu(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height,
        offset.dx + box.size.width,
        0,
      ),
      color: const Color(0xFF0D1B26),
      items: _periods
          .map(
            (p) => PopupMenuItem<String>(
              value: p,
              child: Text(
                p,
                style: AppStyles.bold10(widget.s).copyWith(
                  color: p == _period ? AppColors.cyan : Colors.white,
                ),
              ),
            ),
          )
          .toList(),
    );
    if (selected != null && mounted) {
      setState(() => _period = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final data = _period == 'TODAY' ? _chartData(28) : <double>[];
    final hasData = data.isNotEmpty;

    return Padding(
      padding: EdgeInsets.all(20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HEART RATE\nHISTORY',
                style: AppStyles.lemon12(s).copyWith(height: 1.2),
              ),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => _showPeriodMenu(ctx),
                  child: Container(
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
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),

          // ── Chart or empty state ───────────────────────────────
          if (hasData)
            AspectRatio(
              aspectRatio: 1.8,
              child: CustomPaint(
                painter: _ChartPainter(
                  s: s,
                  data: data,
                  xStart: _xLabelStart(),
                  xEnd: _xLabelEnd(),
                ),
              ),
            )
          else
            SizedBox(
              height: 100 * s,
              child: Center(
                child: Text(
                  _period == 'TODAY'
                      ? 'Wear your bracelet to record heart rate history.'
                      : 'History is available for the current session only.\nLong-term history coming soon.',
                  textAlign: TextAlign.center,
                  style: AppStyles.reg12(s).copyWith(
                    color: AppColors.labelDim,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line chart painter – accepts real data
// ─────────────────────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final double s;
  final List<double> data;
  final String xStart;
  final String xEnd;

  const _ChartPainter({
    required this.s,
    required this.data,
    required this.xStart,
    required this.xEnd,
  });

  static const _yMin = 40.0;
  static const _yMax = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gridPaint = Paint()
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

    // Horizontal grid lines + y labels
    final yPoints = [0.0, 0.25, 0.5, 0.75, 1.0];
    final yLabels = ['200', '160', '120', '80', '40'];
    for (int i = 0; i < yPoints.length; i++) {
      final y = chartH * yPoints[i];
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );
      _drawText(
        canvas,
        yLabels[i],
        Offset(0, y - 6 * s),
        AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
        leftPad,
      );
    }

    // Vertical grid lines
    for (int i = 0; i < 6; i++) {
      final x = leftPad + (i / 5) * chartW;
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), gridPaint);
    }

    // X-axis labels: start time → end time
    final midTime = ''; // omit mid labels for clarity
    final xLabels = [xStart, midTime, midTime, midTime, xEnd];
    for (int i = 0; i < xLabels.length; i++) {
      if (xLabels[i].isEmpty) continue;
      final x = leftPad + (i / (xLabels.length - 1)) * chartW;
      _drawText(
        canvas,
        xLabels[i],
        Offset(x - 10 * s, chartH + 8 * s),
        AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
        50 * s,
      );
    }

    // Data path
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final t = i / (data.length - 1);
      final x = leftPad + t * chartW;
      final clamped = data[i].clamp(_yMin, _yMax);
      final y = chartH * (1 - (clamped - _yMin) / (_yMax - _yMin));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient shader on the line
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFE83B5C),
        const Color(0xFFFF8FA3),
        const Color(0xFFE83B5C),
      ],
    );
    linePaint.shader = gradient.createShader(
      Rect.fromLTWH(leftPad, 0, chartW, chartH),
    );
    canvas.drawPath(path, linePaint);

    // Glowing dot at the latest reading
    if (data.isNotEmpty) {
      final lastX = leftPad + chartW;
      final lastClamped = data.last.clamp(_yMin, _yMax);
      final lastY = chartH * (1 - (lastClamped - _yMin) / (_yMax - _yMin));
      canvas.drawCircle(
        Offset(lastX, lastY),
        8 * s,
        Paint()
          ..color = const Color(0xFFFF4D6D).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        4 * s,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
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
  bool shouldRepaint(_ChartPainter old) =>
      old.data != data || old.xStart != old.xStart || old.s != s;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card – dynamic text based on actual BPM
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final int? bpm;
  const _AiInsightCard({required this.s, this.bpm});

  static String _insight(int? bpm) {
    if (bpm == null) {
      return 'Connect your bracelet to receive personalised heart rate insights.';
    }
    if (bpm < 50) {
      return 'Your heart rate is very low at $bpm BPM. This is common in trained athletes at rest. If you feel dizzy, short of breath, or unwell, consult a doctor.';
    }
    if (bpm < 60) {
      return 'Your heart rate is slightly below average at $bpm BPM. This often indicates good cardiovascular fitness or deep relaxation.';
    }
    if (bpm <= 80) {
      return 'Your heart rate is in a healthy resting range at $bpm BPM. Your cardiovascular system appears to be in good shape. Keep it up.';
    }
    if (bpm <= 100) {
      return 'Your heart rate is slightly elevated at $bpm BPM. This may be due to light activity, mild stress, or caffeine. Try slow, deep breathing to bring it down.';
    }
    if (bpm <= 120) {
      return 'Your heart rate is elevated at $bpm BPM. If you are not exercising, this could indicate stress or fatigue. Take a short break and rest.';
    }
    return 'Your heart rate is significantly elevated at $bpm BPM. If you are resting, this may indicate high stress or overexertion. Stop activity and rest immediately.';
  }

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
            _insight(bpm),
            style: AppStyles.reg12(s).copyWith(
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

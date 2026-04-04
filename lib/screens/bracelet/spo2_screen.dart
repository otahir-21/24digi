import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../core/app_constants.dart';
import '../../bracelet/data/bracelet_data_parser.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../painters/spo2_icon_painter.dart';
import '../../widgets/health_info_sheet.dart';
import '../../widgets/vitals_history_chart.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Spo2Screen — dedicated SpO2 measurement flow (live 57, then history 42/43).
// ─────────────────────────────────────────────────────────────────────────────
/// SpO2 types only: 57 = live measurement, 42 = automatic history, 43 = manual history. Type 24 is ignored.
const _spo2DataTypes = {57, 42, 43};

class Spo2Screen extends StatefulWidget {
  const Spo2Screen({super.key, this.channel, this.initialSpO2});

  final BraceletChannel? channel;
  final int? initialSpO2;

  @override
  State<Spo2Screen> createState() => _Spo2ScreenState();
}

class _Spo2ScreenState extends State<Spo2Screen> {
  int _periodIndex = 0;
  int? _spo2Value;
  bool _isMeasuring = false;
  bool _timeoutFired = false;
  StreamSubscription<BraceletEvent>? _subscription;
  Timer? _measurementTimeout;

  /// All valid SpO2 readings received this session (for stats + graph).
  final List<int> _spo2Readings = [];

  int? get _highest => _spo2Readings.isEmpty ? null : _spo2Readings.reduce((a, b) => a > b ? a : b);
  int? get _lowest => _spo2Readings.isEmpty ? null : _spo2Readings.reduce((a, b) => a < b ? a : b);
  int? get _average => _spo2Readings.isEmpty
      ? null
      : (_spo2Readings.reduce((a, b) => a + b) / _spo2Readings.length).round();

  @override
  void initState() {
    super.initState();
    if (widget.initialSpO2 != null &&
        widget.initialSpO2! >= 1 &&
        widget.initialSpO2! <= 100) {
      _spo2Value = widget.initialSpO2;
      _spo2Readings.add(widget.initialSpO2!);
    }
    if (widget.channel != null) {
      _isMeasuring = true;
      if (kDebugMode) debugPrint('[SpO2] live measurement started');
      widget.channel!.startSpo2Monitoring();
      _listenBracelet();
      _measurementTimeout = Timer(const Duration(seconds: 10), _onMeasurementTimeout);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(widget.channel!.requestAutomaticSpo2History());
      });
    }
  }

  @override
  void dispose() {
    _measurementTimeout?.cancel();
    // SpO2 stays enabled from bracelet dashboard connect; stopping here cleared the tile when leaving this screen.
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

  void _onMeasurementTimeout() {
    if (!mounted) return;
    _measurementTimeout = null;
    setState(() {
      _isMeasuring = false;
      _timeoutFired = true;
    });
    if (kDebugMode) debugPrint('[SpO2] fallback history request started (no live 57 in 10s)');
    widget.channel?.requestManualSpo2History();
    widget.channel?.requestAutomaticSpo2History();
  }

  void _listenBracelet() {
    _subscription?.cancel();
    _subscription = widget.channel!.events.listen((BraceletEvent e) {
      if (!mounted) return;
      if (e.event == 'connectionState') {
        if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
          setState(() {
            _spo2Value = null;
            _isMeasuring = false;
            _timeoutFired = false;
          });
        }
        return;
      }
      if (e.event != 'realtimeData') return;
      final type = BraceletDataParser.dataTypeAsInt(e.data['dataType']);
      if (type == null || !_spo2DataTypes.contains(type)) return;
      final dic = e.data['dicData'];
      if (dic == null || dic is! Map) return;
      final dicData = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final spo2 = BraceletDataParser.extractSpo2FromDicData(dicData);
      if (spo2 == null || spo2 < 1 || spo2 > 100) return;
      if (type == 57) {
        _measurementTimeout?.cancel();
        _measurementTimeout = null;
        if (kDebugMode) debugPrint('[SpO2] live 57 arrived spo2=$spo2%');
        BraceletChannel.lastKnownSpo2 = spo2;
        setState(() {
          _spo2Value = spo2;
          _isMeasuring = false;
          _spo2Readings.add(spo2);
          if (_spo2Readings.length > 100) _spo2Readings.removeAt(0);
        });
        return;
      }
      // History 42 or 43: use latest valid reading
      if (kDebugMode) debugPrint('[SpO2] latest valid SpO2 selected from type=$type -> $spo2%');
      BraceletChannel.lastKnownSpo2 = spo2;
      setState(() {
        _spo2Value = spo2;
        _spo2Readings.add(spo2);
        if (_spo2Readings.length > 100) _spo2Readings.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cw = AppConstants.getScaleWidth(context);

    return BraceletScaffold(
      actions: [
        HealthInfoButton(
          onTap: () {
            final v = _spo2Value;
            showHealthInfoSheet(
              context,
              HealthMetrics.spo2,
              currentValue: v != null ? v.toString() : null,
              currentRangeIndex: v == null
                  ? -1
                  : v >= 95 ? 0 : v >= 91 ? 1 : v >= 86 ? 2 : 3,
            );
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name?.trim();
              final greeting = (name != null && name.isNotEmpty)
                  ? 'HI, ${name.toUpperCase()}'
                  : 'HI';
              return Center(
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w300,
                    color: AppColors.labelDim,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32 * s),

          // ── Lungs Hero ───────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _LungsHero(
              s: s,
              cw: cw,
              spo2Value: _spo2Value,
            ),
          ),
          SizedBox(height: 28 * s),

          // ── Gradient Bar ─────────────────────────────────────────
          _SegmentedColorBar(
            s: s,
            value: _spo2Value != null
                ? (_spo2Value!.clamp(0, 100) / 100).toDouble()
                : 0.0,
          ),
          SizedBox(height: 28 * s),

          // ── Stat Tiles ───────────────────────────────────────────
          _StatTiles(
            s: s,
            cw: cw,
            highest: _highest,
            lowest: _lowest,
            average: _average,
          ),
          SizedBox(height: 24 * s),

          // ── Period Toggle ────────────────────────────────────────
          Center(
            child: _PeriodPillToggle(
              s: s,
              selected: _periodIndex,
              onTap: (i) => setState(() => _periodIndex = i),
            ),
          ),
          SizedBox(height: 24 * s),

          // ── Graph Card ───────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _GraphCard(
              s: s,
              cw: cw,
              period: _periodIndex,
              samples: List<int>.from(_spo2Readings),
            ),
          ),
          SizedBox(height: 28 * s),

          Divider(color: Colors.white.withAlpha(20), thickness: 1, height: 1),
          SizedBox(height: 28 * s),

          // ── AI Insight Card ──────────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(s: s, spo2Value: _spo2Value),
          ),
          SizedBox(height: 48 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

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
      painter: SmoothGradientBorder(radius: 32 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lungs hero: painted lungs + spo2 value
// ─────────────────────────────────────────────────────────────────────────────
class _LungsHero extends StatelessWidget {
  final double s;
  final double cw;
  final int? spo2Value;
  const _LungsHero({
    required this.s,
    required this.cw,
    this.spo2Value,
  });

  @override
  Widget build(BuildContext context) {
    final display = spo2Value != null ? '$spo2Value%' : '--';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36 * s),
      child: Column(
        children: [
          Spo2Icon(size: 150 * s),
          SizedBox(height: 24 * s),
          Text(
            display,
            style: GoogleFonts.inter(
              fontSize: 60 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient bar with indicator marker
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentedColorBar extends StatelessWidget {
  final double s;
  final double value; // 0..1
  const _SegmentedColorBar({required this.s, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(11 * s),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11 * s),
        child: CustomPaint(painter: _SegmentedBarPainter(value: value)),
      ),
    );
  }
}

class _SegmentedBarPainter extends CustomPainter {
  final double value;
  const _SegmentedBarPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;

    // Segments: Red(15%), Yellow(30%), Green(55%)
    final w1 = w * 0.15;
    final w2 = w * 0.30;
    // final w3 = w * 0.55;

    final paint = Paint()..style = PaintingStyle.fill;

    // Red
    paint.color = const Color(0xFFD67771);
    canvas.drawRect(Rect.fromLTWH(0, 0, w1, h), paint);

    // Yellow
    paint.color = const Color(0xFFD6C071);
    canvas.drawRect(Rect.fromLTWH(w1, 0, w2, h), paint);

    // Green
    paint.color = const Color(0xFF71D6AA);
    canvas.drawRect(Rect.fromLTWH(w1 + w2, 0, w - (w1 + w2), h), paint);

    // Marker (dashed line)
    final markerX = w * value;
    final markerPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..strokeWidth = 1.5;

    double curY = 0;
    while (curY < h) {
      canvas.drawLine(
        Offset(markerX, curY),
        Offset(markerX, curY + 4),
        markerPaint,
      );
      curY += 7;
    }
  }

  @override
  bool shouldRepaint(_SegmentedBarPainter old) => old.value != value;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 stat tiles
// ─────────────────────────────────────────────────────────────────────────────
class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  final int? highest;
  final int? lowest;
  final int? average;

  const _StatTiles({
    required this.s,
    required this.cw,
    this.highest,
    this.lowest,
    this.average,
  });

  @override
  Widget build(BuildContext context) {
    final gap = 12.0 * s;
    final tileW = (cw - gap * 2) / 3;
    final tiles = [
      (
        label: 'Highest',
        value: highest != null ? '$highest%' : '--',
        icon: Icons.trending_up,
        color: const Color(0xFF71D6AA),
      ),
      (
        label: 'Lowest',
        value: lowest != null ? '$lowest%' : '--',
        icon: Icons.trending_down,
        color: const Color(0xFFD67771),
      ),
      (
        label: 'Average',
        value: average != null ? '$average%' : '--',
        icon: Icons.query_stats,
        color: const Color(0xFF9E9E9E),
      ),
    ];

    return Row(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Expanded(
          child: Container(
            width: tileW,
            margin: EdgeInsets.only(right: i < 2 ? gap : 0),
            child: _BorderCard(
              s: s,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 16 * s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.icon, color: t.color, size: 18 * s),
                        SizedBox(width: 4 * s),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      t.value,
                      style: GoogleFonts.inter(
                        fontSize: 26 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      t.label,
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: AppColors.labelDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period toggle: Daily / Weekly / Monthly
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodPillToggle extends StatelessWidget {
  final double s;
  final int selected;
  final ValueChanged<int> onTap;
  const _PeriodPillToggle({
    required this.s,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(28 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 2 * s),
              padding: EdgeInsets.symmetric(
                horizontal: 24 * s,
                vertical: 8 * s,
              ),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF145E73) : Colors.transparent,
                borderRadius: BorderRadius.circular(24 * s),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : AppColors.labelDim,
                ),
              ),
            ),
          );
        }),
      ),
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
  final List<int> samples;

  const _GraphCard({
    required this.s,
    required this.cw,
    required this.period,
    required this.samples,
  });

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
          if (period != 0)
            VitalsHistoryChart(
              vitalType: VitalType.spo2,
              weekly: period == 1,
            )
          else if (samples.isEmpty)
            SizedBox(
              height: 140 * s,
              child: Center(
                child: Text(
                  'No SpO2 readings yet',
                  style: GoogleFonts.inter(fontSize: 12 * s, color: AppColors.labelDim),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 140 * s,
              child: CustomPaint(painter: _Spo2BarPainter(s: s, samples: samples)),
            ),
        ],
      ),
    );
  }
}

class _Spo2BarPainter extends CustomPainter {
  final double s;
  final List<int> samples;

  const _Spo2BarPainter({required this.s, required this.samples});

  static Color _barColor(int v) {
    if (v >= 97) return const Color(0xFF71D6AA); // green – normal
    if (v >= 94) return const Color(0xFF35B1DC); // cyan – borderline
    if (v >= 90) return const Color(0xFFE8C56B); // yellow – low
    return const Color(0xFFD67771);              // red – very low
  }

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 42.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    // SpO2 meaningful range: floor at 85%, ceiling at 100%
    const floor = 85;
    const ceiling = 100;
    const range = ceiling - floor; // 15 points

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y axis: 100 / 97 / 94 / 90
    const yLabels = ['100%', '97%', '94%', '90%'];
    const yValues = [100, 97, 94, 90];
    final yPositions = yValues.map((v) => 1.0 - (v - floor) / range).toList();

    for (int i = 0; i < yLabels.length; i++) {
      tp.text = TextSpan(
        text: yLabels[i],
        style: TextStyle(fontSize: 8.5 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, chartH * yPositions[i] - tp.height / 2));
    }

    // Dashed grid lines
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 0.5;
    for (final yPos in yPositions) {
      final y = chartH * yPos;
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 4 * s, y), dashPaint);
        dx += 8 * s;
      }
    }

    // Bars
    final n = samples.length;
    final slotGap = 4.0 * s;
    final barW = ((chartW - (n - 1) * slotGap) / n).clamp(4.0, 32.0);

    for (int i = 0; i < n; i++) {
      final clamped = samples[i].clamp(floor, ceiling);
      final norm = (clamped - floor) / range;
      final bH = (chartH * norm).clamp(2.0, chartH);
      final x = yLabelW + i * (barW + slotGap);
      final top = chartH - bH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barW, bH),
          Radius.circular(barW / 2),
        ),
        Paint()..color = _barColor(samples[i]),
      );
    }

    // Bottom dashed X line
    final bottomPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 1;
    double bx = yLabelW;
    while (bx < size.width) {
      canvas.drawLine(
        Offset(bx, chartH + 5 * s),
        Offset(bx + 2 * s, chartH + 5 * s),
        bottomPaint,
      );
      bx += 4 * s;
    }

    // X labels: first and last sample index
    final xLabelData = [('1', yLabelW), ('$n', yLabelW + (n - 1) * (barW + slotGap))];
    for (final (label, xPos) in xLabelData) {
      tp.text = TextSpan(
        text: label,
        style: TextStyle(fontSize: 9 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 10 * s));
    }
  }

  @override
  bool shouldRepaint(_Spo2BarPainter old) => old.s != s || old.samples != samples;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final int? spo2Value;

  const _AiInsightCard({required this.s, this.spo2Value});

  String get _message {
    final v = spo2Value;
    if (v == null) {
      return 'Start SpO2 monitoring to receive personalised blood oxygen insights.';
    }
    if (v >= 98) {
      return 'Excellent SpO2 ($v%). Your blood oxygen is optimal — your body is delivering oxygen efficiently throughout all tissues.';
    }
    if (v >= 95) {
      return 'Normal SpO2 ($v%). Blood oxygen levels are healthy. No action needed — keep up your current activity and breathing habits.';
    }
    if (v >= 93) {
      return 'Borderline SpO2 ($v%). Slightly lower than ideal. Try slow, deep diaphragmatic breathing, sit upright, and avoid strenuous exercise until it recovers.';
    }
    if (v >= 90) {
      return 'Low SpO2 ($v%). Rest in a well-ventilated area and retry the measurement. If it stays below 93% consistently, consult a healthcare provider.';
    }
    return 'Very low SpO2 ($v%). This may indicate hypoxia. Please seek medical attention if this reading persists.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.cyan, size: 22 * s),
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
                  _message,
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

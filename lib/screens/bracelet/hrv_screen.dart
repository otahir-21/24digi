import 'dart:async';
import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../widgets/health_info_sheet.dart';
import '../../widgets/vitals_history_chart.dart';
import 'bracelet_scaffold.dart';
import '../../bracelet/bracelet_dashboard_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HrvScreen – shows HRV from bracelet (dataType 38).
// ─────────────────────────────────────────────────────────────────────────────
class HrvScreen extends StatefulWidget {
  const HrvScreen({super.key, this.channel, this.liveData});

  final BraceletChannel? channel;
  final Map<String, dynamic>? liveData;

  @override
  State<HrvScreen> createState() => _HrvScreenState();
}

class _HrvScreenState extends State<HrvScreen> {
  int _periodIndex = 0;
  BraceletChannel? _channel;
  StreamSubscription<BraceletEvent>? _subscription;

  int? _hrvCurrent;
  int? _hrvHighest;
  int? _hrvLowest;
  final List<int> _hrvSamples = [];

  bool _isLoading = true;
  Timer? _loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel ?? BraceletChannel();
    _applyLiveData(widget.liveData);
    _listen();
    _channel?.requestHRVData();
    // Auto-clear loading after 8s if no data arrives
    _loadingTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });
  }

  void _applyLiveData(Map<String, dynamic>? data) {
    if (data == null) return;
    final hrv = data['hrv'] ?? data['HRV'];
    if (hrv != null) {
      final v = hrv is int ? hrv : (hrv is num ? hrv.toInt() : int.tryParse(hrv.toString()));
      if (v != null) {
        _hrvCurrent = v;
        BraceletChannel.lastKnownHrv = v;
        if (_hrvSamples.isEmpty) _hrvSamples.add(v);
      }
    }
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _channel?.events.listen((BraceletEvent e) {
      if (!mounted) return;
      if (e.event == 'connectionState') {
        if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
          setState(() {
            _hrvCurrent = null;
            _hrvHighest = null;
            _hrvLowest = null;
            _hrvSamples.clear();
          });
        }
        return;
      }
      if (e.event != 'realtimeData') return;
      final dataType = e.data['dataType'];
      final dic = e.data['dicData'];
      if (dic == null || dic is! Map) return;
      final type = dataType is int
          ? dataType
          : (dataType is num ? dataType.toInt() : null);
      if (type != 38 && type != 56) return; // 38 = HRVData_J2208A, 56 = DeviceMeasurement_HRV_J2208A
      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      int? ms = _extractHrvFromMap(dicMap);
      if (ms == null) {
        // iOS SDK uses arrayHrvData; Android uses Data/data
        final dataList =
            dicMap['arrayHrvData'] ?? dicMap['Data'] ?? dicMap['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final records = [dataList.first, dataList.last];
          for (final record in records) {
            if (record is! Map) continue;
            final rec = Map<String, dynamic>.from(
              (record as Map<Object?, Object?>).map(
                (k, v) => MapEntry(k?.toString() ?? '', v),
              ),
            );
            ms = _extractHrvFromMap(rec);
            if (ms != null) break;
          }
        }
      }
      assert(() {
        if (ms == null && (type == 38 || type == 56)) {
          debugPrint(
            'HRV dataType=$type keys: ${dicMap.keys.toList()} values: $dicMap',
          );
        }
        return true;
      }());
      if (ms == null) return;
      final int value = ms;
      BraceletChannel.lastKnownHrv = value;
      _loadingTimeoutTimer?.cancel();
      setState(() {
        _isLoading = false;
        _hrvCurrent = value;
        _hrvSamples.add(value);
        if (_hrvSamples.length > 100) _hrvSamples.removeAt(0);
        if (_hrvHighest == null || value > _hrvHighest!) _hrvHighest = value;
        if (_hrvLowest == null || value < _hrvLowest!) _hrvLowest = value;
      });
    });
  }

  static int? _extractHrvFromMap(Map<String, dynamic> m) {
    final v =
        m['HRV'] ??
        m['hrv'] ??
        m['Value'] ??
        m['value'] ??
        m['SDNN'] ??
        m['sdnn'] ??
        m['RMSSD'] ??
        m['rmssd'] ??
        m['Hrv'] ??
        m['hrvValue'] ??
        m['hrvTestValue'] ??
        m['hrvResultValue'] ??
        m['hrvResultAvg'];
    return _parseInt(v);
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  int? get _hrvAverage => _hrvSamples.isEmpty
      ? null
      : (_hrvSamples.reduce((a, b) => a + b) / _hrvSamples.length).round();

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final hPad = 16.0 * s;
    final cw = AppConstants.getScaleWidth(context) - hPad * 2;

    return BraceletScaffold(
      title: 'HRV',
      actions: [
        HealthInfoButton(
          onTap: () {
            final v = _hrvCurrent;
            showHealthInfoSheet(
              context,
              HealthMetrics.hrv,
              currentValue: v != null ? v.toString() : null,
              currentRangeIndex: v == null
                  ? -1
                  : v > 50 ? 0 : v >= 30 ? 1 : v >= 20 ? 2 : 3,
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

          // ── HRV Hero ───────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _HrvHero(
              s: s,
              cw: cw,
              valueMs: _hrvAverage ?? _hrvCurrent,
              isLoading: _isLoading,
            ),
          ),
          SizedBox(height: 28 * s),

          // ── Stat Tiles ───────────────────────────────────────────
          _StatTiles(
            s: s,
            cw: cw,
            highest: _hrvHighest,
            lowest: _hrvLowest,
            average: _hrvAverage,
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
              samples: List<int>.from(_hrvSamples),
            ),
          ),
          SizedBox(height: 28 * s),

          Divider(color: Colors.white.withAlpha(20), thickness: 1, height: 1),
          SizedBox(height: 28 * s),

          // ── AI Insight Card ──────────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(s: s, hrvValue: _hrvAverage ?? _hrvCurrent),
          ),
          SizedBox(height: 48 * s),
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
      painter: SmoothGradientBorder(radius: 32 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HRV hero: heart shape with ECG + value ms (from device when available)
// ─────────────────────────────────────────────────────────────────────────────
class _HrvHero extends StatelessWidget {
  final double s;
  final double cw;
  final int? valueMs;
  final bool isLoading;

  const _HrvHero({
    required this.s,
    required this.cw,
    this.valueMs,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStr = valueMs != null ? '$valueMs' : '—';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36 * s),
      child: Column(
        children: [
          SizedBox(
            width: 160 * s,
            height: 140 * s,
            child: CustomPaint(painter: const _HrvHeartPainter()),
          ),
          SizedBox(height: 14 * s),
          if (isLoading) ...[
            SizedBox(
              width: 28 * s,
              height: 28 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              'Measuring...',
              style: BraceletDashboardTypography.text(
                fontSize: 12 * s,
                color: AppColors.labelDim,
              ),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valueStr,
                  style: BraceletDashboardTypography.text(
                    fontSize: 60 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                SizedBox(width: 8 * s),
                Text(
                  'ms',
                  style: BraceletDashboardTypography.text(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelDim,
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
    heartPath.cubicTo(
      w * 0.15,
      h * 0.05,
      w * 0.45,
      h * 0.05,
      w * 0.5,
      h * 0.25,
    );
    // Right curve (stops where ECG exits)
    heartPath.cubicTo(
      w * 0.55,
      h * 0.05,
      w * 0.85,
      h * 0.05,
      w * 0.9,
      h * 0.25,
    );
    heartPath.cubicTo(
      w * 0.95,
      h * 0.45,
      w * 0.85,
      h * 0.65,
      w * 0.82,
      h * 0.73,
    );

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
// 3 stat tiles: Highest / Lowest / Average (from device when available)
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
        value: highest != null ? '$highest' : '—',
        icon: Icons.trending_up,
        color: const Color(0xFF71D6AA),
      ),
      (
        label: 'Lowest',
        value: lowest != null ? '$lowest' : '—',
        icon: Icons.trending_down,
        color: const Color(0xFFD67771),
      ),
      (
        label: 'Average',
        value: average != null ? '$average' : '—',
        icon: Icons.query_stats,
        color: const Color(0xFF9E9E9E),
      ),
    ];

    return Row(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Container(
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
                    children: [Icon(t.icon, color: t.color, size: 18 * s)],
                  ),
                  SizedBox(height: 8 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        t.value,
                        style: BraceletDashboardTypography.text(
                          fontSize: 26 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 2 * s),
                      Text(
                        'ms',
                        style: BraceletDashboardTypography.text(
                          fontSize: 10 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    t.label,
                    style: BraceletDashboardTypography.text(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w500,
                      color: AppColors.labelDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period toggle
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
                style: BraceletDashboardTypography.text(
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
            style: BraceletDashboardTypography.text(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10 * s),
          if (period != 0)
            VitalsHistoryChart(
              vitalType: VitalType.hrv,
              weekly: period == 1,
            )
          else if (samples.isEmpty)
            SizedBox(
              height: 150 * s,
              child: Center(
                child: Text(
                  'No HRV readings yet',
                  style: BraceletDashboardTypography.text(
                    fontSize: 12 * s,
                    color: AppColors.labelDim,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 150 * s,
              child: CustomPaint(painter: _HrvBarPainter(s: s, samples: samples)),
            ),
        ],
      ),
    );
  }
}

class _HrvBarPainter extends CustomPainter {
  final double s;
  final List<int> samples;

  const _HrvBarPainter({required this.s, required this.samples});

  static Color _barColor(int v) {
    if (v < 40) return const Color(0xFFD67771); // red – low
    if (v < 60) return const Color(0xFFE8C56B); // yellow – moderate
    if (v < 80) return const Color(0xFF35B1DC); // cyan – good
    return const Color(0xFF71D6AA); // green – excellent
  }

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 38.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    // Dynamic ceiling: round up to nearest 20 above max sample
    final maxVal = samples.fold<int>(0, (m, v) => max(m, v));
    final ceiling = (((maxVal + 19) ~/ 20) * 20).clamp(60, 200);

    final ySteps = 4;
    final stepVal = ceiling ~/ ySteps;
    final yPositions = List.generate(ySteps, (i) => i / ySteps.toDouble());
    final yLabels = List.generate(
      ySteps,
      (i) => '${ceiling - i * stepVal}',
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y Axis Labels
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
      final norm = (samples[i] / ceiling).clamp(0.0, 1.0);
      final bH = chartH * norm;
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

    // X label: first and last sample index
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
  bool shouldRepaint(_HrvBarPainter old) =>
      old.s != s || old.samples != samples;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final int? hrvValue;

  const _AiInsightCard({required this.s, this.hrvValue});

  String get _message {
    final v = hrvValue;
    if (v == null) {
      return 'Connect your bracelet and measure HRV to get personalised recovery insights.';
    }
    if (v < 20) {
      return 'Very low HRV ($v ms). Your nervous system is under significant stress. Avoid intense exercise — focus on rest, hydration, and quality sleep tonight.';
    }
    if (v < 40) {
      return 'Low HRV ($v ms). Your body shows signs of fatigue or stress. Light movement and recovery-focused activity are recommended today.';
    }
    if (v < 60) {
      return 'Moderate HRV ($v ms). You\'re in an acceptable recovery range. Balanced activity and good hydration will help maintain this level.';
    }
    if (v < 80) {
      return 'Good HRV ($v ms)! Your recovery is solid. You can handle moderate to high intensity training today with confidence.';
    }
    if (v < 100) {
      return 'Very good HRV ($v ms). Your nervous system is well balanced — a great day for challenging workouts or high-focus mental work.';
    }
    return 'Excellent HRV ($v ms)! Your body is in peak recovery. Push hard today — your system is primed for top performance.';
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
                  style: BraceletDashboardTypography.text(
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../painters/stress_icon_painter.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../painters/stress_icon_painter.dart';
import '../../widgets/health_info_sheet.dart';
import '../../widgets/vitals_history_chart.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StressScreen – integrates real data from bracelet.
// ─────────────────────────────────────────────────────────────────────────────
class StressScreen extends StatefulWidget {
  const StressScreen({super.key, this.channel});
  final BraceletChannel? channel;

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressData {
  const _StressData({
    this.current = -1,
    this.max = -1,
    this.min = -1,
    this.medium = -1,
    this.barValues = const [],
  });
  final int current;
  final int max;
  final int min;
  final int medium;
  final List<double> barValues;

  bool get hasData => current >= 0;

  double get gradientValue =>
      current < 0 || current > 100 ? -1.0 : current / 100.0;

  String get levelLabel {
    if (current < 0) return '--';
    if (current < 33) return 'Low';
    if (current < 66) return 'Medium';
    return 'High';
  }

  /// Returns the colour matching the stress level for current value.
  Color get levelColor {
    if (current < 0) return AppColors.labelDim;
    if (current < 33) return const Color(0xFF4CAF50);
    if (current < 66) return const Color(0xFF43C6E4);
    return const Color(0xFFE53935);
  }

  /// Trend based on last two readings in barValues.
  IconData get trendIcon {
    if (barValues.length < 2) return Icons.trending_flat_rounded;
    final prev = barValues[barValues.length - 2];
    final last = barValues[barValues.length - 1];
    if (last > prev + 2) return Icons.trending_up_rounded;
    if (last < prev - 2) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  Color get trendColor {
    if (barValues.length < 2) return AppColors.labelDim;
    final prev = barValues[barValues.length - 2];
    final last = barValues[barValues.length - 1];
    if (last > prev + 2) return const Color(0xFFE53935);
    if (last < prev - 2) return AppColors.cyan;
    return AppColors.labelDim;
  }
}

class _StressScreenState extends State<StressScreen> {
  int _periodIndex = 0;
  StreamSubscription<BraceletEvent>? _subscription;
  _StressData _stressData = const _StressData();

  static const int _maxBarHistory = 8;
  final List<double> _stressHistory = [];

  /// True while waiting for the first reading after requestHRVData().
  bool _isLoading = false;
  Timer? _loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();
    if (widget.channel != null) {
      _isLoading = true;
      _listenBracelet();
      widget.channel!.requestHRVData();
      // Auto-cancel loader after 8s if device never responds.
      _loadingTimeoutTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

  void _listenBracelet() {
    _subscription?.cancel();
    _subscription = widget.channel!.events.listen((BraceletEvent e) {
      if (!mounted) return;

      if (e.event == 'connectionState') {
        if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
          _loadingTimeoutTimer?.cancel();
          setState(() {
            _isLoading = false;
            _stressData = const _StressData();
            _stressHistory.clear();
          });
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
      if (type == null) return;

      int? stressFromDevice;
      if (type == 38 || type == 56) {
        final sVal = dicMap['Stress'] ?? dicMap['stress'];
        if (sVal != null) stressFromDevice = _parseInt(sVal);
      }

      int? derivedStress;
      if (type == 24) {
        final hr = dicMap['heartRate'] ?? dicMap['HeartRate'];
        if (hr != null) {
          final hrVal = _parseInt(hr);
          if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
            derivedStress = _stressFromHeartRate(hrVal);
          }
        }
      }

      final int? current = stressFromDevice ?? derivedStress;
      if (current == null) return;

      _loadingTimeoutTimer?.cancel();
      setState(() {
        _isLoading = false;
        _stressHistory.add(current.toDouble());
        if (_stressHistory.length > _maxBarHistory) _stressHistory.removeAt(0);

        final vals = List<double>.from(_stressHistory);
        int maxVal = current, minVal = current;
        double sum = 0;
        for (final v in vals) {
          final i = v.round();
          if (i > maxVal) maxVal = i;
          if (i < minVal) minVal = i;
          sum += v;
        }
        final mediumVal =
            vals.isEmpty ? current : (sum / vals.length).round();

        _stressData = _StressData(
          current: current,
          max: maxVal,
          min: minVal,
          medium: mediumVal,
          barValues: List<double>.from(vals),
        );
      });
    });
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static int _stressFromHeartRate(int heartRate) {
    const restLow = 55;
    const restHigh = 75;
    const high = 120;
    if (heartRate <= restLow) {
      return (20 * heartRate / restLow).round().clamp(0, 100);
    }
    if (heartRate <= restHigh) {
      return (20 + 30 * (heartRate - restLow) / (restHigh - restLow))
          .round()
          .clamp(0, 100);
    }
    if (heartRate <= high) {
      return (50 + 50 * (heartRate - restHigh) / (high - restHigh))
          .round()
          .clamp(0, 100);
    }
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cw = AppConstants.getScaleWidth(context);
    final d = _stressData;

    return BraceletScaffold(
      actions: [
        HealthInfoButton(
          onTap: () => showHealthInfoSheet(
            context,
            HealthMetrics.stress,
            currentValue: d.hasData ? d.current.toString() : null,
            currentRangeIndex: d.hasData
                ? (d.current < 33 ? 0 : d.current < 66 ? 1 : 2)
                : -1,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HI, USER ──────────────────────────────────────────────
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

          // ── Stress hero card ───────────────────────────────────────
          _BorderCard(
            s: s,
            child: _StressHero(
              s: s,
              value: d.hasData ? d.current : null,
              levelLabel: d.levelLabel,
              levelColor: d.levelColor,
              trendIcon: d.trendIcon,
              trendColor: d.trendColor,
              isLoading: _isLoading,
            ),
          ),
          SizedBox(height: 28 * s),

          // ── Gradient bar (hidden when no data) ────────────────────
          _GradientBar(s: s, value: d.gradientValue),
          SizedBox(height: 28 * s),

          // ── Stat tiles ─────────────────────────────────────────────
          _StatTiles(
            s: s,
            cw: cw,
            maxVal: d.max >= 0 ? d.max.toString() : '--',
            mediumVal: d.medium >= 0 ? d.medium.toString() : '--',
            minVal: d.min >= 0 ? d.min.toString() : '--',
          ),
          SizedBox(height: 24 * s),

          // ── Period Toggle ──────────────────────────────────────────
          Center(
            child: _PeriodPillToggle(
              s: s,
              selected: _periodIndex,
              onTap: (i) => setState(() => _periodIndex = i),
            ),
          ),
          SizedBox(height: 24 * s),

          // ── Graph Card ─────────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _GraphCard(
              s: s,
              period: _periodIndex,
              barValues: d.barValues,
            ),
          ),
          SizedBox(height: 28 * s),

          Divider(color: Colors.white.withAlpha(20), thickness: 1, height: 1),
          SizedBox(height: 28 * s),

          // ── AI Insight Card ────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(s: s, stressData: d),
          ),
          SizedBox(height: 48 * s),
        ],
      ),
    );
  }
}

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
// Stress hero – shows '--' when no data, real value when connected
// ─────────────────────────────────────────────────────────────────────────────
class _StressHero extends StatelessWidget {
  final double s;
  final int? value;
  final String levelLabel;
  final Color levelColor;
  final IconData trendIcon;
  final Color trendColor;
  final bool isLoading;

  const _StressHero({
    required this.s,
    required this.value,
    required this.levelLabel,
    required this.levelColor,
    required this.trendIcon,
    required this.trendColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const figH = 140.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24 * s),
      child: Column(
        children: [
          StressIcon(size: figH * s),
          SizedBox(height: 12 * s),

          // ── Value or loader ───────────────────────────────────
          if (isLoading)
            SizedBox(
              height: 68 * s,
              child: Center(
                child: SizedBox(
                  width: 36 * s,
                  height: 36 * s,
                  child: CircularProgressIndicator(
                    strokeWidth: 3 * s,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                  ),
                ),
              ),
            )
          else
            Text(
              value != null ? value.toString() : '--',
              style: GoogleFonts.inter(
                fontSize: 68 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),

          SizedBox(height: 12 * s),

          // ── Level label + trend ───────────────────────────────
          if (isLoading)
            Text(
              'Measuring...',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: AppColors.labelDim,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  levelLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    color: levelColor,
                  ),
                ),
                SizedBox(width: 4 * s),
                Icon(trendIcon, color: trendColor, size: 14 * s),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient bar – hidden when value < 0 (no data)
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBar extends StatelessWidget {
  final double s;
  final double value; // -1 means no data
  const _GradientBar({required this.s, required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 30 * s),
          painter: _GradientBarPainter(s: s, value: value),
        );
      },
    );
  }
}

class _GradientBarPainter extends CustomPainter {
  final double s;
  final double value; // -1 = no data
  const _GradientBarPainter({required this.s, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final h = 10 * s;
    final r = h / 2;
    final barY = 16 * s;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barY, size.width, h),
      Radius.circular(r),
    );
    final gradient = const LinearGradient(
      colors: [Color(0xFF4CAF50), Color(0xFFFFEB3B), Color(0xFFE53935)],
    ).createShader(Rect.fromLTWH(0, barY, size.width, h));

    canvas.drawRRect(barRect, Paint()..shader = gradient);

    // Only draw marker when we have real data
    if (value < 0) return;

    // Sample the gradient colour at the marker's position so it matches the bar.
    // Gradient stops: green (0.0) → yellow (0.5) → red (1.0).
    const green  = Color(0xFF4CAF50);
    const yellow = Color(0xFFFFEB3B);
    const red    = Color(0xFFE53935);
    final t = value.clamp(0.0, 1.0);
    final markerColor = t <= 0.5
        ? Color.lerp(green, yellow, t / 0.5)!
        : Color.lerp(yellow, red, (t - 0.5) / 0.5)!;

    final markerX = size.width * t;
    final markerPath = Path();
    markerPath.moveTo(markerX - 6 * s, 0);
    markerPath.lineTo(markerX + 6 * s, 0);
    markerPath.lineTo(markerX, 10 * s);
    markerPath.close();

    canvas.drawPath(
      markerPath,
      Paint()..color = markerColor,
    );
    canvas.drawLine(
      Offset(markerX, 10 * s),
      Offset(markerX, barY + 4 * s),
      Paint()
        ..color = markerColor.withAlpha(180)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_GradientBarPainter old) => old.value != value;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat tiles – accepts String so '--' can be shown when no data
// ─────────────────────────────────────────────────────────────────────────────
class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  final String maxVal;
  final String mediumVal;
  final String minVal;

  const _StatTiles({
    required this.s,
    required this.cw,
    required this.maxVal,
    required this.mediumVal,
    required this.minVal,
  });

  @override
  Widget build(BuildContext context) {
    final gap = 12.0 * s;
    final tiles = [
      (
        label: 'Max',
        value: maxVal,
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFE53935),
      ),
      (
        label: 'Medium',
        value: mediumVal,
        icon: Icons.trending_flat_rounded,
        color: const Color(0xFF43C6E4),
      ),
      (
        label: 'Min',
        value: minVal,
        icon: Icons.trending_down_rounded,
        color: const Color(0xFF9F56F5),
      ),
    ];
    return Row(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? gap : 0),
            child: _BorderCard(
              s: s,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 16 * s,
                ),
                child: Column(
                  children: [
                    Icon(t.icon, color: t.color, size: 20 * s),
                    SizedBox(height: 8 * s),
                    Text(
                      t.value,
                      style: GoogleFonts.inter(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      t.label,
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
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
// Period pill toggle
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
                color:
                    active ? const Color(0xFF145E73) : Colors.transparent,
                borderRadius: BorderRadius.circular(24 * s),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
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
// Graph card – Daily shows real bars; Weekly/Monthly shows placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final int period;
  final List<double> barValues;
  const _GraphCard({
    required this.s,
    required this.period,
    required this.barValues,
  });

  @override
  Widget build(BuildContext context) {
    const titles = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    final isDaily = period == 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 18 * s, 14 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[period],
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 12 * s),

          if (isDaily) ...[
            Row(
              children: [
                _LegendDot(
                  s: s,
                  color: const Color(0xFF4CAF50),
                  label: 'Low  <33',
                ),
                SizedBox(width: 16 * s),
                _LegendDot(
                  s: s,
                  color: const Color(0xFF43C6E4),
                  label: 'Med  33–66',
                ),
                SizedBox(width: 16 * s),
                _LegendDot(
                  s: s,
                  color: const Color(0xFFE53935),
                  label: 'High  >66',
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            SizedBox(
              width: double.infinity,
              height: 220 * s,
              child: barValues.isEmpty
                  ? Center(
                      child: Text(
                        'Wear your bracelet to record stress history.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _StressBarPainter(s: s, barValues: barValues),
                    ),
            ),
          ] else
            VitalsHistoryChart(
              vitalType: VitalType.stress,
              weekly: period == 1,
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
  const _LegendDot({required this.s, required this.color, required this.label});

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
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8.5 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bar painter – zones, readable grid, colour-coded bars, reading index x-axis
// ─────────────────────────────────────────────────────────────────────────────
class _StressBarPainter extends CustomPainter {
  final double s;
  final List<double> barValues;
  const _StressBarPainter({required this.s, required this.barValues});

  static const _green = Color(0xFF4CAF50);
  static const _cyan  = Color(0xFF43C6E4);
  static const _red   = Color(0xFFE53935);

  Color _barColor(double val) {
    if (val < 33) return _green;
    if (val < 66) return _cyan;
    return _red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final yLW  = 32.0 * s;   // left Y-label column
    final zW   = 38.0 * s;   // right zone-label column
    final xLH  = 20.0 * s;   // bottom X-label row
    final chartW = size.width  - yLW - zW;
    final chartH = size.height - xLH;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // ── 1. Zone background bands ─────────────────────────────────────────
    final zones = [
      (lo: 0.0,  hi: 33.0, fill: _green.withAlpha(25), border: _green, label: 'LOW'),
      (lo: 33.0, hi: 66.0, fill: _cyan.withAlpha(18),  border: _cyan,  label: 'MED'),
      (lo: 66.0, hi:100.0, fill: _red.withAlpha(28),   border: _red,   label: 'HIGH'),
    ];
    for (final z in zones) {
      final yTop    = chartH * (1.0 - z.hi  / 100.0);
      final yBottom = chartH * (1.0 - z.lo  / 100.0);

      // Band fill
      canvas.drawRect(
        Rect.fromLTWH(yLW, yTop, chartW, yBottom - yTop),
        Paint()..color = z.fill,
      );

      // Zone boundary line (top edge of each zone except bottom-most)
      if (z.lo > 0) {
        canvas.drawLine(
          Offset(yLW, yBottom),
          Offset(yLW + chartW, yBottom),
          Paint()
            ..color = z.border.withAlpha(100)
            ..strokeWidth = 0.8 * s,
        );
      }

      // Zone label on right column
      tp.text = TextSpan(
        text: z.label,
        style: TextStyle(
          fontSize: 8.5 * s,
          color: z.border,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      );
      tp.layout();
      final midY = (yTop + yBottom) / 2 - tp.height / 2;
      tp.paint(canvas, Offset(yLW + chartW + 5 * s, midY));
    }

    // ── 2. Horizontal grid lines + Y-axis labels ─────────────────────────
    const gridValues = [0, 25, 50, 75, 100];
    for (final v in gridValues) {
      final y = chartH * (1.0 - v / 100.0);

      // Y label
      tp.text = TextSpan(
        text: v.toString(),
        style: TextStyle(
          fontSize: 8.5 * s,
          color: Colors.white.withAlpha(130),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Solid grid line — clearly visible against dark background
      canvas.drawLine(
        Offset(yLW, y),
        Offset(yLW + chartW, y),
        Paint()
          ..color = Colors.white.withAlpha(v == 0 ? 60 : 35)
          ..strokeWidth = 0.6 * s,
      );
    }

    // ── 3. Bars ──────────────────────────────────────────────────────────
    final n = barValues.length;
    if (n == 0) return;

    final slotW = chartW / n;
    final barW  = (slotW * 0.52).clamp(8.0 * s, 22.0 * s);

    for (int i = 0; i < n; i++) {
      final val = barValues[i].clamp(0.0, 100.0);
      final h   = chartH * (val / 100.0);
      final x   = yLW + i * slotW + (slotW - barW) / 2;
      final top = chartH - h;
      final col = _barColor(val);

      // Gradient: lighter top → solid bottom for depth
      final barRect = Rect.fromLTWH(x, top, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(barW / 2)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [col.withAlpha(170), col],
          ).createShader(barRect),
      );

      // Value label above bar
      tp.text = TextSpan(
        text: val.round().toString(),
        style: TextStyle(
          fontSize: 8 * s,
          color: col,
          fontWeight: FontWeight.w700,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, top - tp.height - 2 * s));

      // X-axis reading index label
      tp.text = TextSpan(
        text: '#${i + 1}',
        style: TextStyle(
          fontSize: 8 * s,
          color: Colors.white.withAlpha(100),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, chartH + 4 * s));
    }

    // ── 4. X-axis base line ──────────────────────────────────────────────
    canvas.drawLine(
      Offset(yLW, chartH),
      Offset(yLW + chartW, chartH),
      Paint()
        ..color = Colors.white.withAlpha(55)
        ..strokeWidth = 0.8 * s,
    );
  }

  @override
  bool shouldRepaint(_StressBarPainter old) => old.barValues != barValues;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight – dynamic text based on actual stress level
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final _StressData stressData;
  const _AiInsightCard({required this.s, required this.stressData});

  static String _insight(_StressData d) {
    if (!d.hasData) {
      return 'Connect your bracelet to receive personalised stress insights.';
    }
    final v = d.current;
    if (v < 20) {
      return 'Your stress level is very low at $v. You are in a calm, relaxed state. Great time for focused work or creative thinking.';
    }
    if (v < 33) {
      return 'Your stress level is low at $v. Your body is well-recovered. Maintain this by staying hydrated and keeping a steady routine.';
    }
    if (v < 50) {
      return 'Your stress is at a mild level ($v). This is normal during light activity or mild mental effort. Monitor for any upward trend.';
    }
    if (v < 66) {
      return 'Your stress is at a moderate level ($v). Consider taking a short break — a few minutes of slow breathing can help reset your nervous system.';
    }
    if (v < 80) {
      return 'Your stress is elevated at $v. This may indicate fatigue or mental overload. Step away from screens, take a short walk, or practice deep breathing.';
    }
    return 'Your stress level is high at $v. Your body is under significant strain. Rest immediately, avoid stimulants, and consider a short recovery session.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.cyan, size: 28 * s),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  _insight(stressData),
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white.withAlpha(200),
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

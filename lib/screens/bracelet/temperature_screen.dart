import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
import '../../widgets/health_info_sheet.dart';
import '../../widgets/vitals_history_chart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TemperatureScreen – shows live temperature from bracelet (RealTimeStep type 24).
// ─────────────────────────────────────────────────────────────────────────────
class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key, this.channel});
  final BraceletChannel? channel;

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  int _periodIndex = 0;
  double? _currentTemp;
  double? _minTemp;
  double? _maxTemp;
  StreamSubscription<BraceletEvent>? _subscription;

  /// Session history – capped at 20 readings for chart + avg computation.
  final List<double> _tempReadings = [];
  static const int _maxReadings = 20;

  double? get _avgTemp {
    if (_tempReadings.isEmpty) return null;
    return _tempReadings.reduce((a, b) => a + b) / _tempReadings.length;
  }

  static double? _parseTemp(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Valid skin/wrist temperature range (°C).
  static bool _isValidTemp(double t) => t >= 30.0 && t <= 45.0;

  @override
  void initState() {
    super.initState();
    if (widget.channel != null) {
      _subscription = widget.channel!.events.listen((BraceletEvent e) {
        if (!mounted) return;

        if (e.event == 'connectionState') {
          if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
            setState(() {
              _currentTemp = null;
              _minTemp = null;
              _maxTemp = null;
              _tempReadings.clear();
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
        if (type != 24) return;

        final t = _parseTemp(dicMap['temperature'] ?? dicMap['Temperature']);
        if (t == null || !_isValidTemp(t)) return;

        setState(() {
          _currentTemp = t;
          if (_minTemp == null || t < _minTemp!) _minTemp = t;
          if (_maxTemp == null || t > _maxTemp!) _maxTemp = t;
          _tempReadings.add(t);
          if (_tempReadings.length > _maxReadings) _tempReadings.removeAt(0);
        });
      });
    }
  }

  @override
  void dispose() {
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

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
                _TopBar(s: s, onInfo: () {
                  final v = _currentTemp;
                  showHealthInfoSheet(
                    context,
                    HealthMetrics.temperature,
                    currentValue: v != null ? v.toStringAsFixed(1) : null,
                    currentRangeIndex: v == null
                        ? -1
                        : v < 36.0 ? 0 : v <= 37.2 ? 1 : v <= 38.0 ? 2 : 3,
                  );
                }),
                SizedBox(height: 14 * s),

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

                // ── Thermometer Hero ─────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _TempHero(
                    s: s,
                    cw: cw,
                    temperature: _currentTemp,
                  ),
                ),
                SizedBox(height: 28 * s),

                // ── Stat Tiles ───────────────────────────────────────────
                _StatTiles(
                  s: s,
                  cw: cw,
                  highest: _maxTemp,
                  lowest: _minTemp,
                  average: _avgTemp,
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
                    readings: List.unmodifiable(_tempReadings),
                  ),
                ),
                SizedBox(height: 28 * s),

                Divider(
                  color: Colors.white.withAlpha(20),
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 28 * s),

                // ── AI Insight Card ──────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _AiInsightCard(s: s, temperature: _currentTemp),
                ),
                SizedBox(height: 48 * s),
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
  final VoidCallback? onInfo;
  const _TopBar({required this.s, this.onInfo});

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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.cyan,
                      size: 20 * s,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/24 logo.png',
                    height: 40 * s,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  HealthInfoButton(onTap: onInfo ?? () {}),
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
// Temperature hero: thermometer with dynamic fill + live value + label
// ─────────────────────────────────────────────────────────────────────────────
class _TempHero extends StatelessWidget {
  final double s;
  final double cw;
  final double? temperature;
  const _TempHero({required this.s, required this.cw, this.temperature});

  static const double _minDisplay = 34.0;
  static const double _maxDisplay = 40.0;

  static double _fillRatio(double t) =>
      ((t - _minDisplay) / (_maxDisplay - _minDisplay)).clamp(0.0, 1.0);

  static String _label(double t) {
    if (t < 35.0) return 'Very Low';
    if (t < 36.0) return 'Low';
    if (t <= 37.2) return 'Normal';
    if (t <= 38.0) return 'Elevated';
    return 'High';
  }

  static IconData _labelIcon(double t) {
    if (t < 36.0) return Icons.trending_down;
    if (t <= 37.2) return Icons.remove;
    return Icons.trending_up;
  }

  static Color _labelColor(double t) {
    if (t < 36.0) return const Color(0xFF43C6E4);
    if (t <= 37.2) return const Color(0xFF71D6AA);
    if (t <= 38.0) return const Color(0xFFFFEB3B);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    final tempStr = temperature != null
        ? '${temperature!.toStringAsFixed(1)} C'
        : '-- C';
    final labelStr = temperature != null ? _label(temperature!) : '--';
    final icon = temperature != null ? _labelIcon(temperature!) : Icons.remove;
    final labelColor =
        temperature != null ? _labelColor(temperature!) : AppColors.labelDim;
    final fill = temperature != null ? _fillRatio(temperature!) : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36 * s),
      child: Column(
        children: [
          SizedBox(
            width: 100 * s,
            height: 150 * s,
            child: CustomPaint(
              painter: _ThermometerPainter(fillRatio: fill),
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                tempStr,
                style: GoogleFonts.inter(
                  fontSize: 60 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 24 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    labelStr,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(icon, color: labelColor, size: 14 * s),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thermometer painter – dynamic fill level based on fillRatio (0.0–1.0)
// ─────────────────────────────────────────────────────────────────────────────
class _ThermometerPainter extends CustomPainter {
  final double fillRatio;
  const _ThermometerPainter({this.fillRatio = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.4;
    final bulbR = w * 0.32;
    final tubeW = w * 0.4;
    const strokeW = 4.5;

    final tubeTopY = h * 0.15 + tubeW / 2;
    final tubeBottomY = h * 0.75 - 15;
    final tubeH = tubeBottomY - tubeTopY;
    final bulbCenter = Offset(cx, h * 0.75);

    // ── Fill (mercury) – drawn first so outline sits on top ──────────
    if (fillRatio > 0) {
      final fillTop = tubeBottomY - tubeH * fillRatio;
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF7043),
            const Color(0xFFE53935),
          ],
        ).createShader(Rect.fromLTWH(cx - tubeW / 2, fillTop, tubeW, tubeBottomY - fillTop + bulbR));

      // Tube fill
      canvas.drawRect(
        Rect.fromLTWH(cx - tubeW / 2 + strokeW / 2, fillTop, tubeW - strokeW, tubeBottomY - fillTop),
        fillPaint,
      );
      // Bulb fill (always full)
      canvas.drawCircle(bulbCenter, bulbR - strokeW / 2, fillPaint);
    }

    // ── Outline ──────────────────────────────────────────────────────
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    path.moveTo(cx - tubeW / 2, tubeBottomY);
    path.lineTo(cx - tubeW / 2, tubeTopY - tubeW / 2);
    path.arcTo(
      Rect.fromLTWH(cx - tubeW / 2, h * 0.15, tubeW, tubeW),
      pi,
      pi,
      false,
    );
    path.lineTo(cx + tubeW / 2, tubeBottomY);
    const angle = 0.55;
    path.arcTo(
      Rect.fromCircle(center: bulbCenter, radius: bulbR),
      -pi / 2 + angle,
      2 * pi - 2 * angle,
      false,
    );
    path.close();
    canvas.drawPath(path, outlinePaint);

    // Inner circle highlight
    canvas.drawCircle(bulbCenter, bulbR * 0.45, outlinePaint);

    // Heat dashes
    final dashX = cx + bulbR + 12;
    const dashW = 10.0;
    for (int i = 0; i < 3; i++) {
      final y = h * 0.22 + i * 16;
      canvas.drawLine(Offset(dashX, y), Offset(dashX + dashW, y), outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter old) => old.fillRatio != fillRatio;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat tiles: Highest / Lowest / Average (all from real session data)
// ─────────────────────────────────────────────────────────────────────────────
class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  final double? highest;
  final double? lowest;
  final double? average;
  const _StatTiles({
    required this.s,
    required this.cw,
    this.highest,
    this.lowest,
    this.average,
  });

  static String _fmt(double? v) =>
      v != null ? v.toStringAsFixed(1) : '--';

  @override
  Widget build(BuildContext context) {
    final gap = 12.0 * s;
    final tileW = (cw - gap * 2) / 3;
    final tiles = [
      (
        label: 'Highest',
        value: _fmt(highest),
        icon: Icons.trending_up,
        color: const Color(0xFF71D6AA),
      ),
      (
        label: 'Lowest',
        value: _fmt(lowest),
        icon: Icons.trending_down,
        color: const Color(0xFFD67771),
      ),
      (
        label: 'Average',
        value: _fmt(average),
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
// Graph card – Daily shows real readings; Weekly/Monthly shows placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  final List<double> readings;
  const _GraphCard({
    required this.s,
    required this.cw,
    required this.period,
    required this.readings,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    final isDaily = period == 0;

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

          if (isDaily)
            SizedBox(
              width: double.infinity,
              height: 150 * s,
              child: readings.isEmpty
                  ? Center(
                      child: Text(
                        'Wear your bracelet to record temperature history.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _TempBarPainter(s: s, readings: readings),
                    ),
            )
          else
            VitalsHistoryChart(
              vitalType: VitalType.temperature,
              weekly: period == 1,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bar painter – real temperature readings, colour-coded by range
// ─────────────────────────────────────────────────────────────────────────────
class _TempBarPainter extends CustomPainter {
  final double s;
  final List<double> readings;
  const _TempBarPainter({required this.s, required this.readings});

  static const _yLabels = ['40°C', '38°C', '36°C', '34°C'];

  // Display range
  static const double _minT = 34.0;
  static const double _maxT = 40.0;

  Color _barColor(double t) {
    if (t < 36.0) return const Color(0xFF43C6E4);      // Low – blue
    if (t <= 37.2) return const Color(0xFF71D6AA);     // Normal – green
    if (t <= 38.0) return const Color(0xFFFFEB3B);     // Elevated – yellow
    return const Color(0xFFE53935);                     // High – red
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final yLabelW = 38.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y positions for 40, 38, 36, 34
    final yPositions = [0.0, 0.333, 0.667, 1.0];

    // Y labels + dashed grid
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 0.5;
    for (int i = 0; i < _yLabels.length; i++) {
      tp.text = TextSpan(
        text: _yLabels[i],
        style: TextStyle(fontSize: 8.5 * s, color: AppColors.labelDim),
      );
      tp.layout();
      final y = chartH * yPositions[i];
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 4 * s, y), dashPaint);
        dx += 8 * s;
      }
    }

    // Bars
    final n = readings.length;
    final slotGap = 4.0 * s;
    final barW = ((chartW - (n - 1) * slotGap) / n).clamp(4.0 * s, 20.0 * s);

    for (int i = 0; i < n; i++) {
      final t = readings[i].clamp(_minT, _maxT);
      final norm = (t - _minT) / (_maxT - _minT);
      final bH = (chartH * norm).clamp(2.0, chartH);
      final x = yLabelW + i * (barW + slotGap);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartH - bH, barW, bH),
          Radius.circular(barW / 2),
        ),
        Paint()..color = _barColor(readings[i]),
      );
    }

    // Bottom dashed line
    double bx = yLabelW;
    while (bx < size.width) {
      canvas.drawLine(
        Offset(bx, chartH + 5 * s),
        Offset(bx + 2 * s, chartH + 5 * s),
        Paint()
          ..color = Colors.white.withAlpha(40)
          ..strokeWidth = 1,
      );
      bx += 4 * s;
    }
  }

  @override
  bool shouldRepaint(_TempBarPainter old) => old.readings != readings;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight – dynamic text based on actual temperature
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final double? temperature;
  const _AiInsightCard({required this.s, this.temperature});

  static String _insight(double? t) {
    if (t == null) {
      return 'Connect your bracelet to receive personalised temperature insights.';
    }
    if (t < 35.0) {
      return 'Your skin temperature is very low at ${t.toStringAsFixed(1)}°C. This may indicate cold exposure, poor circulation, or the sensor not being worn correctly. Ensure the bracelet fits snugly.';
    }
    if (t < 36.0) {
      return 'Your skin temperature is slightly low at ${t.toStringAsFixed(1)}°C. This is common in cool environments. If you feel cold or unwell, warm up and monitor your readings.';
    }
    if (t <= 37.2) {
      return 'Your skin temperature is in the normal range at ${t.toStringAsFixed(1)}°C. Your body is well-regulated. Keep hydrated and maintain your current activity level.';
    }
    if (t <= 38.0) {
      return 'Your skin temperature is slightly elevated at ${t.toStringAsFixed(1)}°C. This can be an early signal of physical exertion, stress, or mild dehydration. Rest and drink water.';
    }
    if (t <= 39.0) {
      return 'Your skin temperature is elevated at ${t.toStringAsFixed(1)}°C. This may indicate your body is under strain or fighting something. Monitor closely and rest if needed.';
    }
    return 'Your skin temperature is high at ${t.toStringAsFixed(1)}°C. This may indicate fever or significant overheating. Stop physical activity, cool down, and consult a doctor if it persists.';
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
                  _insight(temperature),
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

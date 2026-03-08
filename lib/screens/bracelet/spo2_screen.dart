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

  @override
  void initState() {
    super.initState();
    if (widget.initialSpO2 != null &&
        widget.initialSpO2! >= 1 &&
        widget.initialSpO2! <= 100) {
      _spo2Value = widget.initialSpO2;
    }
    if (widget.channel != null) {
      _isMeasuring = true;
      if (kDebugMode) debugPrint('[SpO2] live measurement started');
      widget.channel!.startSpo2Monitoring();
      _listenBracelet();
      _measurementTimeout = Timer(const Duration(seconds: 10), _onMeasurementTimeout);
    }
  }

  @override
  void dispose() {
    _measurementTimeout?.cancel();
    if (widget.channel != null) {
      widget.channel!.stopSpo2Monitoring();
    }
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
        setState(() {
          _spo2Value = spo2;
          _isMeasuring = false;
        });
        return;
      }
      // History 42 or 43: use latest valid reading
      if (kDebugMode) debugPrint('[SpO2] latest valid SpO2 selected from type=$type -> $spo2%');
      setState(() => _spo2Value = spo2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cw = AppConstants.getScaleWidth(context);

    return BraceletScaffold(
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
              isMeasuring: _isMeasuring,
              noReadingReceived: _timeoutFired && _spo2Value == null,
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
          _StatTiles(s: s, cw: cw),
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
            child: _GraphCard(s: s, cw: cw, period: _periodIndex),
          ),
          SizedBox(height: 28 * s),

          Divider(color: Colors.white.withAlpha(20), thickness: 1, height: 1),
          SizedBox(height: 28 * s),

          // ── AI Insight Card ──────────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(s: s),
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
  final bool isMeasuring;
  final bool noReadingReceived;
  const _LungsHero({
    required this.s,
    required this.cw,
    this.spo2Value,
    this.isMeasuring = false,
    this.noReadingReceived = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = isMeasuring
        ? 'Measuring...'
        : (spo2Value != null
            ? '$spo2Value%'
            : (noReadingReceived ? 'No SpO2 reading received' : '--'));
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
  const _StatTiles({required this.s, required this.cw});

  @override
  Widget build(BuildContext context) {
    final gap = 12.0 * s;
    final tileW = (cw - gap * 2) / 3;
    final tiles = [
      (
        label: 'Highest',
        value: '-1%',
        icon: Icons.trending_up,
        color: const Color(0xFF71D6AA),
      ),
      (
        label: 'Lowest',
        value: '-1%',
        icon: Icons.trending_down,
        color: const Color(0xFFD67771),
      ),
      (
        label: 'Average',
        value: '-1%',
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
            height: 140 * s,
            child: CustomPaint(painter: _Spo2BarPainter(s: s)),
          ),
        ],
      ),
    );
  }
}

class _Spo2BarPainter extends CustomPainter {
  final double s;
  const _Spo2BarPainter({required this.s});

  static const _raw = [
    25,
    30,
    45,
    100,
    60,
    45,
    30,
    20,
    40,
    35,
    25,
    20,
    42,
    28,
    45,
    25,
    75,
    20,
    10,
    8,
    5,
  ];
  static const _yLabels = ['100 %', '97 %', '50 %', '25 %'];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 38.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final yPositions = [
      0.0,
      0.2,
      0.6,
      0.85,
    ]; // Adjusted to match design 100, 97, 50, 25

    // Y Axis Labels
    for (int i = 0; i < _yLabels.length; i++) {
      tp.text = TextSpan(
        text: _yLabels[i],
        style: TextStyle(fontSize: 8.5 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, chartH * yPositions[i] - tp.height / 2));
    }

    // Dashed lines
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
    final n = _raw.length;
    final slotGap = 4.0 * s;
    final barW = (chartW - (n - 1) * slotGap) / n;

    for (int i = 0; i < n; i++) {
      final norm = _raw[i] / 100.0;
      final bH = chartH * norm;
      final x = yLabelW + i * (barW + slotGap);
      final top = chartH - bH;

      final rect = Rect.fromLTWH(x, top, barW, bH);
      canvas.drawRect(rect, Paint()..color = const Color(0xFF35B1DC));
    }

    // Bottom X Line
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

    // X Labels
    for (int i = 0; i < _xLabels.length; i++) {
      final xPos = yLabelW + (chartW / (_xLabels.length - 1)) * i;
      tp.text = TextSpan(
        text: _xLabels[i],
        style: TextStyle(fontSize: 10 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 10 * s));
    }
  }

  @override
  bool shouldRepaint(_Spo2BarPainter old) => old.s != s;
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
                  'Your blood oxygen saturation is slightly below your typical range. '
                  'Improving airflow through deeper breathing, posture adjustment, '
                  'or rest may help optimize oxygen delivery.',
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

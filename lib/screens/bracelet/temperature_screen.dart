import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bracelet/bracelet_channel.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

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

  static double? _parseTemp(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.channel != null) {
      _subscription = widget.channel!.events.listen((BraceletEvent e) {
        if (e.event != 'realtimeData' || !mounted) return;
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
            : (dataType is num ? (dataType as num).toInt() : null);
        if (type != 24) return;
        final t = _parseTemp(dicMap['temperature'] ?? dicMap['Temperature']);
        if (t == null) return;
        setState(() {
          _currentTemp = t;
          if (_minTemp == null || t < _minTemp!) _minTemp = t;
          if (_maxTemp == null || t > _maxTemp!) _maxTemp = t;
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
                _TopBar(s: s),
                SizedBox(height: 14 * s),

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
                  average: _currentTemp,
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
                  child: _GraphCard(s: s, cw: cw, period: _periodIndex),
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
                  child: _AiInsightCard(s: s),
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
                  CustomPaint(
                    painter: SmoothGradientBorder(radius: 22 * s),
                    child: ClipOval(
                      child: SizedBox(
                        width: 42 * s,
                        height: 42 * s,
                        child: Image.asset(
                          'assets/fonts/male.png',
                          fit: BoxFit.cover,
                        ),
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
      painter: SmoothGradientBorder(radius: 32 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Temperature hero: thermometer painter + live value (e.g. "36.0 C") + label
// ─────────────────────────────────────────────────────────────────────────────
class _TempHero extends StatelessWidget {
  final double s;
  final double cw;
  final double? temperature;
  const _TempHero({required this.s, required this.cw, this.temperature});

  static String _label(double t) {
    if (t < 36.0) return 'Low';
    if (t <= 37.2) return 'Normal';
    return 'High';
  }

  static IconData _labelIcon(double t) {
    if (t < 36.0) return Icons.trending_down;
    if (t <= 37.2) return Icons.remove;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    final tempStr = temperature != null
        ? '${temperature!.toStringAsFixed(1)} C'
        : '-- C';
    final labelStr = temperature != null ? _label(temperature!) : '--';
    final icon = temperature != null ? _labelIcon(temperature!) : Icons.remove;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36 * s),
      child: Column(
        children: [
          SizedBox(
            width: 100 * s,
            height: 150 * s,
            child: const CustomPaint(painter: _ThermometerPainter()),
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
                      color: AppColors.labelDim,
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(
                    icon,
                    color: AppColors.labelDim,
                    size: 14 * s,
                  ),
                ],
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
    final cx = w * 0.4;
    final bulbR = w * 0.32;
    final tubeW = w * 0.4;
    final strokeW = 4.5;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // ── Outer Body Path ──
    final path = Path();
    // Top cap
    path.addArc(Rect.fromLTWH(cx - tubeW / 2, h * 0.1, tubeW, tubeW), pi, pi);
    // Left wall
    path.moveTo(cx - tubeW / 2, h * 0.1 + tubeW / 2);
    path.lineTo(cx - tubeW / 2, h * 0.65);
    // Bulb connection
    // We'll just draw the tube and bulb as separate components if they overlap nicely,
    // but the screenshot shows a unified outline. Let's do a unified path.
    path.reset();

    final tubeTopY = h * 0.15;
    final bulbCenter = Offset(cx, h * 0.75);

    // Constructing unified path
    path.moveTo(cx - tubeW / 2, bulbCenter.dy - 15); // Left wall bottom
    path.lineTo(cx - tubeW / 2, tubeTopY + tubeW / 2);
    path.arcTo(
      Rect.fromLTWH(cx - tubeW / 2, tubeTopY, tubeW, tubeW),
      pi,
      pi,
      false,
    );
    path.lineTo(cx + tubeW / 2, bulbCenter.dy - 15); // Right wall bottom

    // Now the bulb arc
    // Angle where tube meets bulb
    const angle = 0.55;
    path.arcTo(
      Rect.fromCircle(center: bulbCenter, radius: bulbR),
      -pi / 2 + angle,
      2 * pi - 2 * angle,
      false,
    );
    path.close();

    canvas.drawPath(path, paint);

    // ── Inner Circle ──
    canvas.drawCircle(bulbCenter, bulbR * 0.45, paint);

    // ── Three Dashes ──
    final dashX = cx + bulbR + 12;
    final dashW = 10.0;
    for (int i = 0; i < 3; i++) {
      final y = h * 0.22 + i * 16;
      canvas.drawLine(Offset(dashX, y), Offset(dashX + dashW, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 stat tiles: Highest / Lowest / Average (from bracelet live data)
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
      v != null ? '${v.toStringAsFixed(1)}' : '--';

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

  static const _raw = [
    5,
    10,
    20,
    60,
    45,
    30,
    48,
    62,
    52,
    45,
    35,
    42,
    28,
    45,
    25,
    45,
    15,
    8,
    4,
  ];
  static const _yLabels = ['40 C', '36 C', '33 C', '32 C'];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 38.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final yPositions = [0.0, 0.3, 0.65, 0.85]; // 40, 36, 33, 32

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
      final norm = _raw[i] / 80.0;
      final bH = chartH * norm;
      final x = yLabelW + i * (barW + slotGap);
      final top = chartH - bH;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, bH),
        Radius.circular(barW / 2),
      );

      canvas.drawRRect(rRect, Paint()..color = const Color(0xFFFB6E6E));
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

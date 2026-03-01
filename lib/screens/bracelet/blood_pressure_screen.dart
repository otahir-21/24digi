import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
import '../../bracelet/bracelet_channel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BloodPressureScreen – shows live BP from bracelet when channel + data provided.
// ─────────────────────────────────────────────────────────────────────────────
class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key, this.channel, this.liveData});

  final BraceletChannel? channel;
  final Map<String, dynamic>? liveData;

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  int _periodIndex = 0;
  int? _systolic;
  int? _diastolic;
  bool _isEstimated = false;
  StreamSubscription<BraceletEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _applyLiveData(widget.liveData);
    if (widget.channel != null) {
      _listenBracelet();
      widget.channel!.startPpgMeasurement();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _applyLiveData(Map<String, dynamic>? data) {
    if (data == null) return;
    final sys = _intFrom(data['systolic'] ?? data['Systolic']);
    final dia = _intFrom(data['diastolic'] ?? data['Diastolic']);
    if (sys != null && dia != null) {
      setState(() { _systolic = sys; _diastolic = dia; _isEstimated = false; });
      return;
    }
    final hr = _intFrom(data['heartRate'] ?? data['HeartRate']);
    if (hr != null && hr >= 40 && hr <= 200) {
      final est = _estimateBpFromHeartRate(hr);
      setState(() { _systolic = est.$1; _diastolic = est.$2; _isEstimated = true; });
    }
  }

  void _listenBracelet() {
    _subscription?.cancel();
    _subscription = widget.channel!.events.listen((BraceletEvent e) {
      if (e.event != 'realtimeData' || !mounted) return;
      final dic = e.data['dicData'];
      if (dic == null || dic is! Map) return;
      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map((k, v) => MapEntry(k?.toString() ?? '', v)),
      );
      final flat = _flattenForBp(dicMap);
      int? sys = _intFrom(flat['systolic'] ?? flat['ECGhighBpValue'] ?? flat['highBp'] ?? flat['highBloodPressure']);
      int? dia = _intFrom(flat['diastolic'] ?? flat['ECGLowBpValue'] ?? flat['lowBp'] ?? flat['lowBloodPressure']);
      if (sys != null && dia != null && sys >= 60 && sys <= 250 && dia >= 40 && dia <= 150) {
        setState(() { _systolic = sys; _diastolic = dia; _isEstimated = false; });
        return;
      }
      final hr = _intFrom(flat['heartRate'] ?? flat['HeartRate']);
      if (hr != null && hr >= 40 && hr <= 200) {
        final est = _estimateBpFromHeartRate(hr);
        setState(() { _systolic = est.$1; _diastolic = est.$2; _isEstimated = true; });
      }
    });
  }

  static (int, int) _estimateBpFromHeartRate(int heartRate) {
    const baseSys = 100;
    const baseDia = 65;
    final hrOffset = (heartRate - 65).clamp(-30, 40);
    final sys = (baseSys + hrOffset * 0.6).round().clamp(90, 160);
    final dia = (baseDia + hrOffset * 0.4).round().clamp(55, 100);
    return (sys, dia);
  }

  static Map<String, dynamic> _flattenForBp(Map<String, dynamic> m) {
    final out = Map<String, dynamic>.from(m);
    final data = m['Data'] ?? m['data'];
    if (data is Map) {
      for (final e in (data as Map<Object?, Object?>).entries) {
        out[e.key?.toString() ?? ''] = e.value;
      }
    }
    return out;
  }

  static int? _intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return (v as num).toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;
    final sysStr = _systolic != null ? _systolic.toString() : '-1';
    final diaStr = _diastolic != null ? _diastolic.toString() : '-1';
    final lastBp = (_systolic != null && _diastolic != null) ? '$_systolic/$_diastolic' : '-1';

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
                SizedBox(height: 6 * s),

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

                // ── Hero card (live or estimated systolic / diastolic) ─
                _BorderCard(s: s, child: _BpHero(s: s, cw: cw, systolic: sysStr, diastolic: diaStr, isEstimated: _isEstimated)),
                SizedBox(height: 14 * s),

                // ── 2 stat tiles ─────────────────────────────────────
                _StatTiles(s: s, cw: cw, lastBp: lastBp),
                SizedBox(height: 14 * s),

                // ── Period toggle ────────────────────────────────────
                _PeriodToggle(
                  s: s,
                  selected: _periodIndex,
                  onTap: (i) => setState(() => _periodIndex = i),
                ),
                SizedBox(height: 14 * s),

                // ── Graph card ───────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _GraphCard(s: s, cw: cw, period: _periodIndex),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight ───────────────────────────────────────
                _BorderCard(s: s, child: _AiInsightCard(s: s)),
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
// Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  const _BorderCard({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BP hero card: drop icon + systolic/diastolic + Measure button
// ─────────────────────────────────────────────────────────────────────────────
class _BpHero extends StatelessWidget {
  final double s;
  final double cw;
  final String systolic;
  final String diastolic;
  final bool isEstimated;
  const _BpHero({required this.s, required this.cw, required this.systolic, required this.diastolic, this.isEstimated = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, 14 * s, 18 * s, 18 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Blood\nPressure',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10 * s),

          // Drop + ECG icon
          Center(
            child: SizedBox(
              width: cw * 0.36,
              height: cw * 0.40,
              child: const CustomPaint(painter: _BpDropPainter()),
            ),
          ),
          SizedBox(height: 14 * s),

          // Systolic / Diastolic
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BigNum(s: s, value: systolic, unit: 'mmHg'),
              Padding(
                padding: EdgeInsets.only(bottom: 20 * s),
                child: Text(
                  ' / ',
                  style: GoogleFonts.inter(
                    fontSize: 36 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
              _BigNum(s: s, value: diastolic, unit: 'mmHg'),
            ],
          ),
          if (isEstimated)
            Padding(
              padding: EdgeInsets.only(top: 6 * s),
              child: Center(
                child: Text(
                  'Estimated from heart rate',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: AppColors.labelDim,
                  ),
                ),
              ),
            ),
          SizedBox(height: 18 * s),

          // Measure button
          Center(
            child: CustomPaint(
              painter: SmoothGradientBorder(radius: 22 * s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22 * s),
                child: Container(
                  width: cw * 0.55,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyan.withAlpha(30),
                        AppColors.purple.withAlpha(30),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Measure',
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigNum extends StatelessWidget {
  final double s;
  final String value;
  final String unit;
  const _BigNum({required this.s, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 52 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
            shadows: [
              Shadow(
                color: const Color(0xFF43C6E4).withAlpha(110),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

// Water-drop shape with ECG pulse inside – cyan→purple gradient
class _BpDropPainter extends CustomPainter {
  const _BpDropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.14
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF43C6E4).withAlpha(55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // ── Drop outline (top sharp point, arc bottom, break on right for ECG exit) ──
    final drop = Path();
    // Start at top sharp point
    drop.moveTo(w * 0.5, h * 0.05);
    // Left side down
    drop.cubicTo(w * 0.5, h * 0.05, w * 0.1, h * 0.4, w * 0.1, h * 0.7);
    drop.arcToPoint(
      Offset(w * 0.65, h * 0.9),
      radius: Radius.circular(w * 0.4),
      clockwise: false,
    );
    // Right break / nub back up to top
    drop.moveTo(w * 0.78, h * 0.45);
    drop.quadraticBezierTo(w * 0.85, h * 0.35, w * 0.5, h * 0.05);

    // ── ECG pulse ──
    final ekg = Path();
    ekg.moveTo(w * 0.35, h * 0.58);
    ekg.lineTo(w * 0.45, h * 0.58);
    ekg.lineTo(w * 0.52, h * 0.72); // down spike
    ekg.lineTo(w * 0.62, h * 0.45); // high spike
    ekg.lineTo(w * 0.68, h * 0.68); // back down
    ekg.lineTo(w * 0.74, h * 0.58); // level
    ekg.lineTo(w * 0.88, h * 0.58); // exit right

    canvas.drawPath(drop, glow);
    canvas.drawPath(ekg, glow);
    canvas.drawPath(drop, paint);
    canvas.drawPath(ekg, paint);
  }

  @override
  bool shouldRepaint(_BpDropPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2 stat tiles: My Last BP / My Average BP (live data when available)
// ─────────────────────────────────────────────────────────────────────────────
class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  final String lastBp;
  final String averageBp;
  const _StatTiles({required this.s, required this.cw, required this.lastBp, this.averageBp = '-1'});

  @override
  Widget build(BuildContext context) {
    final gap = 8.0 * s;
    final tileW = (cw - gap) / 2;
    return Row(
      children: [
        _StatTile(
          s: s,
          width: tileW,
          label: 'My Last BP',
          value: lastBp,
        ),
        SizedBox(width: gap),
        _StatTile(
          s: s,
          width: tileW,
          label: 'My average BP',
          value: averageBp,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final double s;
  final double width;
  final String label;
  final String value;
  const _StatTile(
      {required this.s,
      required this.width,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 14 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9 * s,
                      color: AppColors.labelDim,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 5 * s),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
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
// Period toggle
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodToggle extends StatelessWidget {
  final double s;
  final int selected;
  final ValueChanged<int> onTap;
  const _PeriodToggle(
      {required this.s, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Weekly', 'Monthly'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final active = i == selected;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 6 * s),
            padding:
                EdgeInsets.symmetric(horizontal: 18 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: active ? AppColors.cyan.withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: active ? AppColors.cyan : AppColors.divider,
                width: 1,
              ),
            ),
            child: Text(
              labels[i],
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.cyan : AppColors.labelDim,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Graph card: dual bars (Systolic = cyan, Diastolic = purple)
// ─────────────────────────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  const _GraphCard({required this.s, required this.cw, required this.period});

  @override
  Widget build(BuildContext context) {
    const titles = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[period],
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 8 * s),
          // Legend
          Row(
            children: [
              _LegendDot(s: s, color: AppColors.cyan, label: 'Systolic'),
              SizedBox(width: 14 * s),
              _LegendDot(s: s, color: AppColors.purple, label: 'Diastolic'),
            ],
          ),
          SizedBox(height: 10 * s),
          SizedBox(
            width: double.infinity,
            height: 180 * s,
            child: CustomPaint(painter: _BpBarPainter(s: s)),
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
  const _LegendDot(
      {required this.s, required this.color, required this.label});

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
        SizedBox(width: 5 * s),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

class _BpBarPainter extends CustomPainter {
  final double s;
  const _BpBarPainter({required this.s});

  // 6 time slots (00 03 06 09 12 15 18 21 → simplified to 8 slots)
  // Systolic values (~115-155 range)
  static const _sys = [125.0, 138.0, 148.0, 155.0, 145.0, 130.0, 120.0, 118.0];
  // Diastolic values (~70-95 range)
  static const _dia = [72.0, 80.0, 88.0, 95.0, 88.0, 80.0, 74.0, 72.0];

  static const _yTicks = [180.0, 160.0, 140.0, 120.0, 100.0, 80.0, 60.0, 40.0];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 34.0 * s;
    final xLabelH = 18.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;

    const minVal = 30.0;
    const maxVal = 180.0;
    const range = maxVal - minVal;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // ── Dashed horizontal guide lines + Y labels ──
    final dashPaint = Paint()
      ..color = AppColors.cyan.withAlpha(28)
      ..strokeWidth = 1;

    for (final tick in _yTicks) {
      final yFrac = 1.0 - (tick - minVal) / range;
      final y = chartH * yFrac;

      tp
        ..text = TextSpan(
            text: tick.toInt().toString(),
            style: TextStyle(fontSize: 7.5 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // ── Dual bars ──
    final n = _sys.length;
    // Each slot: two bars + inner gap, plus slot gaps
    const innerGap = 2.0;
    const slotGap = 6.0;
    final slotW = (chartW - (n - 1) * slotGap) / n;
    final barW = (slotW - innerGap) / 2;

    for (int i = 0; i < n; i++) {
      final slotX = yLabelW + i * (slotW + slotGap);

      // Systolic bar (left of pair, cyan)
      final sysNorm = (_sys[i] - minVal) / range;
      final sysH = chartH * sysNorm;
      final sysRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX, chartH - sysH, barW, sysH),
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(
        sysRRect,
        Paint()
          ..color = AppColors.cyan.withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        sysRRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cyan, AppColors.cyan.withAlpha(160)],
          ).createShader(
              Rect.fromLTWH(slotX, chartH - sysH, barW, sysH)),
      );

      // Diastolic bar (right of pair, purple)
      final diaX = slotX + barW + innerGap;
      final diaNorm = (_dia[i] - minVal) / range;
      final diaH = chartH * diaNorm;
      final diaRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(diaX, chartH - diaH, barW, diaH),
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(
        diaRRect,
        Paint()
          ..color = AppColors.purple.withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        diaRRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple, AppColors.purple.withAlpha(160)],
          ).createShader(
              Rect.fromLTWH(diaX, chartH - diaH, barW, diaH)),
      );
    }

    // ── X labels ──
    for (int i = 0; i < _xLabels.length; i++) {
      final xPos = yLabelW + (chartW / (_xLabels.length - 1)) * i;
      tp
        ..text = TextSpan(
            text: _xLabels[i],
            style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 2));
    }
  }

  @override
  bool shouldRepaint(_BpBarPainter old) => old.s != s;
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
          Icon(Icons.auto_awesome_rounded,
              color: AppColors.cyan, size: 22 * s),
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
                  'Your blood pressure pattern shows signs of elevation beyond your usual range. '
                  'This may be linked to stress, low recovery, or lifestyle factors. '
                  'The AI suggests rest and monitoring trends over time.',
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

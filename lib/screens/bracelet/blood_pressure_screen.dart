import 'dart:math';
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
      setState(() {
        _systolic = sys;
        _diastolic = dia;
        _isEstimated = false;
      });
      return;
    }
    final hr = _intFrom(data['heartRate'] ?? data['HeartRate']);
    if (hr != null && hr >= 40 && hr <= 200) {
      final est = _estimateBpFromHeartRate(hr);
      setState(() {
        _systolic = est.$1;
        _diastolic = est.$2;
        _isEstimated = true;
      });
    }
  }

  void _listenBracelet() {
    _subscription?.cancel();
    _subscription = widget.channel!.events.listen((BraceletEvent e) {
      if (e.event != 'realtimeData' || !mounted) return;
      final dic = e.data['dicData'];
      if (dic == null || dic is! Map) return;
      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final flat = _flattenForBp(dicMap);
      int? sys = _intFrom(
        flat['systolic'] ??
            flat['ECGhighBpValue'] ??
            flat['highBp'] ??
            flat['highBloodPressure'],
      );
      int? dia = _intFrom(
        flat['diastolic'] ??
            flat['ECGLowBpValue'] ??
            flat['lowBp'] ??
            flat['lowBloodPressure'],
      );
      if (sys != null &&
          dia != null &&
          sys >= 60 &&
          sys <= 250 &&
          dia >= 40 &&
          dia <= 150) {
        setState(() {
          _systolic = sys;
          _diastolic = dia;
          _isEstimated = false;
        });
        return;
      }
      final hr = _intFrom(flat['heartRate'] ?? flat['HeartRate']);
      if (hr != null && hr >= 40 && hr <= 200) {
        final est = _estimateBpFromHeartRate(hr);
        setState(() {
          _systolic = est.$1;
          _diastolic = est.$2;
          _isEstimated = true;
        });
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
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;
    final sysStr = _systolic != null ? _systolic.toString() : '--';
    final diaStr = _diastolic != null ? _diastolic.toString() : '--';
    final lastBp = (_systolic != null && _diastolic != null)
        ? '$_systolic/$_diastolic'
        : '--/--';

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

                // ── Hero Section ─────────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: _BpHero(
                    s: s,
                    cw: cw,
                    systolic: sysStr,
                    diastolic: diaStr,
                    isEstimated: _isEstimated,
                  ),
                ),
                SizedBox(height: 28 * s),

                // ── Stat Tiles ───────────────────────────────────────────
                _StatTiles(s: s, cw: cw, lastBp: lastBp, averageBp: '-- / --'),
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
// Card wrapper
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
// BP hero card: drop icon + systolic/diastolic + Measure button
// ─────────────────────────────────────────────────────────────────────────────
class _BpHero extends StatelessWidget {
  final double s;
  final double cw;
  final String systolic;
  final String diastolic;
  final bool isEstimated;
  const _BpHero({
    required this.s,
    required this.cw,
    required this.systolic,
    required this.diastolic,
    this.isEstimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(22 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Blood\nPressure',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: AppColors.labelDim,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12 * s),

          Center(
            child: SizedBox(
              width: 140 * s,
              height: 160 * s,
              child: const CustomPaint(painter: _BpDropPainter()),
            ),
          ),
          SizedBox(height: 24 * s),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _BigNum(s: s, value: systolic, unit: 'mmHg'),
              SizedBox(width: 12 * s),
              Text(
                '/',
                style: GoogleFonts.inter(
                  fontSize: 48 * s,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12 * s),
              _BigNum(s: s, value: diastolic, unit: 'mmHg'),
            ],
          ),
          SizedBox(height: 28 * s),

          Center(
            child: CustomPaint(
              painter: SmoothGradientBorder(radius: 24 * s),
              child: Container(
                width: 180 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 * s),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1B263B).withAlpha(180),
                      const Color(0xFF0D1B2A).withAlpha(180),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Measure',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          unit,
          style: GoogleFonts.inter(fontSize: 10 * s, color: AppColors.labelDim),
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
    final cx = w / 2;
    final strokeW = 5.0;

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

    // ── More Pointed Drop Shape ──
    final dropPath = Path();
    dropPath.moveTo(cx, h * 0.05); // Sharper top

    // Left side
    dropPath.cubicTo(cx - 10, h * 0.15, cx - 55, h * 0.45, cx - 55, h * 0.7);
    // Bottom arc
    dropPath.arcTo(
      Rect.fromCircle(center: Offset(cx, h * 0.7), radius: 55),
      pi,
      -pi,
      false,
    );
    // Right side back to top
    dropPath.cubicTo(cx + 55, h * 0.45, cx + 10, h * 0.15, cx, h * 0.05);

    canvas.drawPath(dropPath, paint);

    // ── Stylized ECG Pulse ──
    final ecgPath = Path();
    final ecgY = h * 0.65;
    ecgPath.moveTo(cx - 35, ecgY);
    ecgPath.lineTo(cx - 15, ecgY);
    ecgPath.lineTo(cx - 5, ecgY + 20); // Spike down
    ecgPath.lineTo(cx + 8, ecgY - 45); // Tall spike up
    ecgPath.lineTo(cx + 25, ecgY + 15); // Spike down
    ecgPath.lineTo(cx + 35, ecgY);
    ecgPath.lineTo(cx + 55, ecgY);

    canvas.drawPath(ecgPath, paint);
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
  const _StatTiles({
    required this.s,
    required this.cw,
    required this.lastBp,
    this.averageBp = '-- / --',
  });

  @override
  Widget build(BuildContext context) {
    final gap = 12.0 * s;
    final tileW = (cw - gap) / 2;
    return Row(
      children: [
        _StatTile(s: s, width: tileW, label: 'My Last BP', value: lastBp),
        SizedBox(width: gap),
        _StatTile(s: s, width: tileW, label: 'My average BP', value: averageBp),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final double s;
  final double width;
  final String label;
  final String value;
  const _StatTile({
    required this.s,
    required this.width,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _BorderCard(
        s: s,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 18 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w200,
                  color: AppColors.labelDim,
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 38 * s,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
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
          // Legend
          Row(
            children: [
              _LegendDot(
                s: s,
                color: const Color(0xFF9F56F5),
                label: 'Systolic',
              ),
              SizedBox(width: 16 * s),
              _LegendDot(
                s: s,
                color: const Color(0xFF43C6E4),
                label: 'Diastolic',
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          SizedBox(
            width: double.infinity,
            height: 200 * s,
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
        SizedBox(width: 5 * s),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

class _BpBarPainter extends CustomPainter {
  final double s;
  const _BpBarPainter({required this.s});

  static const _sys = [120.0, 145.0, 135.0, 140.0, 155.0];
  static const _dia = [80.0, 95.0, 85.0, 90.0, 100.0];

  static const _yLabels = [
    '180',
    '120',
    '80',
    '40',
    '0',
    '40',
    '80',
    '120',
    '180',
  ];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 40.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;
    final zeroY = chartH / 2;
    final halfH = chartH / 2;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y Axis Labels
    final yPosFractions = [0.0, 0.16, 0.27, 0.38, 0.5, 0.62, 0.73, 0.84, 1.0];
    for (int i = 0; i < _yLabels.length; i++) {
      tp.text = TextSpan(
        text: _yLabels[i],
        style: TextStyle(fontSize: 8.5 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, chartH * yPosFractions[i] - tp.height / 2));
    }

    // Dashed lines
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 0.5;
    for (final frac in yPosFractions) {
      final y = chartH * frac;
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 4 * s, y), dashPaint);
        dx += 8 * s;
      }
    }

    // Bars
    final n = _sys.length;
    final barW = 14.0 * s; // Thicker bars
    final slotGap =
        (chartW - (n * barW)) /
        (n - 1); // Dynamically calculate gap for thick bars

    for (int i = 0; i < n; i++) {
      final x = yLabelW + i * (barW + slotGap);

      // Systolic (UP) - Purple
      final sysNorm = _sys[i] / 180.0;
      final sysH = halfH * sysNorm;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, zeroY - sysH, barW, sysH),
          Radius.circular(barW / 2),
        ),
        Paint()..color = const Color(0xFF9F56F5),
      );

      // Diastolic (DOWN) - Teal
      final diaNorm = _dia[i] / 180.0;
      final diaH = halfH * diaNorm;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, zeroY, barW, diaH),
          Radius.circular(barW / 2),
        ),
        Paint()..color = const Color(0xFF43C6E4),
      );
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
                  'Your blood pressure pattern shows signs of elevation beyond your usual range. '
                  'This may be linked to stress, low recovery, or lifestyle factors. '
                  'The AI suggests rest and monitoring trends over time.',
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

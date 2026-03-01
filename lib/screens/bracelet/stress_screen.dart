import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../painters/stress_icon_painter.dart';
import '../../widgets/digi_background.dart';
import '../../bracelet/bracelet_channel.dart';

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

  double get gradientValue =>
      current < 0 || current > 100 ? 0.0 : current / 100.0;
  String get levelLabel {
    if (current < 0) return 'Low';
    if (current < 33) return 'Low';
    if (current < 66) return 'Medium';
    return 'High';
  }
}

class _StressScreenState extends State<StressScreen> {
  int _periodIndex = 0;
  StreamSubscription<BraceletEvent>? _subscription;
  _StressData _stressData = const _StressData(
    current: 57,
    max: 82,
    min: 45,
    medium: 61,
    barValues: [52, 78, 88, 68, 82, 65, 76],
  );

  final List<double> _stressHistory = [];
  static const int _maxBarHistory = 8;

  @override
  void initState() {
    super.initState();
    if (widget.channel != null) {
      _listenBracelet();
      widget.channel!.requestHRVData();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenBracelet() {
    _subscription?.cancel();
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
          : (dataType is num ? dataType.toInt() : null);
      if (type == null) return;

      int? stressFromDevice;
      if (type == 38 || type == 56) {
        final sVal = dicMap['Stress'] ?? dicMap['stress'];
        if (sVal != null) stressFromDevice = _parseInt(sVal);
      }

      int? derivedStress;
      if (type == 24) {
        final hr = dicMap['heartRate'];
        if (hr != null) {
          final hrVal = _parseInt(hr);
          if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
            derivedStress = _stressFromHeartRate(hrVal);
          }
        }
      }

      final int? current = stressFromDevice ?? derivedStress;
      if (current == null) return;
      setState(() {
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
        final mediumVal = vals.isEmpty ? current : (sum / vals.length).round();
        final barValues = List<double>.from(vals);
        _stressData = _StressData(
          current: current,
          max: maxVal,
          min: minVal,
          medium: mediumVal,
          barValues: barValues,
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
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;
    final d = _stressData;

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

                _BorderCard(
                  s: s,
                  child: _StressHero(
                    s: s,
                    value: d.current < 0 ? 57 : d.current,
                    levelLabel: d.levelLabel,
                  ),
                ),
                SizedBox(height: 28 * s),

                _GradientBar(
                  s: s,
                  value: d.gradientValue <= 0 ? 0.57 : d.gradientValue,
                ),
                SizedBox(height: 28 * s),

                _StatTiles(
                  s: s,
                  cw: cw,
                  maxVal: d.max < 0 ? 82 : d.max,
                  mediumVal: d.medium < 0 ? 61 : d.medium,
                  minVal: d.min < 0 ? 45 : d.min,
                ),
                SizedBox(height: 24 * s),

                Center(
                  child: _PeriodPillToggle(
                    s: s,
                    selected: _periodIndex,
                    onTap: (i) => setState(() => _periodIndex = i),
                  ),
                ),
                SizedBox(height: 24 * s),

                _BorderCard(
                  s: s,
                  child: _GraphCard(
                    s: s,
                    period: _periodIndex,
                    barValues: d.barValues,
                  ),
                ),
                SizedBox(height: 28 * s),

                Divider(
                  color: Colors.white.withAlpha(20),
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 28 * s),

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

class _StressHero extends StatelessWidget {
  final double s;
  final int value;
  final String levelLabel;
  const _StressHero({
    required this.s,
    required this.value,
    required this.levelLabel,
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
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 68 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                levelLabel,
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: AppColors.labelDim,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(
                Icons.trending_down_rounded,
                color: AppColors.cyan,
                size: 14 * s,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  final double s;
  final double value;
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
  final double value;
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

    final markerX = size.width * value;
    final markerPath = Path();
    markerPath.moveTo(markerX - 6 * s, 0);
    markerPath.lineTo(markerX + 6 * s, 0);
    markerPath.lineTo(markerX, 10 * s);
    markerPath.close();

    canvas.drawPath(markerPath, Paint()..color = Colors.white.withAlpha(200));
    canvas.drawLine(
      Offset(markerX, 10 * s),
      Offset(markerX, barY + 4 * s),
      Paint()
        ..color = Colors.white.withAlpha(100)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_GradientBarPainter old) => old.value != value;
}

class _StatTiles extends StatelessWidget {
  final double s;
  final double cw;
  final int maxVal;
  final int mediumVal;
  final int minVal;
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
    final tileW = (cw - gap * 2) / 3;
    final tiles = [
      (
        label: 'Max',
        value: maxVal.toString(),
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFE53935),
      ),
      (
        label: 'Medium',
        value: mediumVal.toString(),
        icon: Icons.trending_flat_rounded,
        color: const Color(0xFF43C6E4),
      ),
      (
        label: 'Min',
        value: minVal.toString(),
        icon: Icons.trending_down_rounded,
        color: const Color(0xFF9F56F5),
      ),
    ];
    return Row(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Padding(
          padding: EdgeInsets.only(right: i < 2 ? gap : 0),
          child: SizedBox(
            width: tileW,
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
          Row(
            children: [
              _LegendDot(
                s: s,
                color: const Color(0xFF4CAF50),
                label: 'Calm Periods',
              ),
              SizedBox(width: 16 * s),
              _LegendDot(
                s: s,
                color: const Color(0xFF43C6E4),
                label: 'Neutral',
              ),
              SizedBox(width: 16 * s),
              _LegendDot(
                s: s,
                color: const Color(0xFFE53935),
                label: 'Stress Peaks',
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          SizedBox(
            width: double.infinity,
            height: 200 * s,
            child: CustomPaint(
              painter: _StressBarPainter(s: s, barValues: barValues),
            ),
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
          style: GoogleFonts.inter(
            fontSize: 8.5 * s,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

class _StressBarPainter extends CustomPainter {
  final double s;
  final List<double> barValues;
  const _StressBarPainter({required this.s, required this.barValues});

  static const _yLabels = ['100', '75', '50', '25'];
  static const _xLabels = ['00', '06', '12', '18', '00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 40.0 * s;
    final xLabelH = 20.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height - xLabelH;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final bands = [
      (bottom: 0, top: 40, color: const Color(0xFF1B5E20).withAlpha(100)),
      (bottom: 40, top: 78, color: const Color(0xFF0D3B4F).withAlpha(100)),
      (bottom: 78, top: 100, color: const Color(0xFF7B1515).withAlpha(100)),
    ];

    for (var band in bands) {
      final yTop = chartH * (1.0 - band.top / 100.0);
      final yBottom = chartH * (1.0 - band.bottom / 100.0);
      canvas.drawRect(
        Rect.fromLTWH(yLabelW, yTop, chartW, yBottom - yTop),
        Paint()..color = band.color,
      );
    }

    final yPos = [0.0, 0.25, 0.5, 0.75, 1.0];
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 0.5;

    for (int i = 0; i < _yLabels.length; i++) {
      tp.text = TextSpan(
        text: _yLabels[i],
        style: TextStyle(fontSize: 9 * s, color: AppColors.labelDim),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, chartH * (i * 0.25) - tp.height / 2));
    }

    for (var f in yPos) {
      final y = chartH * f;
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 4 * s, y), dashPaint);
        dx += 8 * s;
      }
    }

    final n = 7;
    const sampleValues = [52.0, 78.0, 88.0, 68.0, 82.0, 65.0, 76.0];
    final barW = 16.0 * s;
    final slotGap = (chartW - (n * barW)) / (n - 1);

    for (int i = 0; i < n; i++) {
      final x = yLabelW + i * (barW + slotGap);
      final val = i < barValues.length ? barValues[i] : sampleValues[i];
      final currentVal = val < 0 ? sampleValues[i] : val;
      final h = chartH * (currentVal.clamp(0, 100) / 100.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartH - h, barW, h),
          Radius.circular(barW / 2),
        ),
        Paint()..color = const Color(0xFF43C6E4),
      );
    }

    final xLineY = chartH + 5 * s;
    double bx = yLabelW;
    while (bx < size.width) {
      canvas.drawLine(
        Offset(bx, xLineY),
        Offset(bx + 2 * s, xLineY),
        Paint()
          ..color = Colors.white.withAlpha(40)
          ..strokeWidth = 1,
      );
      bx += 4 * s;
    }

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
  bool shouldRepaint(_StressBarPainter old) => true;
}

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
                  'Your stress levels have remained elevated for extended periods. '
                  'The AI recommends a short recovery window — deep breathing, '
                  'a brief walk, or disengaging from screens — to help reset your system.',
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

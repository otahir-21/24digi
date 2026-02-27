import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
import 'heart_screen.dart';
import 'sleep_screen.dart';
import 'blood_pressure_screen.dart';
import 'hrv_screen.dart';
import 'hydration_screen.dart';
import 'spo2_screen.dart';
import 'activities_screen.dart';
import 'progress_screen.dart';
import 'stress_screen.dart';
import 'temperature_screen.dart';


// BraceletScreen
// ─────────────────────────────────────────────────────────────────────────────
class BraceletScreen extends StatefulWidget {
  const BraceletScreen({super.key});

  @override
  State<BraceletScreen> createState() => _BraceletScreenState();
}

class _BraceletScreenState extends State<BraceletScreen> {
  int _activeTab = 0;

  static const _tabs = ['All', 'Walking', 'Running', 'Cycling', 'Workout'];
  static const _tabIcons = [
    Icons.grid_view_rounded,
    Icons.directions_walk_rounded,
    Icons.directions_run_rounded,
    Icons.directions_bike_rounded,
    Icons.fitness_center_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────────────
                _TopBar(s: s),
                SizedBox(height: 6 * s),

                // ── Hi user ──────────────────────────────────────────
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
                SizedBox(height: 16 * s),

                // ── Progress card ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressScreen()),
                  ),
                  child: _BorderCard(
                    s: s,
                    width: cw,
                    child: _ProgressCard(s: s),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Activity tabs ─────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final active = i == _activeTab;
                      return GestureDetector(
                        onTap: () => setState(() => _activeTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 8 * s),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * s,
                            vertical: 8 * s,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24 * s),
                            color: active
                                ? AppColors.cyanTint18
                                : const Color(0xFF0A1820),
                            border: Border.all(
                              color: active
                                  ? AppColors.cyan
                                  : const Color(0xFF1E3040),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tabIcons[i],
                                size: 14 * s,
                                color: active
                                    ? AppColors.cyan
                                    : AppColors.labelDim,
                              ),
                              SizedBox(width: 5 * s),
                              Text(
                                _tabs[i],
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active
                                      ? AppColors.cyan
                                      : AppColors.labelDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 12 * s),

                // ── Latest Activity label ─────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ActivitiesScreen()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Activity',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w400,
                          color: AppColors.labelDim,
                        ),
                      ),
                      Text(
                        'View All >',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * s),

                // ── Activity card ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ActivitiesScreen()),
                  ),
                  child: _BorderCard(
                    s: s,
                    width: cw,
                    child: _ActivityCard(s: s),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Recovery Data button ──────────────────────────────
                _BorderCard(
                  s: s,
                  width: cw,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 18 * s, vertical: 14 * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recovery Data',
                          style: TextStyle(
                            fontFamily: 'LemonMilk',
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: AppColors.cyan, size: 20 * s),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Health metrics 2×4 grid ───────────────────────────
                _HealthGrid(s: s, cw: cw),
                SizedBox(height: 20 * s),
              ],
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
  final double width;
  final Widget child;
  const _BorderCard(
      {required this.s, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 16 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar (pill with back arrow + logo + avatar)
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
// Progress card (concentric rings + stat rows)
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final double s;
  const _ProgressCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.cyan, size: 20 * s),
            ],
          ),
          SizedBox(height: 14 * s),

          // Rings + stats
          Row(
            children: [
              // Stats left
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      s: s,
                      color: const Color(0xFFE53935),
                      icon: Icons.local_fire_department_rounded,
                      label: 'CALORIES (Kcal)',
                      value: '800',
                      sub: '--- / 800',
                    ),
                    SizedBox(height: 12 * s),
                    _StatRow(
                      s: s,
                      color: AppColors.cyan,
                      icon: Icons.directions_walk_rounded,
                      label: 'STEPS',
                      value: '10,000',
                      sub: '--- / 1',
                    ),
                    SizedBox(height: 12 * s),
                    _StatRow(
                      s: s,
                      color: const Color(0xFF00C853),
                      icon: Icons.straighten_rounded,
                      label: 'DISTANCE (km)',
                      value: '8,000',
                      sub: '--- / 1',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),

              // Rings right
              SizedBox(
                width: 110 * s,
                height: 110 * s,
                child: CustomPaint(
                  painter: _RingsPainter(
                    caloriesProgress: 0.55,
                    stepsProgress: 0.70,
                    distanceProgress: 0.40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final double s;
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  const _StatRow({
    required this.s,
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14 * s),
        SizedBox(width: 6 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                color: AppColors.labelDim,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                color: AppColors.labelDimmer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Concentric progress-rings painter
// ─────────────────────────────────────────────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double distanceProgress;

  const _RingsPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.distanceProgress,
  });

  void _drawRing(Canvas canvas, Size size, double inset, double progress,
      Color color) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - inset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track (inactive arc)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = color.withAlpha(40)
        ..strokeCap = StrokeCap.round,
    );
    // Active arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawRing(canvas, size, 4, caloriesProgress, const Color(0xFFE53935));
    _drawRing(canvas, size, 20, stepsProgress, AppColors.cyan);
    _drawRing(canvas, size, 36, distanceProgress, const Color(0xFF00C853));
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.caloriesProgress != caloriesProgress ||
      old.stepsProgress != stepsProgress ||
      old.distanceProgress != distanceProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Latest activity card
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final double s;
  const _ActivityCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14 * s),
      child: Column(
        children: [
          // Running header row
          Row(
            children: [
              Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyanTint10,
                  border:
                      Border.all(color: AppColors.cyan.withAlpha(60)),
                ),
                child: Icon(Icons.directions_run_rounded,
                    color: AppColors.cyan, size: 22 * s),
              ),
              SizedBox(width: 12 * s),
              Text(
                'Running',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TimeRow(s: s, label: 'Start', time: '6:30 AM'),
                  SizedBox(height: 2 * s),
                  _TimeRow(s: s, label: 'Finish', time: '7:30 AM'),
                ],
              ),
            ],
          ),
          SizedBox(height: 14 * s),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 10 * s),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActivityStat(s: s, value: '8 min/km', label: 'Pace'),
              _ActivityStat(s: s, value: '1,200 KM', label: 'Distance'),
              _ActivityStat(s: s, value: '285 Kcal', label: 'Calories'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final double s;
  final String label;
  final String time;
  const _TimeRow(
      {required this.s, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: GoogleFonts.inter(
              fontSize: 9 * s, color: AppColors.labelDim),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 2 * s),
        Icon(Icons.arrow_forward_ios_rounded,
            size: 8 * s, color: AppColors.labelDim),
      ],
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final double s;
  final String value;
  final String label;
  const _ActivityStat(
      {required this.s, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2 * s),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 9 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health metrics 2-column grid (8 tiles)
// ─────────────────────────────────────────────────────────────────────────────
class _HealthGrid extends StatelessWidget {
  final double s;
  final double cw;
  const _HealthGrid({required this.s, required this.cw});

  static const _metrics = [
    (title: 'SLEEP',          value: '7h 15m', unit: 'C',    color: Color(0xFF7C4DFF), trend: '8h →→'),
    (title: 'HYDRATION',      value: '72.5',   unit: '%',    color: Color(0xFF00BCD4), trend: '76% →→'),
    (title: 'HEART RATE',     value: '72',     unit: 'bpm',  color: Color(0xFFE53935), trend: '71.2 ↑↑'),
    (title: 'HRV',            value: '45',     unit: 'MS',   color: Color(0xFF00C853), trend: '38.7 ↑↑'),
    (title: 'STRESS',         value: '35',     unit: 'Low',  color: Color(0xFFFFB300), trend: '62.9 ↑↑'),
    (title: 'SPO2',           value: '98',     unit: '%',    color: Color(0xFF00BCD4), trend: '99% →→'),
    (title: 'TEMPERATURE',    value: '36.5',   unit: '°C',   color: Color(0xFFE53935), trend: '36.8 ↑↑'),
    (title: 'BLOOD PRESSURE', value: '120/80', unit: 'mmHg', color: Color(0xFF7C4DFF), trend: '118/80 →→'),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = 10.0 * s;
    final cardW = (cw - gap) / 2;
    VoidCallback? tapFor(int index, BuildContext ctx) {
      if (_metrics[index].title == 'HEART RATE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HeartScreen()),
            );
      }
      if (_metrics[index].title == 'SLEEP') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const SleepScreen()),
            );
      }
      if (_metrics[index].title == 'HYDRATION') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HydrationScreen()),
            );
      }
      if (_metrics[index].title == 'SPO2') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const Spo2Screen()),
            );
      }
      if (_metrics[index].title == 'HRV') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HrvScreen()),
            );
      }
      if (_metrics[index].title == 'TEMPERATURE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const TemperatureScreen()),
            );
      }
      if (_metrics[index].title == 'BLOOD PRESSURE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const BloodPressureScreen()),
            );
      }
      if (_metrics[index].title == 'STRESS') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const StressScreen()),
            );
      }
      return null;
    }

    final rows = <Widget>[];
    for (int i = 0; i < _metrics.length; i += 2) {
      rows.add(Row(
        children: [
          _MetricCard(
              s: s,
              width: cardW,
              m: _metrics[i],
              onTap: tapFor(i, context)),
          SizedBox(width: gap),
          _MetricCard(
              s: s,
              width: cardW,
              m: _metrics[i + 1],
              onTap: tapFor(i + 1, context)),
        ],
      ));
      if (i + 2 < _metrics.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

class _MetricCard extends StatelessWidget {
  final double s;
  final double width;
  final ({String title, String value, String unit, Color color, String trend}) m;
  final VoidCallback? onTap;

  const _MetricCard(
      {required this.s, required this.width, required this.m, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 14 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 12 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + chevron
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          m.title,
                          style: GoogleFonts.inter(
                            fontSize: 8 * s,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelDim,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.labelDim, size: 14 * s),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  // Value
                  Text(
                    m.value,
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  // Unit + trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m.unit,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                      Text(
                        m.trend,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: m.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

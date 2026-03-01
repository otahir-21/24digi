import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../painters/smooth_gradient_border.dart';

// ── Progress Card ─────────────────────────────────────────────────────────────
class ProgressCard extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;
  final VoidCallback? onTap;

  const ProgressCard({super.key, required this.s, this.liveData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final calories = _toDouble(liveData?['calories']) ?? 0;
    final steps = _toInt(liveData?['step']) ?? 0;
    final distance = _toDouble(liveData?['distance']) ?? 0;

    final goalCalories = 800.0;
    final goalSteps = 10000.0;
    final goalDistance = 8000.0; // Assuming it's in meters from screenshot

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 20 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Container(
            color: const Color(0xFF060E16).withOpacity(0.8),
            padding: EdgeInsets.all(20 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS',
                      style: AppStyles.lemon16(s).copyWith(letterSpacing: 1.0),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.cyan,
                      size: 24 * s,
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _ProgressMetric(
                            s: s,
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.red,
                            label: 'CALORIES (Kcal)',
                            value: calories > 0
                                ? calories.toStringAsFixed(0)
                                : '-- --',
                            target: '800',
                          ),
                          SizedBox(height: 15 * s),
                          _ProgressMetric(
                            s: s,
                            icon: Icons.directions_run_rounded,
                            iconColor: Colors.blueAccent,
                            label: 'STEPS',
                            value: steps > 0 ? steps.toString() : '-- --',
                            target: '10,000',
                          ),
                          SizedBox(height: 15 * s),
                          _ProgressMetric(
                            s: s,
                            icon: Icons.location_on_rounded,
                            iconColor: Colors.green,
                            label: 'DISTANCE (km)',
                            value: distance > 0
                                ? distance.toStringAsFixed(0)
                                : '-- --',
                            target: '8,000',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: _ConcentricRingsPainter(
                            s: s,
                            redProgress: (calories / goalCalories).clamp(
                              0.0,
                              1.0,
                            ),
                            blueProgress: (steps / goalSteps).clamp(0.0, 1.0),
                            greenProgress: (distance / goalDistance).clamp(
                              0.0,
                              1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class _ProgressMetric extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String target;

  const _ProgressMetric({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2 * s),
          child: Icon(icon, color: iconColor, size: 14 * s),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
              ),
              SizedBox(height: 2 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppStyles.bold18(s)),
                  Text(
                    ' / ',
                    style: AppStyles.reg14(
                      s,
                    ).copyWith(color: AppColors.labelDim),
                  ),
                  Text(
                    target,
                    style: AppStyles.reg14(
                      s,
                    ).copyWith(color: AppColors.labelDim),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double s;
  final double redProgress;
  final double blueProgress;
  final double greenProgress;

  _ConcentricRingsPainter({
    required this.s,
    required this.redProgress,
    required this.blueProgress,
    required this.greenProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 14 * s;

    // Rings from outer to inner
    _drawRing(
      canvas,
      center,
      radius - strokeWidth / 2,
      Colors.red,
      redProgress,
      strokeWidth,
      Icons.local_fire_department_rounded,
    );
    _drawRing(
      canvas,
      center,
      radius - strokeWidth * 2.0,
      Colors.blueAccent,
      blueProgress,
      strokeWidth,
      Icons.directions_run_rounded,
    );
    _drawRing(
      canvas,
      center,
      radius - strokeWidth * 3.5,
      Colors.greenAccent,
      greenProgress,
      strokeWidth,
      Icons.location_on_rounded,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double progress,
    double strokeWidth,
    IconData icon,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Background track
    paint.color = color.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    // Opacity logic: minimum 0.3, maximum 1.0
    final double opacity = 0.3 + (0.7 * progress);
    paint.color = color.withValues(alpha: opacity);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Draw small icon at start
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: strokeWidth * 0.7,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - radius - iconPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Activity Tabs ────────────────────────────────────────────────────────────
class ActivityTabs extends StatelessWidget {
  final double s;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const ActivityTabs({
    super.key,
    required this.s,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {'label': 'All', 'icon': Icons.grid_view_rounded},
      {'label': 'Walking', 'icon': Icons.directions_walk_rounded},
      {'label': 'Running', 'icon': Icons.directions_run_rounded},
      {'label': 'Cycling', 'icon': Icons.directions_bike_rounded},
      {'label': 'Workout', 'icon': Icons.fitness_center_rounded},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(tabs.length, (i) {
        final active = i == activeIndex;
        return GestureDetector(
          onTap: () => onTabSelected(i),
          child: Column(
            children: [
              Container(
                width: 48 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: active ? null : const Color(0xFF2C3E4A),
                ),
                child: Icon(
                  tabs[i]['icon'],
                  color: active ? Colors.white : AppColors.labelDim,
                  size: 24 * s,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                tabs[i]['label'],
                style: AppStyles.reg10(s).copyWith(
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? Colors.white : AppColors.labelDim,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Latest Activity Card ──────────────────────────────────────────────────────
class LatestActivityCard extends StatelessWidget {
  final double s;
  final VoidCallback? onTap;

  const LatestActivityCard({super.key, required this.s, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 16 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: Container(
            color: const Color(0xFF16212B),
            padding: EdgeInsets.all(16 * s),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/fonts/person_run.png',
                      width: 50 * s,
                      height: 50 * s,
                      color: AppColors.cyan,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.directions_run_rounded,
                        size: 50 * s,
                        color: AppColors.cyan,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Running', style: AppStyles.semi14(s)),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Start   6:30 AM',
                                        style: AppStyles.reg10(s),
                                      ),
                                      Text(
                                        'Finish   7:30 AM',
                                        style: AppStyles.reg10(s),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8 * s),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.cyan,
                                    size: 20 * s,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                const Divider(color: Color(0xFF2C3E4A), height: 1),
                SizedBox(height: 12 * s),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActivityStat(
                          s: s,
                          label: '6 min/km',
                          sub: 'Pace',
                        ),
                      ),
                      const VerticalDivider(
                        color: Color(0xFF2C3E4A),
                        thickness: 1,
                      ),
                      Expanded(
                        child: _ActivityStat(
                          s: s,
                          label: '1,200 KM',
                          sub: 'Distance',
                        ),
                      ),
                      const VerticalDivider(
                        color: Color(0xFF2C3E4A),
                        thickness: 1,
                      ),
                      Expanded(
                        child: _ActivityStat(
                          s: s,
                          label: '285 Kcal',
                          sub: 'Calories',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final double s;
  final String label;
  final String sub;

  const _ActivityStat({
    required this.s,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppStyles.semi12(s)),
        Text(
          sub,
          style: AppStyles.reg10(s).copyWith(color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ── Recovery Data Button ────────────────────────────────────────────────────
class RecoveryDataButton extends StatelessWidget {
  final VoidCallback? onTap;

  const RecoveryDataButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / AppConstants.figmaW;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 300 * s,
          height: 60 * s,
          child: CustomPaint(
            painter: SmoothGradientBorder(radius: 30 * s),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30 * s),
              child: Container(
                color: const Color(0xFF060E16).withValues(alpha: .8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Recovery Data', style: AppStyles.lemon14(s)),
                    SizedBox(width: 8 * s),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.cyan,
                      size: 24 * s,
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

// ── Health Metric Card ────────────────────────────────────────────────────────
class HealthMetricCard extends StatelessWidget {
  final double s;
  final String title;
  final String value;
  final String? unit;
  final String? trend;
  final Color trendColor;
  final VoidCallback? onTap;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.s,
    this.unit,
    this.trend,
    this.trendColor = Colors.green,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 20 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Container(
            color: const Color(0xFF060E16).withOpacity(0.8),
            padding: EdgeInsets.all(16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppStyles.lemon10(
                        s,
                      ).copyWith(color: AppColors.labelDim, letterSpacing: 0.5),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.cyan,
                      size: 16 * s,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: AppStyles.bold22(s)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (unit != null)
                          Text(
                            unit!,
                            style: AppStyles.reg10(
                              s,
                            ).copyWith(color: AppColors.labelDim),
                          ),
                        if (trend != null)
                          Text(
                            trend!,
                            style: AppStyles.bold10(
                              s,
                            ).copyWith(color: trendColor),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

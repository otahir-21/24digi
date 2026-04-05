import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../bracelet/bracelet_dashboard_typography.dart';
import '../../bracelet/data/bracelet_data_parser.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../painters/smooth_gradient_border.dart';

// ── Bracelet health grid (dashboard) ───────────────────────────────────────────
abstract class BraceletDashboardColors {
  static const Color screenBg = Color(0xFF080E18);
  static const Color cardFill = Color(0xFF0F1923);
  /// Primary metric value — bright cyan (matches border start).
  static const Color valueCyan = Color(0xFF00F0FF);
  /// Unit / sub-label — muted blue-grey (readable on dark cards).
  static const Color labelGrey = Color(0xFF94A3B8);
  static const Color chevronCyan = Color(0xFF00F0FF);
  /// Card border & icon gradients: cyan → teal → magenta.
  static const Color borderCyan = Color(0xFF00F0FF);
  static const Color borderTeal = Color(0xFF00B4C8);
  static const Color borderMagenta = Color(0xFFD946EF);
}

/// Cards are portrait — aspect ratio and specs match the screenshot design.
abstract class BraceletMetricTileSpec {
  static const double gridAspectWidthOverHeight = 1.4;
  static double gridGap(double s) => 12 * s;
  static double cardRadius(double s) => 18 * s;
  static EdgeInsets cardPadding(double s) => EdgeInsets.all(10 * s);
  static double iconBox(double s) => 28 * s;
}

/// Gradient border: bright cyan (top-left) → teal → vivid magenta (bottom-right).
class BraceletMetricCardBorderPainter extends CustomPainter {
  BraceletMetricCardBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          BraceletDashboardColors.borderCyan,
          BraceletDashboardColors.borderTeal,
          BraceletDashboardColors.borderMagenta,
        ],
        stops: [0.0, 0.48, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant BraceletMetricCardBorderPainter old) =>
      old.radius != radius;
}

// ── Progress Card ─────────────────────────────────────────────────────────────
class ProgressCard extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;
  final VoidCallback? onTap;

  const ProgressCard({super.key, required this.s, this.liveData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final flat = liveData == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(liveData!);
    final calories =
        BraceletDataParser.coalesceCaloriesFromMap(flat) ??
        _toDouble(liveData?['calories']) ??
        0;
    final steps =
        BraceletDataParser.coalesceStepFromMap(flat) ??
        _toInt(liveData?['step']) ??
        0;
    final distanceRaw =
        BraceletDataParser.coalesceDistanceFromMap(flat) ??
        _toDouble(liveData?['distance']) ??
        _toDouble(liveData?['Distance']) ??
        _toDouble(liveData?['totalDistance']) ??
        _toDouble(liveData?['TotalDistance']) ??
        _toDouble(liveData?['distanceMeters']) ??
        _toDouble(liveData?['DistanceMeters']) ??
        _toDouble(liveData?['mileage']);
    // Device often sends distance in meters; if value is large assume meters and convert to km for display.
    final distance = distanceRaw == null
        ? 0.0
        : (distanceRaw > 100 ? distanceRaw / 1000.0 : distanceRaw);

    final goalCalories = 800.0;
    final goalSteps = 10000.0;
    final goalDistance = 8.0; // km (display unit after conversion)

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 20 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Container(
            color: const Color(0xFF060E16).withValues(alpha: 0.85),
            padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 18 * s),
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
                    SizedBox(width: 16 * s),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
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
                            icon: Icons.location_on_rounded,
                            iconColor: Colors.green,
                            label: 'DISTANCE (km)',
                            value: distance > 0
                                ? distance.toStringAsFixed(2)
                                : '-- --',
                            target: '8,000',
                          ),
                        ],
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
                width: 46 * s,
                height: 46 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * s),
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: active ? null : const Color(0xFF1E2D3A),
                ),
                child: Icon(
                  tabs[i]['icon'] as IconData,
                  color: active ? Colors.white : AppColors.labelDim,
                  size: 22 * s,
                ),
              ),
              SizedBox(height: 5 * s),
              Text(
                tabs[i]['label'] as String,
                style: BraceletDashboardTypography.text(
                  fontSize: 10 * s,
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
  final Map<String, dynamic>? latestActivity;
  final VoidCallback? onTap;

  const LatestActivityCard({
    super.key,
    required this.s,
    this.latestActivity,
    this.onTap,
  });

  static String _computeFinishTime(String? dateStr, int? activeMin) {
    if (dateStr == null || dateStr.isEmpty || activeMin == null || activeMin <= 0) {
      return '—';
    }
    try {
      final parts = dateStr.split(' ');
      if (parts.length < 2) return '—';
      final datePart = parts[0].replaceAll('.', '-');
      final timePart = parts[1];
      final dt = DateTime.tryParse('$datePart $timePart');
      if (dt == null) return '—';
      final finish = dt.add(Duration(minutes: activeMin));
      final hour = finish.hour;
      final min = finish.minute;
      final am = hour < 12;
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${h.toString().padLeft(2)}:${min.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
    } catch (_) {
      return '—';
    }
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    // e.g. "2025.03.01 06:30:00" or "2025-03-01 06:30"
    final parts = dateStr.split(' ');
    if (parts.length >= 2) {
      final timePart = parts[1];
      final colon = timePart.indexOf(':');
      if (colon >= 0) {
        final hour = int.tryParse(timePart.substring(0, colon)) ?? 0;
        final rest = timePart.length > colon + 1 ? timePart.substring(colon + 1) : '';
        final nextColon = rest.indexOf(':');
        final min = nextColon >= 0
            ? int.tryParse(rest.substring(0, nextColon))
            : int.tryParse(rest);
        final am = hour < 12;
        final h = hour <= 12 ? (hour == 0 ? 12 : hour) : hour - 12;
        return '${h.toString().padLeft(2)}:${(min ?? 0).toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
      }
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final act = latestActivity;
    final hasData = act != null &&
        (act['sportName'] != null ||
            act['activeMinutes'] != null ||
            act['step'] != null);

    final sportName = act?['sportName'] as String? ?? 'Activity';
    final dateStr = act?['date'] as String?;
    final activeMin = act?['activeMinutes'] as int?;
    final pace = act?['pace'] as String? ?? '—';
    final distance = act?['distance'];
    final distStr = distance != null
        ? (distance is num
            ? (distance as num) >= 1
                ? '${(distance as num).toStringAsFixed(2)} km'
                : '${((distance as num) * 1000).toStringAsFixed(0)} m'
            : distance.toString())
        : '—';
    final calories = act?['calories'];
    final calStr = calories != null
        ? (calories is num ? '${(calories as num).round()} Kcal' : calories.toString())
        : '—';
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 18 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18 * s),
          child: Container(
            color: const Color(0xFF111D28),
            padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 14 * s),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52 * s,
                      height: 52 * s,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14 * s),
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        size: 30 * s,
                        color: AppColors.cyan,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasData ? sportName : 'No recent activity',
                            style: BraceletDashboardTypography.text(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (hasData) ...[
                                _TimeColumn(
                                  s: s,
                                  label: 'Start',
                                  time: _formatDate(dateStr),
                                ),
                                SizedBox(width: 14 * s),
                                _TimeColumn(
                                  s: s,
                                  label: 'Finish',
                                  time: _computeFinishTime(dateStr, activeMin),
                                ),
                                SizedBox(width: 6 * s),
                              ] else
                                Text(
                                  'Sync to see latest',
                                  style: BraceletDashboardTypography.text(
                                    fontSize: 10 * s,
                                    color: AppColors.labelDim,
                                  ),
                                ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.cyan,
                                size: 22 * s,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Divider(
                  color: const Color(0xFF1E2D3A),
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 12 * s),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActivityStat(s: s, label: pace, sub: 'Pace'),
                      ),
                      VerticalDivider(
                        color: const Color(0xFF1E2D3A),
                        thickness: 1,
                        width: 1,
                      ),
                      Expanded(
                        child: _ActivityStat(s: s, label: distStr, sub: 'Distance'),
                      ),
                      VerticalDivider(
                        color: const Color(0xFF1E2D3A),
                        thickness: 1,
                        width: 1,
                      ),
                      Expanded(
                        child: _ActivityStat(s: s, label: calStr, sub: 'Calories'),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: BraceletDashboardTypography.text(
            fontSize: 12 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2 * s),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: BraceletDashboardTypography.text(
            fontSize: 10 * s,
            fontWeight: FontWeight.w400,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final double s;
  final String label;
  final String time;

  const _TimeColumn({
    required this.s,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: BraceletDashboardTypography.text(
            fontSize: 10 * s,
            fontWeight: FontWeight.w400,
            color: AppColors.labelDim,
          ),
        ),
        Text(
          time,
          style: BraceletDashboardTypography.text(
            fontSize: 11 * s,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
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
    final s = AppConstants.scale(context);

    return GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: SmoothGradientBorder(radius: 16 * s),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16 * s),
            child: Container(
              height: 56 * s,
              color: const Color(0xFF060E16).withValues(alpha: .8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Recovery Data', style: AppStyles.lemon14(s)),
                  SizedBox(width: 8 * s),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.cyan,
                    size: 22 * s,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

// ── Health Metric Card (bracelet dashboard grid) ─────────────────────────────
class HealthMetricCard extends StatelessWidget {
  final double s;
  final String title;
  final String value;
  final String? unit;
  final String? secondaryValue;
  final Color? secondaryColor;
  /// SVG or raster (e.g. PNG) under [assets/bracelet/metrics/] or [assets/BracletIcons/].
  final String iconAsset;
  /// Figma: Blood Pressure title wraps to two lines; others stay one line.
  final int titleMaxLines;
  final VoidCallback? onTap;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.s,
    required this.iconAsset,
    this.unit,
    this.secondaryValue,
    this.secondaryColor,
    this.titleMaxLines = 1,
    this.onTap,
  });

  bool get _iconIsRaster {
    final p = iconAsset.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.webp');
  }

  Widget _metricIcon({required double box}) {
    final w = box;
    final h = box;
    if (_iconIsRaster) {
      return Image.asset(
        iconAsset,
        width: w,
        height: h,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }
    final picture = SvgPicture.asset(
      iconAsset,
      width: w,
      height: h,
      fit: BoxFit.contain,
    );
    // Cyan → magenta to match card border (line-art SVGs).
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          BraceletDashboardColors.borderCyan,
          BraceletDashboardColors.borderMagenta,
        ],
      ).createShader(bounds),
      child: picture,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = BraceletMetricTileSpec.cardRadius(s);
    final pad = BraceletMetricTileSpec.cardPadding(s);
    final iconBox = BraceletMetricTileSpec.iconBox(s);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: CustomPaint(
          painter: BraceletMetricCardBorderPainter(radius: r),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r),
            child: Container(
              color: BraceletDashboardColors.cardFill,
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── Title + chevron ────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          maxLines: titleMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: BraceletDashboardTypography.text(
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            height: 1.15,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: BraceletDashboardColors.chevronCyan,
                        size: 17 * s,
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  // ── Large value ────────────────────────────────────────
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: BraceletDashboardTypography.text(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        color: BraceletDashboardColors.valueCyan,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // ── Spacer fills remaining space ───────────────────────
                  const Spacer(),
                  // ── Bottom: unit+secondary (left) | icon (right) ───────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (unit != null && unit!.isNotEmpty)
                              Text(
                                unit!,
                                style: BraceletDashboardTypography.text(
                                  fontSize: 11 * s,
                                  fontWeight: FontWeight.w400,
                                  color: BraceletDashboardColors.labelGrey,
                                  height: 1.25,
                                ),
                              ),
                            if (secondaryValue != null &&
                                secondaryValue!.isNotEmpty)
                              Text(
                                secondaryValue!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BraceletDashboardTypography.text(
                                  fontSize: 9.5 * s,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor ??
                                      BraceletDashboardColors.labelGrey,
                                  height: 1.25,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _metricIcon(box: iconBox),
                    ],
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

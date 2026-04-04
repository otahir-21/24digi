import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

/// A single row in the reference table (e.g. "60–100 BPM → Normal").
class HealthRange {
  final String range;
  final String label;
  final Color color;
  final IconData icon;

  const HealthRange({
    required this.range,
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Full descriptor for one health metric shown in the bottom sheet.
class HealthMetricInfo {
  final String title;
  final String unit;
  final IconData icon;
  final String whatItMeans;     // 1–2 sentences explaining the metric
  final String whyItMatters;    // 1 sentence on why users should care
  final List<HealthRange> ranges;
  final String source;          // e.g. "WHO / AHA guidelines"

  const HealthMetricInfo({
    required this.title,
    required this.unit,
    required this.icon,
    required this.whatItMeans,
    required this.whyItMatters,
    required this.ranges,
    required this.source,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Pre-built descriptors for each metric
// ─────────────────────────────────────────────────────────────────────────────

class HealthMetrics {
  HealthMetrics._();

  static const stress = HealthMetricInfo(
    title: 'Stress Index',
    unit: '/ 100',
    icon: Icons.psychology_rounded,
    whatItMeans:
        'Your stress index is a 0–100 score calculated from heart rate variability (HRV) '
        'and heart rate patterns. A higher score means your body is showing more physiological '
        'signs of stress.',
    whyItMatters:
        'Chronic high stress is linked to poor sleep, weakened immunity, and cardiovascular risk.',
    ranges: [
      HealthRange(range: '0 – 32',  label: 'Low — Relaxed',        color: Color(0xFF4CAF50), icon: Icons.sentiment_very_satisfied_rounded),
      HealthRange(range: '33 – 65', label: 'Medium — Normal',       color: Color(0xFFFFEB3B), icon: Icons.sentiment_neutral_rounded),
      HealthRange(range: '66 – 100',label: 'High — Stressed',       color: Color(0xFFE53935), icon: Icons.sentiment_very_dissatisfied_rounded),
    ],
    source: 'Based on HRV-derived stress algorithms',
  );

  static const spo2 = HealthMetricInfo(
    title: 'Blood Oxygen (SpO₂)',
    unit: '%',
    icon: Icons.air_rounded,
    whatItMeans:
        'SpO₂ measures the percentage of hemoglobin in your blood that is carrying oxygen. '
        'It reflects how efficiently your lungs are delivering oxygen to your body.',
    whyItMatters:
        'Low SpO₂ can indicate breathing problems, sleep apnea, or cardiovascular issues.',
    ranges: [
      HealthRange(range: '≥ 95 %',  label: 'Normal',                color: Color(0xFF4CAF50), icon: Icons.check_circle_rounded),
      HealthRange(range: '91–94 %', label: 'Mild Hypoxemia',         color: Color(0xFFFFEB3B), icon: Icons.warning_rounded),
      HealthRange(range: '86–90 %', label: 'Moderate Hypoxemia',     color: Color(0xFFFF9800), icon: Icons.warning_amber_rounded),
      HealthRange(range: '< 86 %',  label: 'Severe — Seek help',     color: Color(0xFFE53935), icon: Icons.emergency_rounded),
    ],
    source: 'WHO / American Thoracic Society',
  );

  static const heartRate = HealthMetricInfo(
    title: 'Heart Rate',
    unit: 'BPM',
    icon: Icons.favorite_rounded,
    whatItMeans:
        'Your resting heart rate is the number of times your heart beats per minute while '
        'you are at rest. It is one of the most important indicators of cardiovascular health.',
    whyItMatters:
        'A lower resting heart rate generally means a stronger, more efficient heart.',
    ranges: [
      HealthRange(range: '< 60 BPM',   label: 'Low (Bradycardia)',    color: Color(0xFF43C6E4), icon: Icons.arrow_downward_rounded),
      HealthRange(range: '60–100 BPM', label: 'Normal',               color: Color(0xFF4CAF50), icon: Icons.check_circle_rounded),
      HealthRange(range: '101–120 BPM',label: 'Slightly Elevated',    color: Color(0xFFFFEB3B), icon: Icons.warning_rounded),
      HealthRange(range: '> 120 BPM',  label: 'High (Tachycardia)',   color: Color(0xFFE53935), icon: Icons.emergency_rounded),
    ],
    source: 'WHO / American Heart Association',
  );

  static const temperature = HealthMetricInfo(
    title: 'Body Temperature',
    unit: '°C',
    icon: Icons.thermostat_rounded,
    whatItMeans:
        'Body temperature reflects your internal heat regulation. It varies slightly '
        'during the day and with activity, but a consistent reading outside normal range '
        'may indicate illness.',
    whyItMatters:
        'Fever is often the first sign of infection. Hypothermia can be dangerous if untreated.',
    ranges: [
      HealthRange(range: '< 36.0 °C',    label: 'Low (Hypothermia)',    color: Color(0xFF43C6E4), icon: Icons.arrow_downward_rounded),
      HealthRange(range: '36.0–37.2 °C', label: 'Normal',               color: Color(0xFF4CAF50), icon: Icons.check_circle_rounded),
      HealthRange(range: '37.3–38.0 °C', label: 'Low-grade Fever',      color: Color(0xFFFFEB3B), icon: Icons.warning_rounded),
      HealthRange(range: '> 38.0 °C',    label: 'Fever',                color: Color(0xFFE53935), icon: Icons.local_fire_department_rounded),
    ],
    source: 'WHO / Mayo Clinic guidelines',
  );

  static const hrv = HealthMetricInfo(
    title: 'Heart Rate Variability',
    unit: 'ms',
    icon: Icons.ssid_chart_rounded,
    whatItMeans:
        'HRV measures the variation in time between consecutive heartbeats. '
        'A higher HRV indicates that your autonomic nervous system is well-balanced '
        'and your body is recovering well.',
    whyItMatters:
        'Low HRV over time is associated with stress, fatigue, and increased disease risk.',
    ranges: [
      HealthRange(range: '> 50 ms',  label: 'Excellent',              color: Color(0xFF4CAF50), icon: Icons.star_rounded),
      HealthRange(range: '30–50 ms', label: 'Good',                   color: Color(0xFF8BC34A), icon: Icons.check_circle_rounded),
      HealthRange(range: '20–29 ms', label: 'Average',                color: Color(0xFFFFEB3B), icon: Icons.warning_rounded),
      HealthRange(range: '< 20 ms',  label: 'Low — Rest & recover',   color: Color(0xFFE53935), icon: Icons.hotel_rounded),
    ],
    source: 'Based on published HRV research (varies by age)',
  );

  static const bloodPressure = HealthMetricInfo(
    title: 'Blood Pressure',
    unit: 'mmHg',
    icon: Icons.monitor_heart_rounded,
    whatItMeans:
        'Blood pressure is the force of blood pushing against artery walls. '
        'It is recorded as systolic (when the heart beats) over diastolic (between beats).',
    whyItMatters:
        'High blood pressure (hypertension) is a major risk factor for heart attack and stroke.',
    ranges: [
      HealthRange(range: '< 90 / < 60',      label: 'Low (Hypotension)',    color: Color(0xFF43C6E4), icon: Icons.arrow_downward_rounded),
      HealthRange(range: '< 120 / < 80',     label: 'Normal',               color: Color(0xFF4CAF50), icon: Icons.check_circle_rounded),
      HealthRange(range: '120–129 / < 80',   label: 'Elevated',             color: Color(0xFFFFEB3B), icon: Icons.warning_rounded),
      HealthRange(range: '130–139 / 80–89',  label: 'High — Stage 1',       color: Color(0xFFFF9800), icon: Icons.warning_amber_rounded),
      HealthRange(range: '≥ 140 / ≥ 90',    label: 'High — Stage 2',       color: Color(0xFFE53935), icon: Icons.emergency_rounded),
    ],
    source: 'WHO / American Heart Association 2017',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the health info bottom sheet for [info].
/// [currentValue] is the user's live reading as a display string (e.g. "72", "98%").
/// [currentRangeIndex] is the 0-based index into [info.ranges] that the current
/// value falls into (-1 if no data).
void showHealthInfoSheet(
  BuildContext context,
  HealthMetricInfo info, {
  String? currentValue,
  int currentRangeIndex = -1,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HealthInfoSheet(
      info: info,
      currentValue: currentValue,
      currentRangeIndex: currentRangeIndex,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _HealthInfoSheet extends StatelessWidget {
  final HealthMetricInfo info;
  final String? currentValue;
  final int currentRangeIndex;

  const _HealthInfoSheet({
    required this.info,
    this.currentValue,
    this.currentRangeIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final activeColor = currentRangeIndex >= 0
        ? info.ranges[currentRangeIndex].color
        : AppColors.cyan;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1822),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 32 * s),
          children: [
            // ── drag handle ─────────────────────────────────────────────
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12 * s, bottom: 20 * s),
                width: 40 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
            ),

            // ── header ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10 * s),
                  decoration: BoxDecoration(
                    color: activeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(14 * s),
                  ),
                  child: Icon(info.icon, color: activeColor, size: 26 * s),
                ),
                SizedBox(width: 14 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Measured in ${info.unit}',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * s),

            // ── current reading banner ───────────────────────────────────
            if (currentValue != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 14 * s,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withAlpha(22),
                  border: Border.all(color: activeColor.withAlpha(80)),
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                child: Row(
                  children: [
                    Icon(Icons.watch_rounded, color: activeColor, size: 20 * s),
                    SizedBox(width: 10 * s),
                    Text(
                      'Your reading: ',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                    Text(
                      '$currentValue ${info.unit}',
                      style: GoogleFonts.inter(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w700,
                        color: activeColor,
                      ),
                    ),
                    const Spacer(),
                    if (currentRangeIndex >= 0) ...[
                      Icon(
                        info.ranges[currentRangeIndex].icon,
                        color: activeColor,
                        size: 18 * s,
                      ),
                      SizedBox(width: 6 * s),
                      Text(
                        info.ranges[currentRangeIndex].label.split('—').last.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20 * s),
            ],

            // ── what it means ────────────────────────────────────────────
            _SectionHeader(s: s, label: 'WHAT IS THIS?'),
            SizedBox(height: 8 * s),
            Text(
              info.whatItMeans,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white.withAlpha(210),
                height: 1.6,
              ),
            ),
            SizedBox(height: 6 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded,
                    color: AppColors.cyan, size: 14 * s),
                SizedBox(width: 6 * s),
                Expanded(
                  child: Text(
                    info.whyItMatters,
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: AppColors.cyan.withAlpha(200),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24 * s),

            // ── reference ranges ─────────────────────────────────────────
            _SectionHeader(s: s, label: 'REFERENCE RANGES'),
            SizedBox(height: 10 * s),
            ...List.generate(info.ranges.length, (i) {
              final r = info.ranges[i];
              final isActive = i == currentRangeIndex;
              return Container(
                margin: EdgeInsets.only(bottom: 8 * s),
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 12 * s,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? r.color.withAlpha(28)
                      : Colors.white.withAlpha(6),
                  border: Border.all(
                    color: isActive
                        ? r.color.withAlpha(120)
                        : Colors.white.withAlpha(15),
                    width: isActive ? 1.2 : 0.8,
                  ),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Row(
                  children: [
                    Icon(r.icon, color: r.color, size: 18 * s),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.label,
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive ? r.color : Colors.white,
                            ),
                          ),
                          Text(
                            r.range,
                            style: GoogleFonts.inter(
                              fontSize: 11 * s,
                              color: AppColors.labelDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * s,
                          vertical: 3 * s,
                        ),
                        decoration: BoxDecoration(
                          color: r.color.withAlpha(40),
                          borderRadius: BorderRadius.circular(20 * s),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.inter(
                            fontSize: 9 * s,
                            fontWeight: FontWeight.w800,
                            color: r.color,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            SizedBox(height: 20 * s),

            // ── source & disclaimer ──────────────────────────────────────
            Container(
              padding: EdgeInsets.all(12 * s),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(6),
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppColors.cyan, size: 13 * s),
                      SizedBox(width: 5 * s),
                      Text(
                        'Source: ${info.source}',
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    'For informational purposes only. These ranges are general guidelines. '
                    'Always consult a healthcare professional for medical advice.',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: AppColors.labelDim,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final double s;
  final String label;
  const _SectionHeader({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10 * s,
        fontWeight: FontWeight.w700,
        color: AppColors.labelDim,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// A small circular info button for the top bar actions list.
class HealthInfoButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? size;

  const HealthInfoButton({super.key, required this.onTap, this.size});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: AppColors.cyan.withAlpha(30),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: AppColors.cyan.withAlpha(150), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.cyan, size: 15 * s),
            SizedBox(width: 4 * s),
            Text(
              'Info',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: unused_element, unnecessary_underscores

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_metrics_cache.dart';
import '../../bracelet/hydration_activity_adjustment.dart';
import '../../bracelet/recovery/recovery_score_calculator.dart';
import '../../bracelet/recovery/recovery_storage.dart';
import '../../bracelet/sleep_storage.dart';
import '../../bracelet/weekly_data_storage.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'bracelet_scaffold.dart';

String _nervousSystemValueLabel(int? stress, int? hrv) {
  if (stress != null) {
    if (stress >= 70) return 'High load';
    if (stress >= 45) return 'Moderate';
    return 'Lower load';
  }
  if (hrv != null && hrv > 0) return hrv >= 45 ? 'Calm' : 'Active';
  return '—';
}

String _nervousSystemSubtitle(int? stress, int? hrv, int? hr) {
  if (stress != null) {
    return 'Stress index $stress/100 from bracelet';
  }
  if (hrv != null && hrv > 0) {
    return 'HRV $hrv ms — sync for stress when available';
  }
  if (hr != null) {
    return 'HR $hr bpm — open bracelet home to sync HRV/stress';
  }
  return 'Connect band or open dashboard to populate';
}

String _tissueRepairLabel(int score, int? spo2) {
  if (spo2 != null && spo2 > 0 && spo2 < 94) return 'Watch';
  if (score >= 85) return 'Peak';
  if (score >= 60) return 'Building';
  return 'Recovering';
}

String _tissueRepairSubtitle(int score, int? spo2) {
  if (spo2 != null && spo2 > 0 && spo2 < 94) {
    return 'SpO₂ $spo2% — verify reading & rest if symptomatic';
  }
  return score >= 85
      ? 'Recovery score supports training load'
      : 'Prioritize sleep before hard sessions';
}

// ─────────────────────────────────────────────────────────────────────────────
// GeneralRecoveryScreen
// ─────────────────────────────────────────────────────────────────────────────
class GeneralRecoveryScreen extends StatelessWidget {
  const GeneralRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    // Recovery score: sleep + HRV + bracelet HR/stress + yesterday load (from band / storage).
    final steps = WeeklyDataStorage.last7DaysSteps;
    final hr = BraceletChannel.lastKnownHeartRate;
    final stress = BraceletChannel.lastKnownStress;
    final input = RecoveryInput(
      totalSleepMinutes: SleepStorage.totalSleepMinutes,
      hrv: BraceletChannel.lastKnownHrv,
      restingHeartRate: hr,
      stress: stress,
      yesterdaySteps: steps.length >= 6 ? steps[5] : null,
      hrvHistoryLast7Days: null,
      restingHeartRateHistoryLast7Days: null,
    );
    final result = RecoveryScoreCalculator.calculate(input);
    // Persist today's snapshot so trend chart has data (in-memory; add prefs/DB later).
    RecoveryStorage.save(
      RecoverySnapshot(
        date: DateTime.now(),
        score: result.score,
        status: result.status,
        reasons: result.reasons,
        recordedAt: DateTime.now(),
      ),
    );

    final sleepTotal = SleepStorage.totalSleepMinutes ?? 0;
    final sleepTarget = 8 * 60;
    final sleepPercent = ((sleepTotal / sleepTarget) * 100)
        .clamp(0.0, 100.0)
        .round();
    final deep =
        (SleepStorage.lastSleepData?['deepMinutes'] as num?)?.toInt() ?? 0;
    final rem =
        (SleepStorage.lastSleepData?['remMinutes'] as num?)?.toInt() ?? 0;
    final inBedRaw =
        (SleepStorage.lastSleepData?['inBedDurationMinutes'] as num?)?.toInt();
    final inBed = inBedRaw != null && inBedRaw > 0 ? inBedRaw : null;
    final circadian = ((sleepTotal / sleepTarget) * 100)
        .clamp(0.0, 100.0)
        .round();
    final deepPct = sleepTotal > 0 ? (deep / sleepTotal) : 0.0;
    final remPct = sleepTotal > 0 ? (rem / sleepTotal) : 0.0;
    final hrv = BraceletChannel.lastKnownHrv;
    final spo2 = BraceletChannel.lastKnownSpo2;
    final skinTemp = BraceletChannel.lastKnownTemperature;

    final totals = BraceletMetricsCache.instance.todayTotals;
    final todayStepsForHydration = steps.length >= 7 ? steps[6] : null;
    final hydrationMap = <String, dynamic>{
      if (todayStepsForHydration != null) 'steps': todayStepsForHydration,
      if (totals != null && totals['calories'] != null)
        'calories': totals['calories'],
      if (hrv != null) 'hrv': hrv,
      if (hr != null) 'heartRate': hr,
      if (stress != null) 'stress': stress,
      if (skinTemp != null) 'temperature': skinTemp,
      if (spo2 != null) 'spo2': spo2,
    };
    final braceletHydrationIdx =
        HydrationActivityAdjustment.braceletHydrationIndexPercent(hydrationMap);
    final fluidValueStr =
        braceletHydrationIdx != null ? '$braceletHydrationIdx%' : '—';
    final fluidStatus = braceletHydrationIdx == null
        ? 'Sync bracelet'
        : (braceletHydrationIdx >= 70 ? 'Favorable' : 'Prioritize fluids');
    final sleepEfficiencyPct = (inBed != null && inBed > 0)
        ? ((sleepTotal / inBed) * 100).round().clamp(0, 100)
        : null;
    final consistency = RecoveryStorage.last7DaysScores
        .whereType<int>()
        .toList();
    final avg7 = consistency.isEmpty
        ? result.score
        : (consistency.reduce((a, b) => a + b) / consistency.length).round();

    return BraceletScaffold(
      customTopBar: const DigiPillHeader(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'RECOVERY DASHBOARD',
              style: GoogleFonts.outfit(
                fontSize: 10 * s,
                color: Colors.white30,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          _RecoveryHeroSection(
            s: s,
            score: result.score,
            status: result.status,
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'What\'s Contributing'),
          SizedBox(height: 10 * s),
          _ContributorsSection(
            s: s,
            restorativeSleepPct: sleepPercent,
            nervousSystemLabel: _nervousSystemValueLabel(stress, hrv),
            nervousSystemSubtitle: _nervousSystemSubtitle(stress, hrv, hr),
            tissueRepairLabel: _tissueRepairLabel(result.score, spo2),
            tissueRepairSubtitle: _tissueRepairSubtitle(result.score, spo2),
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Sleep Analysis'),
          _SleepAnalysisSection(
            s: s,
            deepPct: deepPct,
            remPct: remPct,
            circadianPct: circadian / 100.0,
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Body Systems'),
          SizedBox(height: 10 * s),
          _BodySystemsSection(
            s: s,
            fluidValue: fluidValueStr,
            fluidStatus: fluidStatus,
            balancePct: sleepEfficiencyPct,
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Bracelet data'),
          SizedBox(height: 10 * s),
          _BraceletRecoveryVitalsCard(
            s: s,
            heartRate: hr,
            hrv: hrv,
            stress: stress,
            spo2: spo2,
            skinTempC: skinTemp,
          ),
          SizedBox(height: 10 * s),
          _EveningWindDownCard(s: s),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Recovery Consistency'),
          SizedBox(height: 10 * s),
          _RecoveryConsistencyCard(s: s, average7d: avg7),
          SizedBox(height: 26 * s),
        ],
      ),
    );
  }
}

class _RecoveryHeroSection extends StatelessWidget {
  final double s;
  final int score;
  final String status;
  const _RecoveryHeroSection({
    required this.s,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00F0FF); // Design primary cyan
    final subtitle = score >= 85
        ? 'Your body has restored optimally'
        : 'Your body is recovering steadily';

    return Column(
      children: [
        Text(
          'Your Recovery',
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 18 * s),
        SizedBox(
          width: 190 * s,
          height: 190 * s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(190 * s, 190 * s),
                painter: _RingPainter(
                  progress: score / 100.0,
                  color: color,
                  s: s,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.outfit(
                      fontSize: 60 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '%',
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * s),
        Text(
          status == 'Excellent' || score >= 85
              ? 'Fully Recovered'
              : 'Recovery In Progress',
          style: GoogleFonts.outfit(
            fontSize: 28 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38),
        ),
      ],
    );
  }
}

class _ContributorsSection extends StatelessWidget {
  final double s;
  final int restorativeSleepPct;
  final String nervousSystemLabel;
  final String nervousSystemSubtitle;
  final String tissueRepairLabel;
  final String tissueRepairSubtitle;
  const _ContributorsSection({
    required this.s,
    required this.restorativeSleepPct,
    required this.nervousSystemLabel,
    required this.nervousSystemSubtitle,
    required this.tissueRepairLabel,
    required this.tissueRepairSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContribTile(
          s: s,
          icon: Icons.nights_stay_rounded,
          title: 'Restorative Sleep',
          subtitle: 'Primary recovery driver',
          value: '$restorativeSleepPct%',
          accentColor: const Color(0xFF00F0FF),
        ),
        SizedBox(height: 12 * s),
        _ContribTile(
          s: s,
          icon: Icons.favorite_rounded,
          title: 'Nervous System',
          subtitle: nervousSystemSubtitle,
          value: nervousSystemLabel,
          accentColor: const Color(0xFF00FF9C),
        ),
        SizedBox(height: 12 * s),
        _ContribTile(
          s: s,
          icon: Icons.bolt_rounded,
          title: 'Tissue Repair',
          subtitle: tissueRepairSubtitle,
          value: tissueRepairLabel,
          accentColor: const Color(0xFF00B2FF),
        ),
      ],
    );
  }
}

class _ContribTile extends StatelessWidget {
  final double s;
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color accentColor;
  const _ContribTile({
    required this.s,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * s),
              color: accentColor.withOpacity(0.1),
            ),
            child: Icon(icon, size: 22 * s, color: accentColor),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    color: Colors.white30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20 * s,
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepAnalysisSection extends StatelessWidget {
  final double s;
  final double deepPct;
  final double remPct;
  final double circadianPct;
  const _SleepAnalysisSection({
    required this.s,
    required this.deepPct,
    required this.remPct,
    required this.circadianPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _LineMetric(
            s: s,
            label: 'Deep Sleep',
            pct: deepPct.clamp(0.0, 1.0),
            quality: deepPct >= 0.20 ? 'Excellent' : 'Fair',
          ),
          SizedBox(height: 24 * s),
          _LineMetric(
            s: s,
            label: 'REM Sleep',
            pct: remPct.clamp(0.0, 1.0),
            quality: remPct >= 0.18 ? 'Good' : 'Low',
          ),
          SizedBox(height: 24 * s),
          _LineMetric(
            s: s,
            label: 'Circadian Alignment',
            pct: circadianPct.clamp(0.0, 1.0),
            quality: circadianPct >= 0.75 ? 'On Track' : 'Off Track',
            showBar: false,
          ),
        ],
      ),
    );
  }
}

class _LineMetric extends StatelessWidget {
  final double s;
  final String label;
  final double pct;
  final String quality;
  final bool showBar;
  const _LineMetric({
    required this.s,
    required this.label,
    required this.pct,
    required this.quality,
    this.showBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                color: Colors.white30,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              quality,
              style: GoogleFonts.outfit(
                fontSize: 16 * s,
                color:
                    quality == 'On Track' ||
                        quality == 'Excellent' ||
                        quality == 'Good'
                    ? const Color(0xFF00F0FF)
                    : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (showBar) ...[
          SizedBox(height: 12 * s),
          Stack(
            children: [
              Container(
                height: 6 * s,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3 * s),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6 * s,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B2FF), Color(0xFF00F0FF)],
                    ),
                    borderRadius: BorderRadius.circular(3 * s),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BodySystemsSection extends StatelessWidget {
  final double s;
  final String fluidValue;
  final String fluidStatus;
  final int? balancePct;
  const _BodySystemsSection({
    required this.s,
    required this.fluidValue,
    required this.fluidStatus,
    required this.balancePct,
  });

  @override
  Widget build(BuildContext context) {
    final eff = balancePct;
    final effStr = eff != null ? '$eff%' : '—';
    final effStatus = eff == null
        ? 'Need in-bed time'
        : (eff >= 85 ? 'Efficient' : eff >= 70 ? 'OK' : 'Fragmented');
    return Row(
      children: [
        Expanded(
          child: _BodySystemTile(
            s: s,
            label: 'Fluid index (band)',
            value: fluidValue,
            status: fluidStatus,
            color: const Color(0xFF00B2FF),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _BodySystemTile(
            s: s,
            label: 'Sleep efficiency',
            value: effStr,
            status: effStatus,
            color: const Color(0xFF00FF9C),
          ),
        ),
      ],
    );
  }
}

class _BodySystemTile extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final String status;
  final Color color;
  const _BodySystemTile({
    required this.s,
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              color: Colors.white30,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24 * s,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontSize: 12 * s,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live vitals persisted from the bracelet dashboard merge (same as health tiles).
class _BraceletRecoveryVitalsCard extends StatelessWidget {
  final double s;
  final int? heartRate;
  final int? hrv;
  final int? stress;
  final int? spo2;
  final double? skinTempC;

  const _BraceletRecoveryVitalsCard({
    required this.s,
    this.heartRate,
    this.hrv,
    this.stress,
    this.spo2,
    this.skinTempC,
  });

  @override
  Widget build(BuildContext context) {
    final hasAny = heartRate != null ||
        hrv != null ||
        stress != null ||
        spo2 != null ||
        skinTempC != null;

    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest from bracelet',
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Values update when the band is connected or after you open the bracelet home screen.',
            style: GoogleFonts.outfit(
              fontSize: 11 * s,
              color: Colors.white30,
              height: 1.35,
            ),
          ),
          SizedBox(height: 16 * s),
          if (!hasAny)
            Text(
              'No vitals yet — connect your bracelet and sync.',
              style: GoogleFonts.outfit(
                fontSize: 13 * s,
                color: Colors.white38,
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _VitalCell(
                        s: s,
                        label: 'Heart rate',
                        value: heartRate != null ? '$heartRate' : '—',
                        unit: 'BPM',
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: _VitalCell(
                        s: s,
                        label: 'HRV',
                        value: hrv != null ? '$hrv' : '—',
                        unit: 'ms',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Row(
                  children: [
                    Expanded(
                      child: _VitalCell(
                        s: s,
                        label: 'Stress',
                        value: stress != null ? '$stress' : '—',
                        unit: '/100',
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: _VitalCell(
                        s: s,
                        label: 'SpO₂',
                        value: spo2 != null ? '$spo2' : '—',
                        unit: '%',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                _VitalCell(
                  s: s,
                  label: 'Skin temperature',
                  value: skinTempC != null
                      ? skinTempC!.toStringAsFixed(1)
                      : '—',
                  unit: '°C',
                  fullWidth: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _VitalCell extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final String unit;
  final bool fullWidth;

  const _VitalCell({
    required this.s,
    required this.label,
    required this.value,
    required this.unit,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (value != '—') ...[
                SizedBox(width: 4 * s),
                Text(
                  unit,
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    color: const Color(0xFF00F0FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EveningWindDownCard extends StatelessWidget {
  final double s;
  const _EveningWindDownCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evening Wind-Down',
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6 * s),
                ),
                child: Text(
                  'UP NEXT',
                  style: GoogleFonts.outfit(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFB300),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Row(
            children: [
              Container(
                width: 48 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Icon(
                  Icons.nights_stay_rounded,
                  color: const Color(0xFFCE6AFF),
                  size: 24 * s,
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EST. START 21:30',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00F0FF),
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'Recommended: Blue Light Shift',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14 * s),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCE6AFF), Color(0xFF6F35FF)],
              ),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Center(
              child: Text(
                'Prepare for Rest',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryConsistencyCard extends StatelessWidget {
  final double s;
  final int average7d;
  const _RecoveryConsistencyCard({required this.s, required this.average7d});

  @override
  Widget build(BuildContext context) {
    final scores = RecoveryStorage.last7DaysScores;
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][d.weekday - 1];
    });

    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Average',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$average7d%',
                style: GoogleFonts.outfit(
                  fontSize: 22 * s,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          SizedBox(
            height: 100 * s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final score =
                    (scores.length > i ? scores[i] : null) ?? average7d;
                final heightFactor = (score / 100.0).clamp(0.1, 1.0);
                final isToday = i == 6;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24 * s,
                      height: 70 * s * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF00F0FF),
                            const Color(
                              0xFF00F0FF,
                            ).withOpacity(isToday ? 0.3 : 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6 * s),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      dayLabels[i],
                      style: GoogleFonts.outfit(
                        fontSize: 9 * s,
                        color: isToday ? Colors.white : Colors.white24,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(padding: EdgeInsets.all(16 * s), child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pill (computed recovery: score + status)
// ─────────────────────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final double s;
  final RecoveryResult result;
  const _StatusPill({required this.s, required this.result});

  static Color _statusColor(String status) {
    switch (status) {
      case 'Excellent':
        return AppColors.cyan;
      case 'Good':
        return const Color(0xFF4ADE80);
      case 'Fair':
        return const Color(0xFFFBBF24);
      case 'Low':
        return const Color(0xFFF87171);
      default:
        return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(result.status);
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * s),
          color: const Color(0xFF060E16),
          border: Border.all(color: color.withAlpha(60), width: 1.2 * s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: color, size: 16 * s),
            SizedBox(width: 8 * s),
            Text(
              'RECOVERY: ${result.status.toUpperCase()} (${result.score})',
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chips for recovery reasons (e.g. "HRV above baseline", "Poor sleep duration").
class _RecoveryReasons extends StatelessWidget {
  final double s;
  final List<String> reasons;
  const _RecoveryReasons({required this.s, required this.reasons});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6 * s,
      runSpacing: 6 * s,
      children: reasons
          .map(
            (r) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8 * s),
                color: AppColors.cyan.withAlpha(25),
                border: Border.all(
                  color: AppColors.cyan.withAlpha(80),
                  width: 1,
                ),
              ),
              child: Text(
                r,
                style: GoogleFonts.inter(
                  fontSize: 9 * s,
                  color: AppColors.labelDim,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final double s;
  final String label;
  const _SectionHeader({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white30,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ReadyIndicator extends StatelessWidget {
  final double s;
  final RecoveryResult result;
  const _ReadyIndicator({required this.s, required this.result});

  /// Active bars 1–4 by status: Excellent=4, Good=3, Fair=2, Low=1.
  static int _activeBars(String status) {
    switch (status) {
      case 'Excellent':
        return 4;
      case 'Good':
        return 3;
      case 'Fair':
        return 2;
      case 'Low':
        return 1;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeBars(result.status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isActive = i < active;
        return Container(
          width: 38 * s,
          height: 6 * s,
          margin: EdgeInsets.symmetric(horizontal: 4 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10 * s),
            color: isActive ? AppColors.cyan : const Color(0xFF192A3A),
          ),
        );
      }),
    );
  }
}

// Removed duplicate header

// ─────────────────────────────────────────────────────────────────────────────
// Small badge pill
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final double s;
  final String label;
  final Color color;
  const _Badge({required this.s, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6 * s),
        color: color.withAlpha(30),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8 * s,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body Balance card
// ─────────────────────────────────────────────────────────────────────────────
class _BodyBalanceCard extends StatelessWidget {
  final double s;
  const _BodyBalanceCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.cyan, size: 16 * s),
              SizedBox(width: 4 * s),
              Text(
                'BODY BALANCE',
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  color: AppColors.labelDim,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            '92%',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 24 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            height: 30 * s,
            child: CustomPaint(
              painter: _MiniBarsPainter(
                values: [0.5, 0.7, 0.55, 0.85, 0.65, 0.92],
                color: AppColors.cyan,
                s: s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stress Index card
// ─────────────────────────────────────────────────────────────────────────────
class _StressIndexCard extends StatelessWidget {
  final double s;
  const _StressIndexCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/stress_icon.png',
                height: 16 * s,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.waves, color: AppColors.cyan, size: 16 * s),
              ),
              SizedBox(width: 6 * s),
              Text(
                'STRESS INDEX',
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  color: AppColors.labelDim,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            'LOW',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 22 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * s),
          Container(
            height: 22 * s,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2630),
              borderRadius: BorderRadius.circular(11 * s),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(11 * s),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Quality card
// ─────────────────────────────────────────────────────────────────────────────
class _SleepQualityCard extends StatelessWidget {
  final double s;
  const _SleepQualityCard({required this.s});

  static const _bars = [
    _SleepBar('REM', 0.55, Color(0xFFCE6AFF)),
    _SleepBar('LIGHT', 0.80, Color(0xFF00C8FF)),
    _SleepBar('DEEP', 0.65, Color(0xFF0050FF)),
    _SleepBar('AWAKE', 0.20, Color(0xFFFFB300)),
  ];

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: const Color(0xFFCE6AFF),
                    size: 18 * s,
                  ),
                  SizedBox(width: 8 * s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Quality',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Duration:',
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _Badge(s: s, label: 'Excellent', color: const Color(0xFF00FF9C)),
            ],
          ),
          SizedBox(height: 14 * s),

          // Sleep stage bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _bars
                .map((b) => _SleepStageBar(s: s, bar: b, maxH: 60 * s))
                .toList(),
          ),
          SizedBox(height: 10 * s),

          // Circadian alignment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Circadian Alignment',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: AppColors.labelDim,
                ),
              ),
              Text(
                '96%',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * s),
            child: Container(
              height: 5 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4 * s),
                color: AppColors.divider,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.96,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4 * s),
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.purple],
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

class _SleepBar {
  final String label;
  final double height;
  final Color color;
  const _SleepBar(this.label, this.height, this.color);
}

class _SleepStageBar extends StatelessWidget {
  final double s;
  final _SleepBar bar;
  final double maxH;
  const _SleepStageBar({
    required this.s,
    required this.bar,
    required this.maxH,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * s,
          height: maxH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4 * s),
            color: const Color(0xFF1C2735),
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: bar.height,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4 * s),
                color: bar.color,
                boxShadow: [
                  BoxShadow(color: bar.color.withAlpha(100), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          bar.label,
          style: GoogleFonts.inter(fontSize: 8 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hydration Recovery card
// ─────────────────────────────────────────────────────────────────────────────
class _HydrationRecoveryCard extends StatelessWidget {
  final double s;
  const _HydrationRecoveryCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hydration Recovery',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              _Badge(s: s, label: 'ON TRACK', color: AppColors.cyan),
            ],
          ),
          SizedBox(height: 4 * s),
          Text(
            'Goal: 2.5L Today',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: AppColors.labelDim,
            ),
          ),
          SizedBox(height: 12 * s),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ring with droplet icon + 70% badge
              SizedBox(
                width: 72 * s,
                height: 80 * s,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    CustomPaint(
                      size: Size(72 * s, 72 * s),
                      painter: _RingPainter(
                        progress: 0.70,
                        color: const Color(0xFF00C8FF),
                        s: s,
                      ),
                    ),
                    Positioned(
                      top: 20 * s,
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.cyan,
                        size: 24 * s,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * s,
                          vertical: 2 * s,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * s),
                          color: AppColors.cyan,
                        ),
                        child: Text(
                          '70%',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0B1220),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14 * s),

              // Bullets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signs detected:',
                      style: GoogleFonts.inter(
                        fontSize: 9 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    _BulletText(s: s, text: 'Low water intake'),
                    _BulletText(s: s, text: 'Long gap since last drink'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.cyan, size: 12 * s),
              SizedBox(width: 5 * s),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Suggestion:\n',
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                      TextSpan(
                        text: 'Drink 250–300 ml of water now.',
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
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

class _BulletText extends StatelessWidget {
  final double s;
  final String text;
  const _BulletText({required this.s, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.cyan),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 9 * s,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EveningRoutineCard extends StatelessWidget {
  final double s;
  const _EveningRoutineCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evening Wind-Down',
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6 * s),
                ),
                child: Text(
                  'UP NEXT',
                  style: GoogleFonts.outfit(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFB300),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Row(
            children: [
              Container(
                width: 48 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Icon(
                  Icons.nights_stay_rounded,
                  color: const Color(0xFFCE6AFF),
                  size: 24 * s,
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EST. START 21:30',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00F0FF),
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'Recommended: Blue Light Shift',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14 * s),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCE6AFF), Color(0xFF6F35FF)],
              ),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Center(
              child: Text(
                'Prepare for Rest',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Environment card
// ─────────────────────────────────────────────────────────────────────────────
class _SleepEnvironmentCard extends StatelessWidget {
  final double s;
  const _SleepEnvironmentCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Environment',
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6 * s),
                ),
                child: Text(
                  'Optimized',
                  style: GoogleFonts.outfit(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00FF9C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white30,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      '20°C',
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white30,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'Optimal',
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Trend card
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyTrendCard extends StatelessWidget {
  final double s;
  const _WeeklyTrendCard({required this.s});

  static const _weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final scores = RecoveryStorage.last7DaysScores;
    // Chart points 0..1 (null → 0 so line doesn't break).
    final chartPts = scores.map((v) => v != null ? v / 100.0 : 0.0).toList();
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _weekdayLabels[d.weekday - 1];
    });

    final hasAny = scores.any((v) => v != null);
    final thisWeekAvg = hasAny
        ? (scores.whereType<int>().reduce((a, b) => a + b) /
              scores.whereType<int>().length)
        : 0.0;
    final lastWeekAvg = 0.0; // Not stored; show delta when we have history.
    final delta = lastWeekAvg > 0
        ? ((thisWeekAvg - lastWeekAvg) / lastWeekAvg * 100)
        : null;

    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Trend',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (delta != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${delta >= 0 ? '+' : ''}${delta.round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w800,
                        color: delta >= 0
                            ? AppColors.cyan
                            : const Color(0xFFF87171),
                      ),
                    ),
                    Text(
                      'VS Last Week',
                      style: GoogleFonts.inter(
                        fontSize: 8 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                  ],
                )
              else if (hasAny)
                Text(
                  'Avg ${thisWeekAvg.round()}',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: AppColors.labelDim,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12 * s),

          // Line chart (recovery score 0–100 as 0–1)
          SizedBox(
            height: 60 * s,
            child: CustomPaint(
              painter: _LineChartPainter(points: chartPts, s: s),
              size: Size.infinite,
            ),
          ),
          SizedBox(height: 6 * s),

          // Day labels (last 7 days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels
                .map(
                  (d) => Text(
                    d,
                    style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      color: AppColors.labelDim,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inflammation Index card
// ─────────────────────────────────────────────────────────────────────────────
class _InflammationCard extends StatelessWidget {
  final double s;
  const _InflammationCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(s: s, label: 'STABLE', color: AppColors.cyan),
          SizedBox(height: 8 * s),
          Text(
            'INFLAMMATION\nINDEX',
            style: GoogleFonts.inter(
              fontSize: 8 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'LOW',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 22 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00FF9C),
            ),
          ),
          SizedBox(height: 6 * s),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.cyan, size: 10 * s),
              SizedBox(width: 4 * s),
              Expanded(
                child: Text(
                  'Tissue repair is peak.',
                  style: GoogleFonts.inter(
                    fontSize: 8 * s,
                    color: AppColors.labelDim,
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

// ─────────────────────────────────────────────────────────────────────────────
// Metabolic Readiness card
// ─────────────────────────────────────────────────────────────────────────────
class _MetabolicReadinessCard extends StatelessWidget {
  final double s;
  const _MetabolicReadinessCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(s: s, label: 'OPTIMAL', color: const Color(0xFF00FF9C)),
          SizedBox(height: 8 * s),
          Text(
            'METABOLIC\nREADINESS',
            style: GoogleFonts.inter(
              fontSize: 7.5 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            '88%',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 22 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * s),
          SizedBox(
            width: double.infinity,
            height: 32 * s,
            child: CustomPaint(
              painter: _PulseBarsPainter(
                values: [
                  0.3,
                  0.45,
                  0.35,
                  0.70,
                  0.40,
                  0.85,
                  0.30,
                  0.50,
                  0.75,
                  0.35,
                  0.45,
                  0.90,
                  0.30,
                  0.60,
                ],
                color: AppColors.cyan,
                s: s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseBarsPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double s;
  const _PulseBarsPainter({
    required this.values,
    required this.color,
    required this.s,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final n = values.length;
    final gap = size.width / (n - 1);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < n; i++) {
      final h = size.height * values[i];
      final x = i * gap;
      canvas.drawLine(
        Offset(x, size.height - h),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PulseBarsPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stress line graph painter (downward trend = LOW stress)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Toggle painter (ON state, cyan)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Ring painter (progress arc)
// ─────────────────────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double s;
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.s,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 4 * s;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14 * s
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini bars painter
// ─────────────────────────────────────────────────────────────────────────────
class _MiniBarsPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double s;
  const _MiniBarsPainter({
    required this.values,
    required this.color,
    required this.s,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final n = values.length;
    const gap = 3.0;
    final barW = ((size.width - gap * (n - 1)) / n).clamp(0.0, double.infinity);
    if (barW <= 0) return;
    for (int i = 0; i < n; i++) {
      final h = (size.height * values[i]).clamp(0.0, size.height);
      final x = i * (barW + gap);
      final radius = (barW / 2).clamp(0.0, h / 2);
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        Radius.circular(radius),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withAlpha(140)],
          ).createShader(Rect.fromLTWH(x, size.height - h, barW, h)),
      );
    }
  }

  @override
  bool shouldRepaint(_MiniBarsPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Line chart painter
// ─────────────────────────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final double s;
  const _LineChartPainter({required this.points, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final n = points.length;
    final stepX = size.width / (n - 1);

    Path buildLine() {
      final p = Path();
      p.moveTo(0, size.height * (1 - points[0]));
      for (int i = 1; i < n; i++) {
        final x0 = (i - 1) * stepX;
        final y0 = size.height * (1 - points[i - 1]);
        final x1 = i * stepX;
        final y1 = size.height * (1 - points[i]);
        final mx = (x0 + x1) / 2;
        p.cubicTo(mx, y0, mx, y1, x1, y1);
      }
      return p;
    }

    final linePath = buildLine();

    // Area fill
    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.cyan.withAlpha(60),
            AppColors.purple.withAlpha(40),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line with cyan→purple gradient
    canvas.drawPath(
      linePath,
      Paint()
        ..shader = LinearGradient(
          colors: [AppColors.cyan, AppColors.purple],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot at SAT (index 5)
    final dotIdx = 5;
    final dotX = dotIdx * stepX;
    final dotY = size.height * (1 - points[dotIdx]);
    canvas.drawCircle(
      Offset(dotX, dotY),
      5 * s,
      Paint()
        ..color = AppColors.cyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      3.5 * s,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => false;
}

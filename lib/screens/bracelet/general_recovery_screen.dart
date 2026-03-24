// ignore_for_file: unused_element, unnecessary_underscores

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/recovery/recovery_score_calculator.dart';
import '../../bracelet/recovery/recovery_storage.dart';
import '../../bracelet/sleep_storage.dart';
import '../../bracelet/weekly_data_storage.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_pill_header.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GeneralRecoveryScreen
// ─────────────────────────────────────────────────────────────────────────────
class GeneralRecoveryScreen extends StatelessWidget {
  const GeneralRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    // Build recovery from app data (sleep, HRV, yesterday steps). No SDK recovery.
    final steps = WeeklyDataStorage.last7DaysSteps;
    final input = RecoveryInput(
      totalSleepMinutes: SleepStorage.totalSleepMinutes,
      hrv: BraceletChannel.lastKnownHrv,
      restingHeartRate: null,
      stress: null,
      yesterdaySteps: steps.length >= 6 ? steps[5] : null,
      hrvHistoryLast7Days: null,
      restingHeartRateHistoryLast7Days: null,
    );
    final result = RecoveryScoreCalculator.calculate(input);
    // Persist today's snapshot so trend chart has data (in-memory; add prefs/DB later).
    RecoveryStorage.save(RecoverySnapshot(
      date: DateTime.now(),
      score: result.score,
      status: result.status,
      reasons: result.reasons,
      recordedAt: DateTime.now(),
    ));

    final sleepTotal = SleepStorage.totalSleepMinutes ?? 0;
    final sleepTarget = 8 * 60;
    final sleepPercent = ((sleepTotal / sleepTarget) * 100).clamp(0.0, 100.0).round();
    final deep = (SleepStorage.lastSleepData?['deepMinutes'] as num?)?.toInt() ?? 0;
    final rem = (SleepStorage.lastSleepData?['remMinutes'] as num?)?.toInt() ?? 0;
    final inBed = (SleepStorage.lastSleepData?['inBedDurationMinutes'] as num?)?.toInt() ?? (sleepTotal + 1);
    final circadian = ((sleepTotal / sleepTarget) * 100).clamp(0.0, 100.0).round();
    final deepPct = sleepTotal > 0 ? (deep / sleepTotal) : 0.0;
    final remPct = sleepTotal > 0 ? (rem / sleepTotal) : 0.0;
    final hrv = BraceletChannel.lastKnownHrv;
    final hydrationPct = ((sleepPercent * 0.75) + 10).clamp(0, 100).round();
    final consistency = RecoveryStorage.last7DaysScores.whereType<int>().toList();
    final avg7 = consistency.isEmpty
        ? result.score
        : (consistency.reduce((a, b) => a + b) / consistency.length).round();

    return BraceletScaffold(
      customTopBar: const DigiPillHeader(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name?.trim();
              final greeting = (name != null && name.isNotEmpty) ? 'HI, ${name.toUpperCase()}' : 'HI, USER';
              return Center(
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w300,
                    color: AppColors.labelDim,
                    letterSpacing: 1.8,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12 * s),
          _RecoveryHeroSection(s: s, score: result.score, status: result.status),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'What\'s Contributing'),
          SizedBox(height: 10 * s),
          _ContributorsSection(
            s: s,
            restorativeSleepPct: sleepPercent,
            nervousSystemLabel: hrv != null && hrv >= 45 ? 'Calm' : 'Active',
            tissueRepairLabel: result.score >= 85 ? 'Peak' : 'Building',
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Sleep Analysis'),
          SizedBox(height: 10 * s),
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
            hydrationPct: hydrationPct,
            balancePct: (inBed > 0 ? ((sleepTotal / inBed) * 100).round() : 0).clamp(0, 100),
          ),
          SizedBox(height: 14 * s),
          _SectionHeader(s: s, label: 'Maintain Recovery'),
          SizedBox(height: 10 * s),
          _SleepEnvironmentCard(s: s),
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
    final color = score >= 85 ? const Color(0xFF28B9FF) : const Color(0xFFB161FF);
    final subtitle = score >= 85
        ? 'Your body has restored optimally'
        : 'Your body is recovering steadily';
    return Column(
      children: [
        Text('Your Recovery', style: GoogleFonts.inter(fontSize: 13 * s, color: AppColors.labelDim)),
        SizedBox(height: 14 * s),
        SizedBox(
          width: 170 * s,
          height: 170 * s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(170 * s, 170 * s),
                painter: _RingPainter(progress: score / 100.0, color: color, s: s),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 46 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text('%', style: GoogleFonts.inter(fontSize: 18 * s, color: AppColors.labelDim)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        Text(
          status == 'Excellent' ? 'Fully Recovered' : 'Recovery In Progress',
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 20 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6 * s),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12 * s, color: AppColors.labelDim)),
      ],
    );
  }
}

class _ContributorsSection extends StatelessWidget {
  final double s;
  final int restorativeSleepPct;
  final String nervousSystemLabel;
  final String tissueRepairLabel;
  const _ContributorsSection({
    required this.s,
    required this.restorativeSleepPct,
    required this.nervousSystemLabel,
    required this.tissueRepairLabel,
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
          accentColor: const Color(0xFF1EDCFF),
        ),
        SizedBox(height: 8 * s),
        _ContribTile(
          s: s,
          icon: Icons.favorite_border_rounded,
          title: 'Nervous System',
          subtitle: 'Stress levels low',
          value: nervousSystemLabel,
          accentColor: const Color(0xFF1BEB8B),
        ),
        SizedBox(height: 8 * s),
        _ContribTile(
          s: s,
          icon: Icons.bolt_rounded,
          title: 'Tissue Repair',
          subtitle: 'Inflammation low',
          value: tissueRepairLabel,
          accentColor: const Color(0xFF52A3FF),
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
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 11 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: accentColor.withAlpha(90), width: 1.2 * s),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            accentColor.withAlpha(34),
            const Color(0xFF060E16),
            const Color(0xFF060E16),
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13 * s),
              color: accentColor.withAlpha(28),
            ),
            child: Icon(icon, size: 23 * s, color: accentColor),
          ),
          SizedBox(width: 11 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 8.8 * s,
                    color: const Color(0xFF8895A7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 17 * s,
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
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 18 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF121A26),
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: const Color(0xFF20314A), width: 1.1),
      ),
      child: Column(
        children: [
          _LineMetric(
            s: s,
            label: 'Deep Sleep',
            pct: deepPct.clamp(0.0, 1.0),
            quality: deepPct >= 0.20 ? 'Excellent' : 'Fair',
          ),
          SizedBox(height: 22 * s),
          _LineMetric(
            s: s,
            label: 'REM Sleep',
            pct: remPct.clamp(0.0, 1.0),
            quality: remPct >= 0.18 ? 'Good' : 'Low',
          ),
          SizedBox(height: 18 * s),
          Container(height: 1, color: const Color(0xFF24364D)),
          SizedBox(height: 18 * s),
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
              style: GoogleFonts.inter(
                fontSize: 17 * s,
                color: const Color(0xFF9DA8B7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              quality,
              style: GoogleFonts.inter(
                fontSize: 20 * s,
                color: quality == 'On Track' ? const Color(0xFF19D8FF) : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (showBar) ...[
          SizedBox(height: 14 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(7 * s),
            child: Container(
              height: 12 * s,
              color: const Color(0xFF23324A),
              child: FractionallySizedBox(
                widthFactor: pct,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF12C8ED), Color(0xFF357BFF)]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BodySystemsSection extends StatelessWidget {
  final double s;
  final int hydrationPct;
  final int balancePct;
  const _BodySystemsSection({
    required this.s,
    required this.hydrationPct,
    required this.balancePct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BodySystemTile(
            s: s,
            icon: Icons.water_drop_rounded,
            title: 'Hydration',
            value: '$hydrationPct%',
            subtitle: 'Drink 300ml soon',
          ),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: _BodySystemTile(
            s: s,
            icon: Icons.monitor_heart_outlined,
            title: 'Balance',
            value: '$balancePct%',
            subtitle: 'Well balanced',
          ),
        ),
      ],
    );
  }
}

class _BodySystemTile extends StatelessWidget {
  final double s;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  const _BodySystemTile({
    required this.s,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2A),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFF223045), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18 * s, color: const Color(0xFF11D1EE)),
          SizedBox(height: 10 * s),
          Text(title, style: GoogleFonts.inter(fontSize: 11 * s, color: const Color(0xFFA1AABC))),
          SizedBox(height: 2 * s),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 22 * s,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              color: title == 'Hydration' ? const Color(0xFF10C9EA) : const Color(0xFFA1AABC),
            ),
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
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bedtime_outlined, size: 16 * s, color: const Color(0xFF9B7BFF)),
              SizedBox(width: 8 * s),
              Text(
                'Evening Wind-Down',
                style: TextStyle(fontFamily: 'LemonMilk', fontSize: 11 * s, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text('Recommended at 21:30', style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim)),
          SizedBox(height: 4 * s),
          Text('Blue light shift mode maintain recovery', style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white.withAlpha(210))),
          SizedBox(height: 10 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * s),
              gradient: const LinearGradient(colors: [Color(0xFF2A63F6), Color(0xFF6E52FF)]),
            ),
            child: Center(
              child: Text(
                'Prepare for Rest',
                style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white, fontWeight: FontWeight.w700),
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
    final chartPts = RecoveryStorage.last7DaysScores
        .map((v) => (v ?? average7d) / 100.0)
        .toList();
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('7-Day Average', style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim)),
                  Text(
                    '$average7d%',
                    style: TextStyle(fontFamily: 'LemonMilk', fontSize: 22 * s, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Improvement', style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim)),
                  Text(
                    '+12%',
                    style: GoogleFonts.inter(fontSize: 16 * s, color: const Color(0xFF21E09A), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          SizedBox(
            height: 55 * s,
            child: CustomPaint(
              painter: _LineChartPainter(points: chartPts, s: s),
              size: Size.infinite,
            ),
          ),
          SizedBox(height: 6 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Text(d, style: TextStyle(color: AppColors.labelDim, fontSize: 10)))
                .toList(),
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
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(padding: EdgeInsets.all(14 * s), child: child),
        ),
      ),
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
          border: Border.all(
            color: color.withAlpha(60),
            width: 1.2 * s,
          ),
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
          .map((r) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * s),
                  color: AppColors.cyan.withAlpha(25),
                  border: Border.all(color: AppColors.cyan.withAlpha(80), width: 1),
                ),
                child: Text(
                  r,
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    color: AppColors.labelDim,
                  ),
                ),
              ))
          .toList(),
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

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final double s;
  final String label;
  const _SectionHeader({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'LemonMilk',
        fontSize: 13 * s,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Evening Routine Prep card
// ─────────────────────────────────────────────────────────────────────────────
class _EveningRoutineCard extends StatelessWidget {
  final double s;
  const _EveningRoutineCard({required this.s});

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
                'Evening Routine Prep',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              _Badge(s: s, label: 'UP NEXT', color: const Color(0xFFFFB300)),
            ],
          ),
          SizedBox(height: 10 * s),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sunset icon box
              Container(
                width: 52 * s,
                height: 52 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * s),
                  color: const Color(0xFF1A1228),
                  border: Border.all(
                    color: const Color(0xFFCE6AFF).withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.wb_twilight_rounded,
                  color: const Color(0xFFFFB300),
                  size: 28 * s,
                ),
              ),
              SizedBox(width: 12 * s),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EST. START 21:30',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyan,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      'Recommended: Blue Light Shift',
                      style: GoogleFonts.inter(
                        fontSize: 9 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * s),
          // Start Routine button — full width
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12 * s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(
                  color: AppColors.cyan.withAlpha(120),
                  width: 1,
                ),
                color: AppColors.cyan.withAlpha(18),
              ),
              child: Center(
                child: Text(
                  'START ROUTINE',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyan,
                    letterSpacing: 1.4,
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

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Environment card
// ─────────────────────────────────────────────────────────────────────────────
class _SleepEnvironmentCard extends StatelessWidget {
  final double s;
  const _SleepEnvironmentCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2A),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFF223045), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Environment',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              _Badge(s: s, label: 'Optimized', color: const Color(0xFF00FF9C)),
            ],
          ),
          SizedBox(height: 12 * s),

          Row(
            children: [
              // Temperature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat_rounded, size: 14 * s, color: const Color(0xFFA2AAB9)),
                        SizedBox(width: 4 * s),
                        Text('Temperature', style: GoogleFonts.inter(fontSize: 9.5 * s, color: const Color(0xFFA2AAB9))),
                      ],
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      '20°C',
                      style: TextStyle(
                        fontFamily: 'LemonMilk',
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),

              // Air Quality
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.air_rounded, size: 14 * s, color: const Color(0xFFA2AAB9)),
                        SizedBox(width: 4 * s),
                        Text('Air Quality', style: GoogleFonts.inter(fontSize: 9.5 * s, color: const Color(0xFFA2AAB9))),
                      ],
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      'Optimal',
                      style: TextStyle(
                        fontFamily: 'LemonMilk',
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  static const _weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

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
    final delta = lastWeekAvg > 0 ? ((thisWeekAvg - lastWeekAvg) / lastWeekAvg * 100) : null;

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
                        color: delta >= 0 ? AppColors.cyan : const Color(0xFFF87171),
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
    final r = math.min(cx, cy) - 5 * s;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = color.withAlpha(30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * s
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + math.pi * 2 * progress,
          colors: [color.withAlpha(180), color],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * s
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
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

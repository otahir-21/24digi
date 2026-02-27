import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GeneralRecoveryScreen
// ─────────────────────────────────────────────────────────────────────────────
class GeneralRecoveryScreen extends StatelessWidget {
  const GeneralRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ───────────────────────────────────────────
                _TopBar(s: s, title: 'General Recovery In...'),
                SizedBox(height: 8 * s),

                // ── HI, USER ──────────────────────────────────────────
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
                SizedBox(height: 12 * s),

                // ── Regeneration status pill ───────────────────────────
                _StatusPill(s: s),
                SizedBox(height: 16 * s),

                // ── Ready for High Intensity ───────────────────────────
                Center(
                  child: Text(
                    'Ready for High Intensity',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Body Balance + Stress Index ───────────────────────
                Row(
                  children: [
                    Expanded(child: _BodyBalanceCard(s: s)),
                    SizedBox(width: 10 * s),
                    Expanded(child: _StressIndexCard(s: s)),
                  ],
                ),
                SizedBox(height: 14 * s),

                // ── Sleep Quality card ────────────────────────────────
                _SleepQualityCard(s: s),
                SizedBox(height: 20 * s),

                // ── Regeneration Insights header ──────────────────────
                _SectionHeader(s: s, label: 'Regeneration Insights'),
                SizedBox(height: 12 * s),

                // ── Hydration Recovery card ───────────────────────────
                _HydrationRecoveryCard(s: s),
                SizedBox(height: 10 * s),

                // ── Evening Routine Prep card ─────────────────────────
                _EveningRoutineCard(s: s),
                SizedBox(height: 10 * s),

                // ── Sleep Environment card ────────────────────────────
                _SleepEnvironmentCard(s: s),
                SizedBox(height: 20 * s),

                // ── Recovery Consistency header ───────────────────────
                _SectionHeader(s: s, label: 'Recovery Consistency'),
                SizedBox(height: 12 * s),

                // ── Weekly Trend card ─────────────────────────────────
                _WeeklyTrendCard(s: s),
                SizedBox(height: 20 * s),

                // ── Metabolic Markers header ──────────────────────────
                _SectionHeader(s: s, label: 'Metabolic Markers'),
                SizedBox(height: 12 * s),

                // ── Inflammation + Metabolic Readiness ───────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _InflammationCard(s: s)),
                    SizedBox(width: 10 * s),
                    Expanded(child: _MetabolicReadinessCard(s: s)),
                  ],
                ),
                SizedBox(height: 28 * s),
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
  final String title;
  const _TopBar({required this.s, required this.title});

  @override
  Widget build(BuildContext context) {
    final h = 60.0 * s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2 * s, bottom: 6 * s),
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 11 * s, color: AppColors.labelDim),
          ),
        ),
        CustomPaint(
          painter: SmoothGradientBorder(radius: h / 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h / 2),
            child: ColoredBox(
              color: const Color(0xFF060E16),
              child: SizedBox(
                height: h,
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
                            child: Image.asset(
                              'assets/fonts/male.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1E2A3A),
                                child: Icon(Icons.person,
                                    color: AppColors.labelDim, size: 24 * s),
                              ),
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
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient-border card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  final EdgeInsets? padding;
  const _BorderCard({required this.s, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(
            padding: padding ?? EdgeInsets.all(14 * s),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pill
// ─────────────────────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final double s;
  const _StatusPill({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * s),
        color: AppColors.cyan.withAlpha(18),
        border: Border.all(color: AppColors.cyan.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.cyan, size: 15 * s),
          SizedBox(width: 6 * s),
          Text(
            'REGENERATION STATUS: OPTIMAL',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
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
              Text('BODY BALANCE',
                  style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      color: AppColors.labelDim,
                      letterSpacing: 0.8)),
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
                  s: s),
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
              Icon(Icons.show_chart_rounded,
                  color: const Color(0xFFCE6AFF), size: 16 * s),
              SizedBox(width: 4 * s),
              Text('STRESS INDEX',
                  style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      color: AppColors.labelDim,
                      letterSpacing: 0.8)),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            'LOW',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 24 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00FF9C),
            ),
          ),
          SizedBox(height: 10 * s),
          Container(
            height: 26 * s,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2C333A),
              borderRadius: BorderRadius.circular(20 * s),
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 52 * s,
              height: 26 * s,
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(20 * s),
              ),
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
                  Icon(Icons.nightlight_round,
                      color: const Color(0xFFCE6AFF), size: 18 * s),
                  SizedBox(width: 8 * s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sleep Quality',
                          style: TextStyle(
                              fontFamily: 'LemonMilk',
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('Total Duration:',
                          style: GoogleFonts.inter(
                              fontSize: 9 * s, color: AppColors.labelDim)),
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
              Text('Circadian Alignment',
                  style: GoogleFonts.inter(
                      fontSize: 10 * s, color: AppColors.labelDim)),
              Text('96%',
                  style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan)),
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
  const _SleepStageBar(
      {required this.s, required this.bar, required this.maxH});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28 * s,
          height: maxH * bar.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6 * s),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bar.color, bar.color.withAlpha(100)],
            ),
            boxShadow: [
              BoxShadow(
                  color: bar.color.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
        ),
        SizedBox(height: 5 * s),
        Text(bar.label,
            style: GoogleFonts.inter(
                fontSize: 8 * s, color: AppColors.labelDim)),
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
              Text('Hydration Recovery',
                  style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              _Badge(s: s, label: 'ON TRACK', color: AppColors.cyan),
            ],
          ),
          SizedBox(height: 4 * s),
          Text('Goal: 2.5L Today',
              style: GoogleFonts.inter(
                  fontSize: 10 * s, color: AppColors.labelDim)),
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
                          s: s),
                    ),
                    Positioned(
                      top: 20 * s,
                      child: Icon(Icons.water_drop_rounded,
                          color: AppColors.cyan, size: 24 * s),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8 * s, vertical: 2 * s),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * s),
                          color: AppColors.cyan,
                        ),
                        child: Text('70%',
                            style: GoogleFonts.inter(
                                fontSize: 10 * s,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0B1220))),
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
                    Text('Signs detected:',
                        style: GoogleFonts.inter(
                            fontSize: 9 * s, color: AppColors.labelDim)),
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
              Icon(Icons.auto_awesome,
                  color: AppColors.cyan, size: 12 * s),
              SizedBox(width: 5 * s),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Suggestion:\n',
                          style: GoogleFonts.inter(
                              fontSize: 9 * s,
                              color: AppColors.labelDim)),
                      TextSpan(
                          text: 'Drink 250–300 ml of water now.',
                          style: GoogleFonts.inter(
                              fontSize: 9 * s,
                              color: AppColors.textLight)),
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
          Text('• ',
              style: GoogleFonts.inter(
                  fontSize: 9 * s, color: AppColors.cyan)),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 9 * s, color: AppColors.textLight)),
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
              Text('Evening Routine Prep',
                  style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              _Badge(
                  s: s, label: 'UP NEXT', color: const Color(0xFFFFB300)),
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
                      width: 1),
                ),
                child: Icon(Icons.wb_twilight_rounded,
                    color: const Color(0xFFFFB300), size: 28 * s),
              ),
              SizedBox(width: 12 * s),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EST. START 21:30',
                        style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan)),
                    SizedBox(height: 3 * s),
                    Text('Recommended: Blue Light Shift',
                        style: GoogleFonts.inter(
                            fontSize: 9 * s, color: AppColors.labelDim)),
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
                    color: AppColors.cyan.withAlpha(120), width: 1),
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
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sleep Environment',
                  style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              _Badge(
                  s: s,
                  label: 'Optimized',
                  color: const Color(0xFF00FF9C)),
            ],
          ),
          SizedBox(height: 14 * s),

          Row(
            children: [
              // Temperature
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * s),
                    color: Colors.white.withAlpha(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temperature',
                          style: GoogleFonts.inter(
                              fontSize: 9 * s, color: AppColors.labelDim)),
                      SizedBox(height: 2 * s),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('20',
                              style: TextStyle(
                                  fontFamily: 'LemonMilk',
                                  fontSize: 22 * s,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Padding(
                            padding: EdgeInsets.only(top: 3 * s),
                            child: Text('C',
                                style: GoogleFonts.inter(
                                    fontSize: 11 * s,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      Text('Ideal Range',
                          style: GoogleFonts.inter(
                              fontSize: 8 * s, color: AppColors.labelDim)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10 * s),

              // Air Quality
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * s),
                    color: Colors.white.withAlpha(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Air Quality',
                          style: GoogleFonts.inter(
                              fontSize: 9 * s, color: AppColors.labelDim)),
                      SizedBox(height: 2 * s),
                      Text('Optimal',
                          style: TextStyle(
                              fontFamily: 'LemonMilk',
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FF9C))),
                      SizedBox(height: 2 * s),
                      Text('PM2.5: Low',
                          style: GoogleFonts.inter(
                              fontSize: 8 * s, color: AppColors.labelDim)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Trend card
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyTrendCard extends StatelessWidget {
  final double s;
  const _WeeklyTrendCard({required this.s});

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _chartPts = [0.55, 0.60, 0.50, 0.65, 0.70, 0.75, 0.85];

  @override
  Widget build(BuildContext context) {
    return _BorderCard(
      s: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Trend',
                  style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+12%',
                      style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cyan)),
                  Text('VS Last Week',
                      style: GoogleFonts.inter(
                          fontSize: 8 * s, color: AppColors.labelDim)),
                ],
              ),
            ],
          ),
          SizedBox(height: 12 * s),

          // Line chart
          SizedBox(
            height: 60 * s,
            child: CustomPaint(
              painter:
                  _LineChartPainter(points: _chartPts, s: s),
              size: Size.infinite,
            ),
          ),
          SizedBox(height: 6 * s),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days
                .map((d) => Text(d,
                    style: GoogleFonts.inter(
                        fontSize: 8 * s, color: AppColors.labelDim)))
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
          Text('INFLAMMATION\nINDEX',
              style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  color: AppColors.labelDim,
                  letterSpacing: 0.5)),
          SizedBox(height: 4 * s),
          Text('LOW',
              style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00FF9C))),
          SizedBox(height: 6 * s),
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: AppColors.cyan, size: 10 * s),
              SizedBox(width: 4 * s),
              Expanded(
                child: Text('Tissue repair is peak.',
                    style: GoogleFonts.inter(
                        fontSize: 8 * s, color: AppColors.labelDim)),
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
          _Badge(
              s: s,
              label: 'OPTIMAL',
              color: const Color(0xFF00FF9C)),
          SizedBox(height: 8 * s),
          Text('METABOLIC\nREADINESS',
              style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  color: AppColors.labelDim,
                  letterSpacing: 0.5)),
          SizedBox(height: 4 * s),
          Text('88%',
              style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: 6 * s),
          SizedBox(
            width: double.infinity,
            height: 28 * s,
            child: CustomPaint(
              painter: _MiniBarsPainter(
                  values: [0.5, 0.65, 0.55, 0.80, 0.70, 0.88],
                  color: AppColors.cyan,
                  s: s),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stress line graph painter (downward trend = LOW stress)
// ─────────────────────────────────────────────────────────────────────────────
class _StressLinePainter extends CustomPainter {
  final double s;
  const _StressLinePainter({required this.s});

  static const _pts = [0.85, 0.70, 0.60, 0.50, 0.38, 0.28, 0.20];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final n = _pts.length;
    final stepX = size.width / (n - 1);

    Path buildLine() {
      final p = Path();
      p.moveTo(0, size.height * (1 - _pts[0]));
      for (int i = 1; i < n; i++) {
        final x0 = (i - 1) * stepX;
        final y0 = size.height * (1 - _pts[i - 1]);
        final x1 = i * stepX;
        final y1 = size.height * (1 - _pts[i]);
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.purple.withAlpha(70),
            AppColors.purple.withAlpha(10),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot
    final endX = size.width;
    final endY = size.height * (1 - _pts.last);
    canvas.drawCircle(Offset(endX, endY), 3.5 * s,
        Paint()..color = AppColors.purple);
    canvas.drawCircle(Offset(endX, endY), 2 * s,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_StressLinePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle painter (ON state, cyan)
// ─────────────────────────────────────────────────────────────────────────────
class _TogglePainter extends CustomPainter {
  final double s;
  const _TogglePainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final trackH = size.height;
    final trackW = size.width;
    final radius = trackH / 2;

    // Track background (right side = dark)
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, trackW, trackH),
      Radius.circular(radius),
    );
    canvas.drawRRect(trackRect, Paint()..color = const Color(0xFF2A3040));

    // Cyan filled left portion (ON fill)
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, trackW * 0.55, trackH),
      Radius.circular(radius),
    );
    canvas.drawRRect(fillRect, Paint()..color = AppColors.cyan);

    // Thumb (white circle on the right of the cyan area)
    final thumbX = trackW * 0.55 - radius + 2 * s;
    final thumbY = trackH / 2;
    // Shadow
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      radius - 2 * s,
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Thumb
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      radius - 2 * s,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_TogglePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Ring painter (progress arc)
// ─────────────────────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double s;
  const _RingPainter(
      {required this.progress, required this.color, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 5 * s;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false,
        Paint()
          ..color = color.withAlpha(30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * s
          ..strokeCap = StrokeCap.round);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false,
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
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
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
  const _MiniBarsPainter(
      {required this.values, required this.color, required this.s});

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
            ).createShader(Rect.fromLTWH(x, size.height - h, barW, h)));
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
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(dotX, dotY), 3.5 * s,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kivi_24/screens/save_life_ai/ai_explanation_screen.dart';
import 'package:kivi_24/screens/save_life_ai/blood_pressure_risk_screen.dart';
import 'package:kivi_24/screens/save_life_ai/blood_oxygen_monitoring_screen.dart';
import 'package:kivi_24/screens/save_life_ai/kidney_disease_risk_screen.dart';
import 'package:kivi_24/screens/save_life_ai/metabolic_syndrome_risk_screen.dart';
import 'package:kivi_24/screens/save_life_ai/obesity_hypoventilation_screen.dart';
import 'package:kivi_24/screens/save_life_ai/resting_heart_rate_analysis_screen.dart';
import 'package:kivi_24/screens/save_life_ai/shock_index_assessment_screen.dart';
import 'package:kivi_24/screens/save_life_ai/sleep_apnea_risk_screen.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _C {
  _C._();
  static const bg = Color(0xFF090910);
  static const card = Color(0xFF111118);
  static const cardBorder = Color(0xFF222230);
  static const gold = Color(0xFFD4A017);
  static const goldLight = Color(0xFFE8B84B);
  static const goldGlow = Color(0xFFFFD54F);
  static const green = Color(0xFF4CAF50);
  static const greenBadge = Color(0xFF1B3A1C);
  static const red = Color(0xFFEF5350);
  static const redBadge = Color(0xFF3A1B1B);
  static const orange = Color(0xFFFF9800);
  static const blue = Color(0xFF5C8AFF);
  static const blueCard = Color(0xFF0E1525);
  static const blueBorder = Color(0xFF1C2D55);
  static const arcTrack = Color(0xFF2A2A3A);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const grey3 = Color(0xFF2A2A3A);
  static const monitorBg = Color(0xFF1A1A28);
  static const monitorBorder = Color(0xFF2E2E45);
  static const tabBg = Color(0xFF0D0D14);
  static const tabBorder = Color(0xFF222230);
  static const tabSelBg = Color(0xFF1E1E2C);
  static const tabSelBorder = Color(0xFF333348);
  static const stableBg = Color(0xFF1A1A28);
  static const stableBorder = Color(0xFF2A2A3A);
  static const attentionBg = Color(0xFF2A1F0A);
  static const attentionBorder = Color(0xFF5A3A10);
}

class _Metric {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeText;
  final Color badgeBg;
  final String desc;
  final bool descHighlight;
  final String value;
  final String unit;
  final String conf;
  final double progress;
  final Color progressColor;
  final VoidCallback? onTap;
  const _Metric({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeText,
    required this.badgeBg,
    required this.desc,
    this.descHighlight = false,
    required this.value,
    required this.unit,
    required this.conf,
    required this.progress,
    required this.progressColor,
    this.onTap,
  });
}

class _Trend {
  final Color dot;
  final String label;
  final String status;
  final bool needsAttention;
  const _Trend({
    required this.dot,
    required this.label,
    required this.status,
    required this.needsAttention,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC DATA
// ─────────────────────────────────────────────────────────────────────────────
const _kMetrics = <_Metric>[
  _Metric(
    icon: Icons.favorite_border_rounded,
    iconColor: Color(0xFFEF9A9A),
    title: 'Blood Pressure',
    subtitle: 'Cardiovascular',
    badge: 'Monitor',
    badgeText: _C.goldLight,
    badgeBg: Color(0xFF2A1E05),
    desc: '↑ Slight upward trend over 14 days',
    descHighlight: true,
    value: '128/82',
    unit: 'mmHg',
    conf: '81% conf.',
    progress: .72,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.show_chart_rounded,
    iconColor: Color(0xFF80DEEA),
    title: 'Shock Index',
    subtitle: 'Circulatory',
    badge: 'Stable',
    badgeText: _C.green,
    badgeBg: _C.greenBadge,
    desc: '— Consistently within normal range',
    value: '0.62',
    unit: 'ratio',
    conf: '87% conf.',
    progress: .87,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.monitor_heart_outlined,
    iconColor: Color(0xFFA5D6A7),
    title: 'Resting HR',
    subtitle: 'Cardiac',
    badge: 'Stable',
    badgeText: _C.green,
    badgeBg: _C.greenBadge,
    desc: '— Within personal baseline range',
    value: '88',
    unit: 'bpm',
    conf: '84% conf.',
    progress: .84,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.water_drop_outlined,
    iconColor: Color(0xFF90CAF9),
    title: 'Blood Oxygen',
    subtitle: 'Respiratory',
    badge: 'Stable',
    badgeText: _C.green,
    badgeBg: _C.greenBadge,
    desc: '— Consistently normal oxygen levels',
    value: '97',
    unit: '% SpO2',
    conf: '89% conf.',
    progress: .89,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.bedtime_outlined,
    iconColor: Color(0xFFCE93D8),
    title: 'Sleep Apnea',
    subtitle: 'Sleep Medicine',
    badge: 'Monitor',
    badgeText: _C.goldLight,
    badgeBg: Color(0xFF2A1E05),
    desc: '↑ Slight increase in breathing interruptions',
    descHighlight: true,
    value: '8.2',
    unit: 'events/hr',
    conf: '80% conf.',
    progress: .80,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.air_rounded,
    iconColor: Color(0xFFFFCC80),
    title: 'Hypoventilation',
    subtitle: 'Respiratory',
    badge: 'Stable',
    badgeText: _C.green,
    badgeBg: _C.greenBadge,
    desc: 'No concerning patterns detected',
    value: 'Normal',
    unit: '',
    conf: '78% conf.',
    progress: .78,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.science_outlined,
    iconColor: Color(0xFF80CBC4),
    title: 'Kidney Risk',
    subtitle: 'Renal',
    badge: 'Stable',
    badgeText: _C.green,
    badgeBg: _C.greenBadge,
    desc: '— All indirect indicators within range',
    value: 'Low Risk',
    unit: '',
    conf: '75% conf.',
    progress: .75,
    progressColor: _C.green,
  ),
  _Metric(
    icon: Icons.local_fire_department_outlined,
    iconColor: Color(0xFFFF8A65),
    title: 'Metabolic Risk',
    subtitle: 'Metabolic',
    badge: 'Elevated Risk',
    badgeText: _C.red,
    badgeBg: _C.redBadge,
    desc: '↑ Gradual increase over 30 days',
    descHighlight: true,
    value: '56',
    unit: 'risk',
    conf: '88% conf.',
    progress: .88,
    progressColor: _C.red,
  ),
];

void _navigate(BuildContext context, _Metric card) {
  if (card.title == 'Metabolic Risk') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MetabolicSyndromeRiskScreen()));
  } else if (card.title == 'Hypoventilation') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ObesityHypoventilationScreen()));
  } else if (card.title == 'Kidney Risk') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const KidneyDiseaseRiskScreen()));
  } else if (card.title == 'Blood Oxygen') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodOxygenMonitoringScreen()));
  } else if (card.title == 'Sleep Apnea') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepApneaRiskScreen()));
  } else if (card.title == 'Blood Pressure') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodPressureRiskScreen()));
  } else if (card.title == 'Shock Index') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShockIndexAssessmentScreen()));
  } else if (card.title == 'Resting HR') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RestingHeartRateAnalysisScreen()));
  }
}

const _kTrends = <_Trend>[
  _Trend(
    dot: _C.goldLight,
    label: 'Blood Pressure',
    status: '↗ Needs Attention',
    needsAttention: true,
  ),
  _Trend(
    dot: _C.green,
    label: 'Shock Index',
    status: '— Stable',
    needsAttention: false,
  ),
  _Trend(
    dot: _C.green,
    label: 'Resting HR',
    status: '— Stable',
    needsAttention: false,
  ),
  _Trend(
    dot: _C.green,
    label: 'Blood Oxygen',
    status: '— Stable',
    needsAttention: false,
  ),
  _Trend(
    dot: _C.goldLight,
    label: 'Sleep Apnea',
    status: '↗ Needs Attention',
    needsAttention: true,
  ),
  _Trend(
    dot: _C.green,
    label: 'Hypoventilation',
    status: '— Stable',
    needsAttention: false,
  ),
  _Trend(
    dot: _C.green,
    label: 'Kidney Risk',
    status: '— Stable',
    needsAttention: false,
  ),
  _Trend(
    dot: _C.red,
    label: 'Metabolic Risk',
    status: '↗ Needs Attention',
    needsAttention: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SaveLifeAiDashboard extends StatefulWidget {
  const SaveLifeAiDashboard({super.key});

  @override
  State<SaveLifeAiDashboard> createState() => _SaveLifeAiDashboardState();
}

class _SaveLifeAiDashboardState extends State<SaveLifeAiDashboard>
    with TickerProviderStateMixin {
  int _trendTab = 1; // default: "7 Days"

  late final AnimationController _arcCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final Animation<double> _arcAnim = CurvedAnimation(
    parent: _arcCtrl,
    curve: Curves.easeOutCubic,
  );

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _arcCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ① TOP BAR  — your reusable DigiPillHeader
            const DigiPillHeader(),
            const SizedBox(height: 14),

            // ② GREETING
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'HI, USER',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ③ SAFELIFE APP CARD
            _AppCard(),
            const SizedBox(height: 4),

            // ④ SCORE ARC + MONITOR ROW
            _ScoreSection(arcAnim: _arcAnim, pulseCtrl: _pulseCtrl),
            const SizedBox(height: 20),

            // ⑤ METRICS GRID  (2 × 4)
            _MetricsGrid(),
            const SizedBox(height: 16),

            // ⑥ AI INSIGHT CARD
            _InsightCard(),
            const SizedBox(height: 18),

            // ⑦ PREDICTIVE TREND DIRECTION
            _PredictiveTrend(
              selected: _trendTab,
              onTab: (i) => setState(() => _trendTab = i),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ③  APP CARD
// ─────────────────────────────────────────────────────────────────────────────
class _AppCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Row(
          children: [
            // Shield icon box
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _C.blueCard,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _C.blueBorder),
              ),
              child: const Icon(Icons.shield_rounded, color: _C.blue, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SafeLife',
                    style: TextStyle(
                      color: _C.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'AI Health Intelligence',
                    style: TextStyle(
                      color: _C.grey1,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Status icons
            Row(
              children: [
                _glowDot(_C.green),
                const SizedBox(width: 8),
                const Icon(Icons.wifi_rounded, color: _C.grey1, size: 16),
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz_rounded, color: _C.grey1, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ④  SCORE SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreSection extends StatelessWidget {
  final Animation<double> arcAnim;
  final AnimationController pulseCtrl;
  const _ScoreSection({required this.arcAnim, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arc + score
        AnimatedBuilder(
          animation: arcAnim,
          builder: (_, __) => SizedBox(
            width: 220,
            height: 210,
            child: CustomPaint(
              painter: _ArcPainter(progress: arcAnim.value),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        color: _C.gold,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(arcAnim.value * 61).round()}',
                        style: const TextStyle(
                          color: _C.goldLight,
                          fontSize: 58,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Safety Score',
                        style: TextStyle(
                          color: _C.grey1,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ● Monitor button
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (_, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: _C.monitorBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _C.monitorBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.goldLight,
                    boxShadow: [
                      BoxShadow(
                        color: _C.goldLight.withOpacity(
                          .25 + .5 * pulseCtrl.value,
                        ),
                        blurRadius: 4 + 6 * pulseCtrl.value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Monitor',
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // AI confidence
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.graphic_eq_rounded, color: _C.grey1, size: 13),
            const SizedBox(width: 6),
            _caption('AI Confidence: 85%'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(width: 1, height: 12, color: _C.grey3),
            ),
            _caption('Updated: Just now'),
          ],
        ),
        const SizedBox(height: 8),

        // Continuous monitoring
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glowDot(_C.green),
            const SizedBox(width: 8),
            _caption('Continuous monitoring active'),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑤  METRICS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _MetricsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: _kMetrics.length,
        itemBuilder: (_, i) => _MetricTile(_kMetrics[i]),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _Metric m;
  const _MetricTile(this.m);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context, m),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(m.icon, color: m.iconColor, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    m.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _C.grey2,
                  size: 15,
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              m.subtitle,
              style: const TextStyle(
                color: _C.grey2,
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 7),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: m.badgeBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                m.badge,
                style: TextStyle(
                  color: m.badgeText,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Description
            Text(
              m.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: m.descHighlight ? _C.goldLight : _C.grey1,
                fontSize: 9.5,
                height: 1.3,
              ),
            ),

            const Spacer(),

            // Value + unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  m.value,
                  style: TextStyle(
                    color: m.progressColor,
                    fontSize: m.value.length > 5 ? 13 : 18,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                if (m.unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      m.unit,
                      style: const TextStyle(color: _C.grey2, fontSize: 9),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 5),

            // Progress bar + conf
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: m.progress,
                      minHeight: 3,
                      backgroundColor: _C.grey3,
                      valueColor: AlwaysStoppedAnimation(m.progressColor),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  m.conf,
                  style: const TextStyle(color: _C.grey2, fontSize: 8.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑥  AI INSIGHT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.blueCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.blueBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111E38),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _C.blueBorder),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: _C.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'SafeLife AI Insight',
                  style: TextStyle(
                    color: _C.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                _glowDot(_C.green),
              ],
            ),
            const SizedBox(height: 14),

            // Headline
            const Text(
              'Early metabolic risk pattern\ndetected',
              style: TextStyle(
                color: _C.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // View Details button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiExplanationScreen(riskType: 'Health Intelligence'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.cardBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _C.grey1,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Why row
            const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: _C.grey2, size: 14),
                SizedBox(width: 7),
                Text(
                  'Why am I seeing this?',
                  style: TextStyle(color: _C.grey1, fontSize: 12.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑦  PREDICTIVE TREND DIRECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PredictiveTrend extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTab;
  const _PredictiveTrend({required this.selected, required this.onTab});

  static const _tabs = ['Today', '7 Days', '30 Days', '6 Months'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: _C.grey1, size: 14),
                SizedBox(width: 8),
                Text(
                  'Predictive Trend Direction',
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tab switcher
            Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _C.tabBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.tabBorder),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final sel = i == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTab(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: sel ? _C.tabSelBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: sel
                              ? Border.all(color: _C.tabSelBorder)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _tabs[i],
                            style: TextStyle(
                              color: sel ? _C.white : _C.grey1,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),

            // Trend list rows
            ...List.generate(_kTrends.length, (i) {
              final t = _kTrends[i];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        // Coloured dot
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: t.dot,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: t.dot.withOpacity(.45),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.label,
                            style: const TextStyle(
                              color: _C.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: t.needsAttention
                                ? _C.attentionBg
                                : _C.stableBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: t.needsAttention
                                  ? _C.attentionBorder
                                  : _C.stableBorder,
                            ),
                          ),
                          child: Text(
                            t.status,
                            style: TextStyle(
                              color: t.needsAttention ? _C.orange : _C.grey1,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _kTrends.length - 1)
                    Divider(height: 1, thickness: .5, color: _C.cardBorder),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ARC  PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  /// progress 0.0 → 1.0  (maps to score 0 → 61 on a 270° arc)
  final double progress;
  const _ArcPainter({required this.progress});

  static const _startAngle = math.pi * 0.72; // bottom-left
  static const _totalSweep = math.pi * 1.56; // 280.8°

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    const r = 90.0;
    const sw = 11.0;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // ── grey track
    canvas.drawArc(
      rect,
      _startAngle,
      _totalSweep,
      false,
      Paint()
        ..color = _C.arcTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // ── gold filled arc
    final filled = _totalSweep * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      _startAngle,
      filled,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + filled,
          colors: const [
            Color(0xFF7A5010),
            Color(0xFFD4A017),
            Color(0xFFE8B84B),
            Color(0xFFFFD54F),
          ],
          stops: const [0.0, 0.35, 0.70, 1.0],
          transform: GradientRotation(_startAngle),
        ).createShader(rect),
    );

    // ── glowing tip
    final tipAngle = _startAngle + filled;
    final tipX = cx + r * math.cos(tipAngle);
    final tipY = cy + r * math.sin(tipAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      6,
      Paint()
        ..color = _C.goldGlow.withOpacity(.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(Offset(tipX, tipY), 3, Paint()..color = _C.goldGlow);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// MICRO HELPERS
// ─────────────────────────────────────────────────────────────────────────────
Widget _glowDot(Color c) => Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: c,
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(color: c.withOpacity(.5), blurRadius: 5)],
  ),
);

Widget _caption(String t) =>
    Text(t, style: const TextStyle(color: _C.grey1, fontSize: 12));

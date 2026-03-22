import 'package:flutter/material.dart';
import 'package:kivi_24/screens/save_life_ai/ai_explanation_screen.dart';
import 'package:kivi_24/screens/save_life_ai/medical_preparation_screen.dart';
import 'package:kivi_24/screens/save_life_ai/pattern_analysis_screen.dart';
import 'package:kivi_24/screens/save_life_ai/prevention_guidance_screen.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _C {
  _C._();
  static const bg = Color(0xFF090910);
  static const card = Color(0xFF111118);
  static const cardBorder = Color(0xFF222230);
  static const riskCard = Color(0xFFFAF5E8);
  static const red = Color(0xFFEF5350);
  static const redBadge = Color(0xFFFFEBEA);
  static const redText = Color(0xFFD32F2F);
  static const orange = Color(0xFFFF8C00);
  static const green = Color(0xFF4CAF50);
  static const blue = Color(0xFF5C8AFF);
  static const blueCard = Color(0xFF0E1525);
  static const blueBorder = Color(0xFF1C2D55);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const grey3 = Color(0xFF2A2A3A);
  static const chartGrid = Color(0xFF1E1E2E);
  static const chartActual = Color(0xFFFF7043);
  static const chartPred = Color(0xFF78909C);
  static const chartBase = Color(0xFF546E7A);
  // impact chip colours
  static const highImpactBg = Color(0xFF2A1505);
  static const highImpactBrd = Color(0xFF5A2E0A);
  static const highImpactTxt = Color(0xFFFF8C00);
  static const medImpactBg = Color(0xFF1A1E2A);
  static const medImpactBrd = Color(0xFF2A3050);
  static const medImpactTxt = Color(0xFF5C8AFF);
  // recommended-action tag colours
  static const lifestyleBg = Color(0xFF0D2010);
  static const lifestyleBrd = Color(0xFF1A4020);
  static const lifestyleTxt = Color(0xFF66BB6A);
  static const monitorBg = Color(0xFF0D1A2A);
  static const monitorBrd = Color(0xFF1A3050);
  static const monitorTxt = Color(0xFF5C8AFF);
  static const consultBg = Color(0xFF2A1800);
  static const consultBrd = Color(0xFF5A3000);
  static const consultTxt = Color(0xFFFFB300);
  // warning / missing data
  static const warnBg = Color(0xFF1E1600);
  static const warnBorder = Color(0xFF4A3800);
  static const warnIcon = Color(0xFFFFC107);
  // escalation bar
  static const escGreen = Color(0xFF4CAF50);
  static const escYellow = Color(0xFFFFEB3B);
  static const escGrey = Color(0xFF37374A);
}

class MetabolicSyndromeRiskScreen extends StatefulWidget {
  const MetabolicSyndromeRiskScreen({super.key});

  @override
  State<MetabolicSyndromeRiskScreen> createState() =>
      _MetabolicSyndromeRiskScreenState();
}

class _MetabolicSyndromeRiskScreenState
    extends State<MetabolicSyndromeRiskScreen> {
  bool _showMedicalExp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ① DigiPillHeader
            const DigiPillHeader(),
            const SizedBox(height: 14),

            // ② Greeting
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
            const SizedBox(height: 16),

            // ③ Page title
            _PageTitle(),
            const SizedBox(height: 16),

            // ④ Risk score card
            _RiskScoreCard(),
            const SizedBox(height: 16),

            // ⑤ Composite Metabolic Score chart
            _CompositeChart(),
            const SizedBox(height: 16),

            // ⑥ AI Interpretation
            _AiInterpretation(
              showMedical: _showMedicalExp,
              onToggle: () =>
                  setState(() => _showMedicalExp = !_showMedicalExp),
            ),
            const SizedBox(height: 16),

            // ⑦ Contributing Factors
            _ContributingFactors(),
            const SizedBox(height: 16),

            // ⑧ Recommended Actions
            _RecommendedActions(),
            const SizedBox(height: 16),

            // ⑨ Data Transparency
            _DataTransparency(),
            const SizedBox(height: 16),

            // ⑩ Escalation Status
            _EscalationStatus(),
            const SizedBox(height: 24),

            // ⑪ Deep Analysis
            _DeepAnalysis(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ③  PAGE TITLE
// ─────────────────────────────────────────────────────────────────────────────
class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.highImpactBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.highImpactBrd),
            ),
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: _C.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metabolic Syndrome Risk',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Metabolic',
                style: TextStyle(color: _C.grey1, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ④  RISK SCORE CARD  (cream/light background)
// ─────────────────────────────────────────────────────────────────────────────
class _RiskScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: _C.riskCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: badge + confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _C.redBadge,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.red.withOpacity(.3), width: 1),
                  ),
                  child: const Text(
                    'Elevated Risk',
                    style: TextStyle(
                      color: _C.redText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: Color(0xFF888888),
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI Confidence: 80%',
                      style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '56',
                  style: TextStyle(
                    color: _C.orange,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    '/100',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Trend
            Row(
              children: const [
                Icon(Icons.trending_up_rounded, color: _C.orange, size: 15),
                SizedBox(width: 6),
                Text(
                  'Gradual increase over 30 days',
                  style: TextStyle(
                    color: _C.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
// ⑤  COMPOSITE METABOLIC SCORE CHART
// ─────────────────────────────────────────────────────────────────────────────
class _CompositeChart extends StatelessWidget {
  // X labels
  static const _xLabels = [
    '02/10',
    '02/12',
    '02/14',
    '02/16',
    '02/18',
    '02/20',
    '02/23',
  ];

  // Actual line data (7 points, range 0-60)
  static const _actual = [44.0, 46.0, 43.0, 49.0, 51.0, 48.0, 47.0];
  // Predicted (dashed)
  static const _pred = [44.5, 46.5, 43.5, 49.5, 51.5, 48.5, 47.5];
  // Baseline (flat dashed)
  static const _base = [46.0, 46.0, 46.0, 46.0, 46.0, 46.0, 46.0];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Composite Metabolic Score',
              style: TextStyle(
                color: _C.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _ChartPainter(
                  actual: _actual,
                  pred: _pred,
                  base: _base,
                  xLabels: _xLabels,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 10),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(_C.chartActual, 'Actual', solid: true),
                const SizedBox(width: 20),
                _legendItem(_C.chartPred, 'Predicted', solid: false),
                const SizedBox(width: 20),
                _legendItem(_C.chartBase, 'Baseline', solid: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color c, String label, {required bool solid}) {
    return Row(
      children: [
        CustomPaint(
          size: const Size(22, 2),
          painter: _LegendLinePainter(color: c, solid: solid),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _C.grey1, fontSize: 10.5)),
      ],
    );
  }
}

// Chart painter
class _ChartPainter extends CustomPainter {
  final List<double> actual;
  final List<double> pred;
  final List<double> base;
  final List<String> xLabels;
  const _ChartPainter({
    required this.actual,
    required this.pred,
    required this.base,
    required this.xLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const yMin = 0.0;
    const yMax = 60.0;
    const yLabels = [0, 15, 30, 45, 60];
    const leftPad = 28.0;
    const rightPad = 8.0;
    const topPad = 8.0;
    const bottomPad = 22.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    double xOf(int i) => leftPad + (i / (actual.length - 1)) * chartW;
    double yOf(double v) =>
        topPad + chartH - ((v - yMin) / (yMax - yMin)) * chartH;

    // ── grid lines + y labels
    final gridPaint = Paint()
      ..color = _C.chartGrid
      ..strokeWidth = 0.8;
    final yLabelStyle = const TextStyle(
      color: _C.grey2,
      fontSize: 9,
      fontWeight: FontWeight.w400,
    );

    for (final y in yLabels) {
      final dy = yOf(y.toDouble());
      canvas.drawLine(
        Offset(leftPad, dy),
        Offset(size.width - rightPad, dy),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(text: '$y', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 5, dy - tp.height / 2));
    }

    // ── vertical grid lines
    for (int i = 0; i < actual.length; i++) {
      canvas.drawLine(
        Offset(xOf(i), topPad),
        Offset(xOf(i), topPad + chartH),
        gridPaint,
      );
    }

    // ── baseline "Baseline" label
    final blY = yOf(base.first);
    final bTp = TextPainter(
      text: const TextSpan(
        text: '— Baseline',
        style: TextStyle(
          color: _C.chartBase,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    bTp.paint(canvas, Offset(xOf(3) + 4, blY - bTp.height - 3));

    // draw dashed line helper
    void drawDashed(
      List<double> data,
      Color color, {
      double width = 1.5,
      List<double> dash = const [4, 3],
    }) {
      final p = Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final pt = Offset(xOf(i), yOf(data[i]));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }

      // dash effect
      final metric = path.computeMetrics().first;
      double dist = 0;
      bool draw = true;
      int di = 0;
      while (dist < metric.length) {
        final segLen = dash[di % dash.length];
        final next = (dist + segLen).clamp(0, metric.length);
        if (draw) {
          final seg = metric.extractPath(dist, next.toDouble());
          canvas.drawPath(seg, p);
        }
        dist = next.toDouble();
        di++;
        draw = !draw;
      }
    }

    // ── baseline (dashed grey)
    drawDashed(base, _C.chartBase, width: 1.2, dash: const [5, 4]);

    // ── predicted (dashed light grey)
    drawDashed(pred, _C.chartPred, width: 1.2, dash: const [4, 3]);

    // ── actual (solid orange)
    final actPaint = Paint()
      ..color = _C.chartActual
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final actPath = Path();
    for (int i = 0; i < actual.length; i++) {
      final pt = Offset(xOf(i), yOf(actual[i]));
      if (i == 0)
        actPath.moveTo(pt.dx, pt.dy);
      else
        actPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(actPath, actPaint);

    // dots on actual
    final dotPaint = Paint()..color = _C.chartActual;
    for (int i = 0; i < actual.length; i++) {
      canvas.drawCircle(Offset(xOf(i), yOf(actual[i])), 3, dotPaint);
    }

    // ── x labels
    final xStyle = const TextStyle(
      color: _C.grey2,
      fontSize: 8.5,
      fontWeight: FontWeight.w400,
    );
    for (int i = 0; i < xLabels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: xStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xOf(i) - tp.width / 2, topPad + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => false;
}

class _LegendLinePainter extends CustomPainter {
  final Color color;
  final bool solid;
  const _LegendLinePainter({required this.color, required this.solid});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    if (solid) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        p,
      );
    } else {
      double x = 0;
      bool draw = true;
      while (x < size.width) {
        if (draw) {
          canvas.drawLine(
            Offset(x, size.height / 2),
            Offset((x + 4).clamp(0, size.width), size.height / 2),
            p,
          );
        }
        x += 4 + 3;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑥  AI INTERPRETATION
// ─────────────────────────────────────────────────────────────────────────────
class _AiInterpretation extends StatelessWidget {
  final bool showMedical;
  final VoidCallback onToggle;
  const _AiInterpretation({required this.showMedical, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // Header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _C.blueCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.blueBorder),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: _C.blue,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Interpretation',
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _interpSection(
              label: 'What was detected',
              text:
                  'SafeLife has identified a combination of subtle indicators that together suggest an emerging metabolic risk pattern. Your blood pressure estimation, activity levels, and resting metabolic indicators show a converging trend that warrants attention.',
            ),
            const SizedBox(height: 12),
            _interpSection(
              label: 'Why it matters',
              text:
                  'Metabolic syndrome is a cluster of conditions that increase risk of heart disease, stroke, and type 2 diabetes. Early intervention through lifestyle changes can significantly reduce this risk.',
            ),
            const SizedBox(height: 12),
            _interpSection(
              label: 'Short-term meaning',
              text:
                  'Individual indicators are within borderline ranges, but their combined trend suggests developing metabolic stress that lifestyle adjustments can address.',
            ),
            const SizedBox(height: 12),
            _interpSection(
              label: 'Long-term prediction',
              text:
                  'Without intervention, the current trajectory suggests increased metabolic risk over the next 6-12 months. Lifestyle modifications now can reverse this trend.',
            ),
            const SizedBox(height: 16),

            // Show Medical Explanation toggle
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Show Medical Explanation',
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      showMedical
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _C.grey1,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _interpSection({required String label, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _C.grey2,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: _C.grey1, fontSize: 12.5, height: 1.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑦  CONTRIBUTING FACTORS
// ─────────────────────────────────────────────────────────────────────────────
class _FactorRow {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool highImpact;
  const _FactorRow(this.icon, this.iconColor, this.label, this.highImpact);
}

const _kFactors = [
  _FactorRow(
    Icons.directions_run_rounded,
    Color(0xFFFF8A65),
    'Physical Activity',
    true,
  ),
  _FactorRow(Icons.bedtime_outlined, Color(0xFFCE93D8), 'Sleep Quality', true),
  _FactorRow(
    Icons.trending_up_rounded,
    Color(0xFF80DEEA),
    'Blood Pressure Trend',
    false,
  ),
  _FactorRow(
    Icons.monitor_heart_outlined,
    Color(0xFFA5D6A7),
    'Resting Heart Rate',
    false,
  ),
  _FactorRow(
    Icons.bar_chart_rounded,
    Color(0xFFFF8A65),
    'Activity Patterns',
    true,
  ),
];

class _ContributingFactors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Contributing Factors',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...List.generate(_kFactors.length, (i) {
              final f = _kFactors[i];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Icon(f.icon, color: f.iconColor, size: 17),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f.label,
                            style: const TextStyle(
                              color: _C.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Impact chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: f.highImpact
                                ? _C.highImpactBg
                                : _C.medImpactBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: f.highImpact
                                  ? _C.highImpactBrd
                                  : _C.medImpactBrd,
                            ),
                          ),
                          child: Text(
                            f.highImpact ? 'high impact' : 'medium impact',
                            style: TextStyle(
                              color: f.highImpact
                                  ? _C.highImpactTxt
                                  : _C.medImpactTxt,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _C.grey2,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (i < _kFactors.length - 1)
                    const Divider(
                      height: 1,
                      thickness: .5,
                      color: _C.cardBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑧  RECOMMENDED ACTIONS
// ─────────────────────────────────────────────────────────────────────────────
class _ActionItem {
  final String tag;
  final Color tagBg;
  final Color tagBrd;
  final Color tagTxt;
  final String text;
  const _ActionItem(this.tag, this.tagBg, this.tagBrd, this.tagTxt, this.text);
}

const _kActions = [
  _ActionItem(
    'Lifestyle',
    _C.lifestyleBg,
    _C.lifestyleBrd,
    _C.lifestyleTxt,
    'Start with 20-minute daily walks and gradually increase to 30-45 minutes of moderate activity.',
  ),
  _ActionItem(
    'Lifestyle',
    _C.lifestyleBg,
    _C.lifestyleBrd,
    _C.lifestyleTxt,
    'Prioritize sleep quality: aim for 7-8 hours with consistent timing.',
  ),
  _ActionItem(
    'Lifestyle',
    _C.lifestyleBg,
    _C.lifestyleBrd,
    _C.lifestyleTxt,
    'Consider a Mediterranean-style eating pattern, rich in whole grains, fruits, and healthy fats.',
  ),
  _ActionItem(
    'Monitoring',
    _C.monitorBg,
    _C.monitorBrd,
    _C.monitorTxt,
    'Track your daily steps and set a goal of 8,000+ steps per day.',
  ),
  _ActionItem(
    'Consultation',
    _C.consultBg,
    _C.consultBrd,
    _C.consultTxt,
    'Consider scheduling metabolic health screening (fasting blood glucose, lipid panel) with your physician.',
  ),
];

class _RecommendedActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const Text(
              'Recommended Actions',
              style: TextStyle(
                color: _C.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(_kActions.length, (i) {
              final a = _kActions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkmark circle
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: _C.green.withOpacity(.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.green, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: _C.green,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: a.tagBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: a.tagBrd),
                              ),
                              child: Text(
                                a.tag,
                                style: TextStyle(
                                  color: a.tagTxt,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              a.text,
                              style: const TextStyle(
                                color: _C.grey1,
                                fontSize: 12.5,
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
            }),
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.warnBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.warnBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _C.warnIcon,
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These are wellness suggestions, not medical prescriptions. Consult a healthcare professional for medical advice.',
                      style: TextStyle(
                        color: _C.warnIcon,
                        fontSize: 11.5,
                        height: 1.5,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// ⑨  DATA TRANSPARENCY
// ─────────────────────────────────────────────────────────────────────────────
class _DataTransparency extends StatelessWidget {
  static const _sources = [
    'Activity tracker',
    'Heart rate sensor',
    'Sleep monitor',
    'Blood pressure estimation',
    'Respiratory rate',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const Text(
              'Data Transparency',
              style: TextStyle(
                color: _C.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // Data Sources
            _rowLabel('Data Sources'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sources
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A28),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _C.grey3),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(color: _C.grey1, fontSize: 11.5),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),

            // Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _rowLabel('Duration Analyzed'),
                const Text(
                  '30 days',
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Accuracy confidence
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _rowLabel('Accuracy Confidence'),
                    const Text(
                      '80%',
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.80,
                    minHeight: 4,
                    backgroundColor: _C.grey3,
                    valueColor: AlwaysStoppedAnimation(_C.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Missing data warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.warnBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.warnBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: _C.warnIcon,
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Missing Data',
                          style: TextStyle(
                            color: _C.warnIcon,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Blood glucose data not available from wearable — clinical testing recommended',
                          style: TextStyle(
                            color: _C.warnIcon,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _rowLabel(String t) => Text(
    t,
    style: const TextStyle(
      color: _C.grey1,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ⑩  ESCALATION STATUS
// ─────────────────────────────────────────────────────────────────────────────
class _EscalationStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const Text(
              'Escalation Status',
              style: TextStyle(
                color: _C.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar with 4 segments
            Row(
              children: [
                // Segment 1 — green (Monitor, active)
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: _C.escGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                // Segment 2 — yellow (Notify User, active)
                Expanded(child: Container(height: 6, color: _C.escYellow)),
                const SizedBox(width: 3),
                // Segment 3 — grey (Suggest Medical)
                Expanded(child: Container(height: 6, color: _C.escGrey)),
                const SizedBox(width: 3),
                // Segment 4 — grey (Emergency)
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: _C.escGrey,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Labels
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Monitor',
                    style: TextStyle(
                      color: _C.escGreen,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Notify User',
                    style: TextStyle(
                      color: _C.escYellow,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Suggest\nMedical\nReview',
                    style: TextStyle(
                      color: _C.grey2,
                      fontSize: 9.5,
                      height: 1.3,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Emergency\nAlert Ready',
                    style: TextStyle(
                      color: _C.grey2,
                      fontSize: 9.5,
                      height: 1.3,
                    ),
                  ),
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
// ⑪  DEEP ANALYSIS
// ─────────────────────────────────────────────────────────────────────────────
class _AnalysisItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBrd;
  final String label;
  const _AnalysisItem(
    this.icon,
    this.iconColor,
    this.iconBg,
    this.iconBrd,
    this.label,
  );
}

const _kAnalysis = [
  _AnalysisItem(Icons.bar_chart_rounded, Color(0xFF5C8AFF), Color(0xFF0E1525),
      Color(0xFF1C2D55), 'Pattern Analysis'),
  _AnalysisItem(Icons.psychology_rounded, Color(0xFF26C6DA), Color(0xFF061818),
      Color(0xFF0A3030), 'AI Explanation'),
  _AnalysisItem(Icons.favorite_border_rounded, Color(0xFFEF5350),
      Color(0xFF200808), Color(0xFF401010), 'Prevention Guidance'),
  _AnalysisItem(Icons.description_outlined, Color(0xFF9090A8), Color(0xFF181828),
      Color(0xFF2A2A3A), 'Medical Preparation'),
];

class _DeepAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deep Analysis',
            style: TextStyle(
              color: _C.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_kAnalysis.length, (i) {
            final a = _kAnalysis[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  if (a.label == 'Pattern Analysis') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PatternAnalysisScreen(riskType: 'Metabolic Syndrome Risk')));
                  } else if (a.label == 'AI Explanation') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiExplanationScreen(riskType: 'Metabolic Syndrome Risk')));
                  } else if (a.label == 'Prevention Guidance') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PreventionGuidanceScreen(riskType: 'Metabolic Syndrome Risk')));
                  } else if (a.label == 'Medical Preparation') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalPreparationScreen(riskType: 'Metabolic Syndrome Risk')));
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: a.iconBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: a.iconBrd),
                        ),
                        child: Icon(a.icon, color: a.iconColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          a.label,
                          style: const TextStyle(
                            color: _C.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _C.grey2,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

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
  static const riskCard = Color(0xFFE8FAF0); // Light green for stable
  static const green = Color(0xFF4CAF50);
  static const greenBadge = Color(0xFFE8F5E9);
  static const greenText = Color(0xFF2E7D32);
  static const blue = Color(0xFF5C8AFF);
  static const blueCard = Color(0xFF0E1525);
  static const blueBorder = Color(0xFF1C2D55);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const grey3 = Color(0xFF2A2A3A);
  static const chartGrid = Color(0xFF1E1E2E);
  static const chartActual = Color(0xFF4CAF50);
  static const chartPred = Color(0xFF78909C);
  static const chartBase = Color(0xFF546E7A);
  // impact chip colours
  static const lowImpactBg = Color(0xFF0D1A10);
  static const lowImpactBrd = Color(0xFF1A3020);
  static const lowImpactTxt = Color(0xFF4CAF50);
  // recommended-action tag colours
  static const lifestyleBg = Color(0xFF0D2010);
  static const lifestyleBrd = Color(0xFF1A4020);
  static const lifestyleTxt = Color(0xFF66BB6A);
  static const monitorBg = Color(0xFF0D1A2A);
  static const monitorBrd = Color(0xFF1A3050);
  static const monitorTxt = Color(0xFF5C8AFF);
  // escalation bar
  static const escGreen = Color(0xFF4CAF50);
  static const escGrey = Color(0xFF37374A);
  // warning
  static const warnBg = Color(0xFF1E1600);
  static const warnBorder = Color(0xFF4A3800);
  static const warnIcon = Color(0xFFFFC107);
}

class ShockIndexAssessmentScreen extends StatefulWidget {
  const ShockIndexAssessmentScreen({super.key});

  @override
  State<ShockIndexAssessmentScreen> createState() =>
      _ShockIndexAssessmentScreenState();
}

class _ShockIndexAssessmentScreenState
    extends State<ShockIndexAssessmentScreen> {
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
            const DigiPillHeader(),
            const SizedBox(height: 14),
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
            _PageTitle(),
            const SizedBox(height: 16),
            _RiskScoreCard(),
            const SizedBox(height: 16),
            _TrendChart(),
            const SizedBox(height: 16),
            _AiInterpretation(
              showMedical: _showMedicalExp,
              onToggle: () =>
                  setState(() => _showMedicalExp = !_showMedicalExp),
            ),
            const SizedBox(height: 16),
            _ContributingFactors(),
            const SizedBox(height: 16),
            _RecommendedActions(),
            const SizedBox(height: 16),
            _DataTransparency(),
            const SizedBox(height: 16),
            _EscalationStatus(),
            const SizedBox(height: 24),
            _DeepAnalysis(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

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
              color: const Color(0xFF0D2010),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A4020)),
            ),
            child: const Icon(
              Icons.speed_rounded,
              color: _C.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shock Index Assessment',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Circulatory',
                style: TextStyle(color: _C.grey1, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _C.greenBadge,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.green.withOpacity(.3), width: 1),
                  ),
                  child: const Text(
                    'Stable',
                    style: TextStyle(
                      color: _C.greenText,
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
                      'AI Confidence: 91%',
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '0.62',
                  style: TextStyle(
                    color: _C.green,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    'ratio',
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
            Row(
              children: const [
                Icon(Icons.horizontal_rule_rounded, color: _C.green, size: 15),
                SizedBox(width: 6),
                Text(
                  'Consistently within normal range',
                  style: TextStyle(
                    color: _C.green,
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

class _TrendChart extends StatelessWidget {
  static const _xLabels = ['10/10', '11/10', '12/10', '13/10', '14/10', '15/10', '16/10'];
  static const _actual = [0.62, 0.63, 0.61, 0.64, 0.62, 0.60, 0.62];
  static const _pred = [0.62, 0.62, 0.62, 0.62, 0.62, 0.62, 0.62];
  static const _base = [0.62, 0.62, 0.62, 0.62, 0.62, 0.62, 0.62];

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
              'HR/SBP Ratio',
              style: TextStyle(color: _C.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _ChartPainter(actual: _actual, pred: _pred, base: _base, xLabels: _xLabels),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 10),
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
          size: const Size(20, 2),
          painter: _LegendLinePainter(color: c, solid: solid),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _C.grey1, fontSize: 10.5)),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> actual;
  final List<double> pred;
  final List<double> base;
  final List<String> xLabels;
  _ChartPainter({required this.actual, required this.pred, required this.base, required this.xLabels});

  @override
  void paint(Canvas canvas, Size size) {
    const yMin = 0.0;
    const yMax = 1.0;
    const yLabels = [0, 0.25, 0.5, 0.75, 1.0];
    const leftPad = 28.0;
    const rightPad = 8.0;
    const topPad = 8.0;
    const bottomPad = 20.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    double xOf(int i) => leftPad + (i / (actual.length - 1)) * chartW;
    double yOf(double v) => topPad + chartH - ((v - yMin) / (yMax - yMin)) * chartH;

    final gridPaint = Paint()..color = _C.chartGrid..strokeWidth = 0.8;
    final labelStyle = const TextStyle(color: _C.grey2, fontSize: 9);

    for (final y in yLabels) {
      final dy = yOf(y.toDouble());
      canvas.drawLine(Offset(leftPad, dy), Offset(size.width - rightPad, dy), gridPaint);
      final tp = TextPainter(text: TextSpan(text: y.toStringAsFixed(2), style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 5, dy - tp.height / 2));
    }

    // Actual path
    final actPaint = Paint()..color = _C.chartActual..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final actPath = Path();
    for (int i = 0; i < actual.length; i++) {
        if (i == 0) actPath.moveTo(xOf(i), yOf(actual[i]));
        else actPath.lineTo(xOf(i), yOf(actual[i]));
    }
    canvas.drawPath(actPath, actPaint);

    // X Labels
    for (int i = 0; i < xLabels.length; i++) {
        final tp = TextPainter(text: TextSpan(text: xLabels[i], style: labelStyle), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(xOf(i) - tp.width / 2, topPad + chartH + 5));
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _LegendLinePainter extends CustomPainter {
  final Color color;
  final bool solid;
  _LegendLinePainter({required this.color, required this.solid});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 2;
    if (solid) canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), p);
    else {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, size.height/2), Offset(x+3, size.height/2), p);
        x += 6;
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

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
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: _C.blueCard, shape: BoxShape.circle, border: Border.all(color: _C.blueBorder)),
                  child: const Icon(Icons.info_outline_rounded, color: _C.blue, size: 15),
                ),
                const SizedBox(width: 10),
                const Text('AI Interpretation', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            _section('What was detected', 'SafeLife continuously monitors your shock index -- the ratio between heart rate and systolic blood pressure. Your current index of 0.62 is well within the healthy adult range (0.5 to 0.7).'),
            _section('Why it matters', 'Shock index is a sensitive early indicator of circulatory stress. While individual heart rate or blood pressure readings might appear normal, their ratio can provide an earlier warning of physiological stress.'),
            _section('Short-term meaning', 'Your circulatory system shows excellent stability. Your heart rate is well-compensated for your blood pressure.'),
            _section('Long-term prediction', 'Current monitoring suggests a highly stable circulatory profile. Continued monitoring will detect any deviations from this healthy baseline.'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF0D0D18), borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.cardBorder)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show Medical Exploration', style: TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    Icon(showMedical ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _C.grey1, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _C.grey2, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: _C.grey1, fontSize: 12.5, height: 1.5)),
        ],
      ),
    );
  }
}

class _ContributingFactors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final factors = [
      {'label': 'Heart Rate Stability', 'low': true},
      {'label': 'Hydration Levels', 'low': true},
      {'label': 'Activity Recovery', 'low': true},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Contributing Factors', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            ...factors.map((f) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      const Icon(Icons.remove, color: _C.green, size: 17),
                      const SizedBox(width: 12),
                      Expanded(child: Text(f['label'] as String, style: const TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w500))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _C.lowImpactBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _C.lowImpactBrd)),
                        child: const Text('low impact', style: TextStyle(color: _C.lowImpactTxt, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: _C.grey2, size: 18),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: .5, color: _C.cardBorder, indent: 16, endIndent: 16),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class _RecommendedActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'tag': 'Lifestyle', 'text': 'Continue maintaining your current hydration habits.'},
      {'tag': 'Monitoring', 'text': 'SafeLife will continue automated monitoring. No action required.'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommended Actions', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...actions.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF0D0D18), borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.cardBorder)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24, margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(color: _C.green.withOpacity(.15), shape: BoxShape.circle, border: Border.all(color: _C.green, width: 1.5)),
                      child: const Icon(Icons.check_rounded, color: _C.green, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                color: a['tag'] == 'Lifestyle' ? _C.lifestyleBg : _C.monitorBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: a['tag'] == 'Lifestyle' ? _C.lifestyleBrd : _C.monitorBrd)),
                            child: Text(a['tag']!, style: TextStyle(color: a['tag'] == 'Lifestyle' ? _C.lifestyleTxt : _C.monitorTxt, fontSize: 10.5, fontWeight: FontWeight.w600)),
                          ),
                          Text(a['text']!, style: const TextStyle(color: _C.grey1, fontSize: 12.5, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _C.warnBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.warnBorder)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: _C.warnIcon, size: 15),
                  SizedBox(width: 8),
                  Expanded(child: Text('These are wellness suggestions, not medical prescriptions. Consult a healthcare professional for medical advice.', style: TextStyle(color: _C.warnIcon, fontSize: 11.5, height: 1.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTransparency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sources = ['Continuous heart rate sensor', 'Blood pressure estimation', 'Activity tracker'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Transparency', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const Text('Data Sources', style: TextStyle(color: _C.grey1, fontSize: 12.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: sources.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF1A1A28), borderRadius: BorderRadius.circular(8), border: Border.all(color: _C.grey3)),
                child: Text(s, style: const TextStyle(color: _C.grey1, fontSize: 11.5)),
              )).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration Analyzed', style: TextStyle(color: _C.grey1, fontSize: 12.5, fontWeight: FontWeight.w500)),
                const Text('Continuous', style: TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Accuracy Confidence', style: TextStyle(color: _C.grey1, fontSize: 12.5, fontWeight: FontWeight.w500)),
                const Text('91%', style: TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(value: 0.91, minHeight: 4, backgroundColor: _C.grey3, valueColor: AlwaysStoppedAnimation(_C.green)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscalationStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escalation Status', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: _C.escGreen, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 6, color: _C.escGrey)),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 6, color: _C.escGrey)),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: _C.escGrey, borderRadius: BorderRadius.circular(4)))),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(child: Text('Monitor', style: TextStyle(color: _C.escGreen, fontSize: 9.5, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Notify User', style: TextStyle(color: _C.grey2, fontSize: 9.5))),
                Expanded(child: Text('Suggest Medical', style: TextStyle(color: _C.grey2, fontSize: 9.5))),
                Expanded(child: Text('Emergency', style: TextStyle(color: _C.grey2, fontSize: 9.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeepAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Pattern Analysis', 'icon': Icons.bar_chart_rounded, 'color': Color(0xFF5C8AFF)},
      {'label': 'AI Explanation', 'icon': Icons.psychology_rounded, 'color': Color(0xFF26C6DA)},
      {'label': 'Prevention Guidance', 'icon': Icons.favorite_border_rounded, 'color': Color(0xFFEF5350)},
      {'label': 'Medical Preparation', 'icon': Icons.description_outlined, 'color': Color(0xFF9090A8)},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deep Analysis', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                if (item['label'] == 'Pattern Analysis') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PatternAnalysisScreen(riskType: 'Shock Index Assessment')));
                } else if (item['label'] == 'AI Explanation') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiExplanationScreen(riskType: 'Shock Index Assessment')));
                } else if (item['label'] == 'Prevention Guidance') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PreventionGuidanceScreen(riskType: 'Shock Index Assessment')));
                } else if (item['label'] == 'Medical Preparation') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalPreparationScreen(riskType: 'Shock Index Assessment')));
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.cardBorder)),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: (item['color'] as Color).withOpacity(.2))),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(item['label'] as String, style: const TextStyle(color: _C.white, fontSize: 14, fontWeight: FontWeight.w600))),
                    const Icon(Icons.chevron_right_rounded, color: _C.grey2, size: 20),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}

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
  static const yellow = Color(0xFFFFD54F);
  static const yellowText = Color(0xFFE8B84B);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const blue = Color(0xFF5C8AFF);
  static const highImpactBg = Color(0xFF2A1505);
  static const highImpactBrd = Color(0xFF5A2E0A);
  static const highImpactTxt = Color(0xFFFF8C00);
  static const medImpactBg = Color(0xFF1A1E2A);
  static const medImpactBrd = Color(0xFF2A3050);
  static const medImpactTxt = Color(0xFF5C8AFF);
  static const lifestyleBg = Color(0xFF0D2010);
  static const lifestyleBrd = Color(0xFF1A4020);
  static const lifestyleTxt = Color(0xFF66BB6A);
  static const monitorBg = Color(0xFF0D1A2A);
  static const monitorBrd = Color(0xFF1A3050);
  static const monitorTxt = Color(0xFF5C8AFF);
  static const consultBg = Color(0xFF2A1505);
  static const consultBrd = Color(0xFF5A2E0A);
  static const consultTxt = Color(0xFFFF8C00);
  static const chartGrid = Color(0xFF1E1E2E);
  static const chartLine = Color(0xFFFFCC80);
  static const escGreen = Color(0xFF4CAF50);
  static const escYellow = Color(0xFFFFD54F);
  static const escGrey = Color(0xFF37374A);
  static const warnBg = Color(0xFF201A0D);
  static const warnBorder = Color(0xFF403010);
  static const warnIcon = Color(0xFFFFD54F);
}

class BloodPressureRiskScreen extends StatefulWidget {
  const BloodPressureRiskScreen({super.key});
  @override
  State<BloodPressureRiskScreen> createState() => _BloodPressureRiskScreenState();
}

class _BloodPressureRiskScreenState extends State<BloodPressureRiskScreen> {
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
              child: Text('HI, USER', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.6)),
            ),
            const SizedBox(height: 16),
            const _PageTitle(),
            const SizedBox(height: 16),
            const _ScoreCard(),
            const SizedBox(height: 16),
            const _TrendChart(),
            const SizedBox(height: 16),
            _AiInterpretation(showMedical: _showMedicalExp, onToggle: () => setState(() => _showMedicalExp = !_showMedicalExp)),
            const SizedBox(height: 16),
            const _ContributingFactors(),
            const SizedBox(height: 16),
            const _RecommendedActions(),
            const SizedBox(height: 16),
            const _DataTransparency(),
            const SizedBox(height: 16),
            const _EscalationStatus(),
            const SizedBox(height: 24),
            const _DeepAnalysis(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF2A1E05), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF5A3A10))),
            child: const Icon(Icons.favorite_rounded, color: _C.yellow, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blood Pressure Risk', style: TextStyle(color: _C.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text('Cardiovascular', style: TextStyle(color: _C.grey1, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFECB3), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFD54F).withOpacity(.3))),
                  child: const Text('Monitor', style: TextStyle(color: Color(0xFF795548), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const Row(children: [Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF888888), size: 14), SizedBox(width: 4), Text('AI Confidence: 87%', style: TextStyle(color: Color(0xFF555555), fontSize: 12))]),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('128/82', style: TextStyle(color: Color(0xFFE65100), fontSize: 36, fontWeight: FontWeight.w800, height: 1)),
                SizedBox(width: 8),
                Padding(padding: EdgeInsets.only(bottom: 6), child: Text('mmHg est.', style: TextStyle(color: Color(0xFF888888), fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
            const SizedBox(height: 8),
            const Row(children: [Icon(Icons.trending_up_rounded, color: Color(0xFFFF9800), size: 15), SizedBox(width: 6), Text('Slight upward trend over 14 days', style: TextStyle(color: Color(0xFFFF9800), fontSize: 12, fontWeight: FontWeight.w500))]),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart();
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
            const Text('Estimated BP Trend', style: TextStyle(color: _C.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(height: 140, child: CustomPaint(painter: _ChartPainter(), size: Size.infinite)),
            const SizedBox(height: 12),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [_LegendItem(_C.yellow, 'Actual'), SizedBox(width: 16), _LegendItem(_C.grey2, 'Predicted'), SizedBox(width: 16), _LegendItem(_C.grey1, 'Baseline')]),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = _C.chartGrid..strokeWidth = 1;
    final yLabels = [0, 20, 40, 60, 80, 100, 120, 140];
    final chartH = size.height - 20;
    final chartW = size.width - 30;
    const left = 25.0;
    for (var i = 0; i < yLabels.length; i++) {
      final y = chartH - (yLabels[i] / 140) * chartH;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(text: TextSpan(text: '${yLabels[i]}', style: const TextStyle(color: _C.grey2, fontSize: 9)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(left - tp.width - 5, y - tp.height / 2));
    }
    final path = Path();
    path.moveTo(left, chartH * 0.2);
    path.lineTo(left + chartW * 0.2, chartH * 0.22);
    path.lineTo(left + chartW * 0.4, chartH * 0.18);
    path.lineTo(left + chartW * 0.6, chartH * 0.21);
    path.lineTo(left + chartW * 0.8, chartH * 0.19);
    path.lineTo(left + chartW, chartH * 0.2);
    canvas.drawPath(path, Paint()..color = _C.chartLine..style = PaintingStyle.stroke..strokeWidth = 2);
  }
  @override bool shouldRepaint(_) => false;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 12, height: 2, color: color), const SizedBox(width: 6), Text(label, style: const TextStyle(color: _C.grey1, fontSize: 10))]);
  }
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
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.psychology_rounded, color: _C.blue, size: 18), SizedBox(width: 8), Text('AI Interpretation', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700))]),
            const SizedBox(height: 12),
            _section('What was detected', 'SafeLife has detected a gradual upward trend in your estimated blood pressure indicators over the past two weeks. Your pulse wave patterns and heart rate variability suggest mild systolic elevation.'),
            _section('Why it matters', 'Sustained blood pressure elevation, even mild, increases long-term cardiovascular risk. Early detection allows for lifestyle interventions before clinical hypertension develops.'),
            _section('Short-term meaning', 'Your current readings are in the pre-hypertension range. This is not an emergency but warrants monitoring.'),
            _section('Long-term prediction', 'If the current trend continues, clinical blood pressure monitoring within 4-6 weeks is advisable to confirm or rule out developing hypertension.'),
            const SizedBox(height: 12),
            InkWell(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF1A2235), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Show Medical Explanation', style: TextStyle(color: _C.blue, fontSize: 13, fontWeight: FontWeight.w600)), Icon(showMedical ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: _C.blue, size: 20)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _C.grey1, fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(content, style: const TextStyle(color: _C.white, fontSize: 12.5, height: 1.4))]),
    );
  }
}

class _ContributingFactors extends StatelessWidget {
  const _ContributingFactors();
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
            const Text('Contributing Factors', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _factor(Icons.bedtime_outlined, 'Sleep Quality', 'High Impact', _C.highImpactBg, _C.highImpactBrd, _C.highImpactTxt),
            const SizedBox(height: 10),
            _factor(Icons.directions_run_rounded, 'Physical Activity', 'Medium Impact', _C.medImpactBg, _C.medImpactBrd, _C.medImpactTxt),
            const SizedBox(height: 10),
            _factor(Icons.monitor_heart_outlined, 'Resting Heart Rate', 'Medium Impact', _C.medImpactBg, _C.medImpactBrd, _C.medImpactTxt),
            const SizedBox(height: 10),
            _factor(Icons.psychology_outlined, 'Stress Indicators', 'High Impact', _C.highImpactBg, _C.highImpactBrd, _C.highImpactTxt),
          ],
        ),
      ),
    );
  }
  Widget _factor(IconData icon, String label, String impact, Color bg, Color brd, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF0D121F), borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.cardBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, color: _C.yellowText, size: 16), const SizedBox(width: 10), Text(label, style: const TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w500))]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: brd)),
            child: Row(children: [Text(impact, style: TextStyle(color: txt, fontSize: 10, fontWeight: FontWeight.w600)), const SizedBox(width: 4), Icon(Icons.keyboard_arrow_down, color: txt, size: 14)]),
          ),
        ],
      ),
    );
  }
}

class _RecommendedActions extends StatelessWidget {
  const _RecommendedActions();
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
            const Text('Recommended Actions', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _action('Lifestyle', 'Aim for 7-8 hours of consistent sleep. Consider setting a bedtime reminder.', _C.lifestyleBg, _C.lifestyleBrd, _C.lifestyleTxt),
            const SizedBox(height: 12),
            _action('Lifestyle', 'Try to include 30 minutes of moderate activity daily, such as brisk walking.', _C.lifestyleBg, _C.lifestyleBrd, _C.lifestyleTxt),
            const SizedBox(height: 12),
            _action('Monitoring', 'Consider using a validated home blood pressure monitor to cross-reference readings.', _C.monitorBg, _C.monitorBrd, _C.monitorTxt),
            const SizedBox(height: 12),
            _action('Consultation', 'If elevated patterns persist for 2+ weeks, consider scheduling a check-up with your physician.', _C.consultBg, _C.consultBrd, _C.consultTxt),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _C.warnBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.warnBorder)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: _C.warnIcon, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('These are wellness suggestions, not medical prescriptions. Consult a healthcare professional for medical advice.', style: TextStyle(color: Color(0xFFFFE082), fontSize: 11, height: 1.4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _action(String tag, String desc, Color bg, Color brd, Color txt) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1F26), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFF2D3545), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: brd)), child: Text(tag, style: TextStyle(color: txt, fontSize: 10, fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: _C.white, fontSize: 12.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataTransparency extends StatelessWidget {
  const _DataTransparency();
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
            const Text('Data Transparency', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const Text('Data Sources', style: TextStyle(color: _C.grey1, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [_source('Optical heart rate sensor'), _source('Accelerometer'), _source('Pulse oximeter'), _source('Sleep tracker')]),
            const SizedBox(height: 16),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Duration Analyzed', style: TextStyle(color: _C.grey1, fontSize: 12)), Text('30 days continuous', style: TextStyle(color: _C.white, fontSize: 12, fontWeight: FontWeight.w500))]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Accuracy Confidence', style: TextStyle(color: _C.grey1, fontSize: 12)),
                Row(children: [Container(width: 80, height: 6, decoration: BoxDecoration(color: _C.escGrey, borderRadius: BorderRadius.circular(3)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.87, child: Container(decoration: BoxDecoration(color: _C.yellow, borderRadius: BorderRadius.circular(3))))), const SizedBox(width: 8), const Text('87%', style: TextStyle(color: _C.white, fontSize: 12, fontWeight: FontWeight.w600))]),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E1600), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF4A3800))),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Missing Data', style: TextStyle(color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.w700)), Text('3 nights of incomplete sleep data detected', style: TextStyle(color: Color(0xFFFFC107), fontSize: 10, height: 1.3))])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _source(String text) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1A1A2A), borderRadius: BorderRadius.circular(6), border: Border.all(color: _C.cardBorder)), child: Text(text, style: const TextStyle(color: _C.grey1, fontSize: 10.5)));
  }
}

class _EscalationStatus extends StatelessWidget {
  const _EscalationStatus();
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
                Expanded(child: Container(height: 5, decoration: const BoxDecoration(color: _C.escGreen, borderRadius: BorderRadius.horizontal(left: Radius.circular(4))))),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 5, color: _C.escYellow)),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 5, color: _C.escGrey)),
                const SizedBox(width: 3),
                Expanded(child: Container(height: 5, decoration: const BoxDecoration(color: _C.escGrey, borderRadius: BorderRadius.horizontal(right: Radius.circular(4))))),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(child: Text('Monitor', style: TextStyle(color: _C.escGreen, fontSize: 9.5))),
                Expanded(child: Text('Notify User', style: TextStyle(color: _C.yellowText, fontSize: 9.5))),
                Expanded(child: Text('Suggest Medical Review', style: TextStyle(color: _C.grey2, fontSize: 9.5))),
                Expanded(child: Text('Emergency Alert Ready', style: TextStyle(color: _C.grey2, fontSize: 9.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeepAnalysis extends StatelessWidget {
  const _DeepAnalysis();
  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Pattern Analysis', 'icon': Icons.show_chart_rounded, 'color': _C.blue},
      {'label': 'AI Explanation', 'icon': Icons.psychology_rounded, 'color': const Color(0xFF26C6DA)},
      {'label': 'Prevention Guidance', 'icon': Icons.favorite_border_rounded, 'color': const Color(0xFFEF5350)},
      {'label': 'Medical Preparation', 'icon': Icons.description_outlined, 'color': _C.grey1},
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PatternAnalysisScreen(riskType: 'Blood Pressure')));
                } else if (item['label'] == 'AI Explanation') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiExplanationScreen(riskType: 'Blood Pressure')));
                } else if (item['label'] == 'Prevention Guidance') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PreventionGuidanceScreen(riskType: 'Blood Pressure')));
                } else if (item['label'] == 'Medical Preparation') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalPreparationScreen(riskType: 'Blood Pressure')));
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.cardBorder)),
                child: Row(
                  children: [
                    Container(width: 38, height: 38, decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(item['label'] as String, style: const TextStyle(color: _C.white, fontSize: 14, fontWeight: FontWeight.w600))),
                    const Icon(Icons.chevron_right_rounded, color: _C.grey2, size: 20),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

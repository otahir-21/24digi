import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _C {
  _C._();
  static const bg = Color(0xFF090910);
  static const card = Color(0xFF111118);
  static const cardBorder = Color(0xFF222230);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const grey2 = Color(0xFF55556A);
  static const blue = Color(0xFF5C8AFF);
  static const blueCard = Color(0xFF0E1525);
  static const blueBorder = Color(0xFF1C2D55);
  static const orange = Color(0xFFFF8C00);
  static const itemBg = Color(0xFF1A1A28);
  static const logicBg = Color(0xFFEEF2FF);
}

class AiExplanationScreen extends StatelessWidget {
  final String riskType;
  const AiExplanationScreen({super.key, this.riskType = 'Metabolic Risk'});

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

            // Greeting/Title Section
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

            _PageHeader(riskType: riskType),
            const SizedBox(height: 20),

            const _CalculationSteps(),
            const SizedBox(height: 24),

            const _SignalsUsed(),
            const SizedBox(height: 24),

            const _ModelLogic(),
            const SizedBox(height: 24),

            const _ScientificBacking(),
            const SizedBox(height: 24),

            const _Footer(),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String riskType;
  const _PageHeader({required this.riskType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.blueCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.blueBorder),
            ),
            child: const Icon(Icons.psychology_rounded, color: _C.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Explanation',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                riskType,
                style: const TextStyle(color: _C.grey1, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculationSteps extends StatelessWidget {
  const _CalculationSteps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_suggest_rounded, color: _C.blue, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How SafeLife Calculates This',
                      style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Understanding the AI behind your assessment',
                      style: TextStyle(color: _C.grey1, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SafeLife uses a multi-factor risk model that weights activity patterns, cardiovascular indicators, and sleep quality to estimate metabolic syndrome risk. The model identifies converging risk factors that individually may appear borderline but collectively indicate metabolic stress.',
                style: TextStyle(color: _C.grey1, fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            _stepItem('1', 'Data Collection', 'Continuous biometric data from your wearable sensors'),
            _stepLine(),
            _stepItem('2', 'Signal Processing', 'Noise reduction, artifact removal, and feature extraction'),
            _stepLine(),
            _stepItem('3', 'Pattern Analysis', 'AI identifies trends, anomalies, and predictive signals'),
            _stepLine(),
            _stepItem('4', 'Risk Assessment', 'Risk level determined using multi-factor assessment model'),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(String num, String title, String desc) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _C.orange.withOpacity(.1),
            border: Border.all(color: _C.orange.withOpacity(.3)),
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(color: _C.orange, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _C.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(desc, style: const TextStyle(color: _C.grey1, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 11.5),
      child: Container(width: 1, height: 16, color: _C.orange.withOpacity(.2)),
    );
  }
}

class _SignalsUsed extends StatelessWidget {
  const _SignalsUsed();

  @override
  Widget build(BuildContext context) {
    final signals = [
      'Activity intensity and duration',
      'Sedentary time analysis',
      'Blood pressure trends',
      'Heart rate variability',
      'Sleep quality and duration',
      'Resting metabolic rate estimation',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns_rounded, color: _C.blue, size: 18),
                const SizedBox(width: 10),
                const Text('Signals Used', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ...signals.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.itemBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: _C.orange, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(s, style: const TextStyle(color: _C.grey1, fontSize: 12.5)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ModelLogic extends StatelessWidget {
  const _ModelLogic();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined, color: _C.blue, size: 18),
                const SizedBox(width: 10),
                const Text('Prediction Model Logic', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.logicBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logicLabel('Input Layer'),
                  const SizedBox(height: 8),
                  _logicTag('Activity intensity and duration'),
                  _logicTag('Sedentary time analysis'),
                  _logicTag('Blood pressure trends'),
                  
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: SizedBox(height: 20, child: VerticalDivider(color: _C.blue, thickness: 1)),
                  ),

                  _logicLabel('Processing'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _logicTag('Baseline Comparison'),
                      const SizedBox(width: 6),
                      _logicTag('Trend Analysis'),
                    ],
                  ),
                  _logicTag('Pattern Detection'),

                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: SizedBox(height: 20, child: VerticalDivider(color: _C.blue, thickness: 1)),
                  ),

                  _logicLabel('Output'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _outputBox('Risk: 56/100', const Color(0xFFFFF3E0), _C.orange),
                      const SizedBox(width: 8),
                      _outputBox('Confidence: 81%', const Color(0xFFE3F2FD), _C.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logicLabel(String t) => Text(t, style: const TextStyle(color: _C.blue, fontSize: 11, fontWeight: FontWeight.w600));

  Widget _logicTag(String t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _C.blue.withOpacity(.1)),
      ),
      child: Text(t, style: const TextStyle(color: _C.blue, fontSize: 10.5, fontWeight: FontWeight.w500)),
    );
  }

  Widget _outputBox(String t, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(t, style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _ScientificBacking extends StatelessWidget {
  const _ScientificBacking();

  @override
  Widget build(BuildContext context) {
    final references = [
      '[1] The Lancet (2023): Wearable-detected metabolic risk',
      '[2] IDF Metabolic Syndrome Definition',
      '[3] AHA/NHLBI Scientific Statement on Metabolic Syndrome',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: _C.blue, size: 18),
                const SizedBox(width: 10),
                const Text('Scientific Backing', style: TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ...references.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.itemBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(r, style: const TextStyle(color: _C.grey1, fontSize: 12.5)),
              ),
            )),
            const SizedBox(height: 8),
            const Text(
              'References are provided for transparency. SafeLife\'s models are inspired by but not identical to cited research methodologies.',
              style: TextStyle(color: _C.grey2, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _C.itemBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.sync_rounded, color: _C.grey2, size: 16),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Model last updated: February 23, 2026 at 12:30 PM',
                style: TextStyle(color: _C.grey1, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

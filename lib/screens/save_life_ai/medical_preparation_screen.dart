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
  static const headerBlue = Color(0xFF2962FF);
  static const riskOrange = Color(0xFFFF9100);
}

class MedicalPreparationScreen extends StatelessWidget {
  final String riskType;
  const MedicalPreparationScreen({super.key, this.riskType = 'Metabolic Risk'});

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
              child: Text('HI, USER',
                  style: TextStyle(
                      color: _C.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6)),
            ),
            const SizedBox(height: 16),
            _PageHeader(
              title: 'Medical Preparation',
              subtitle: riskType,
              icon: Icons.description_outlined,
              iconColor: _C.blue,
            ),
            const SizedBox(height: 20),
            const _IntroBox(),
            const SizedBox(height: 20),
            _HealthSummaryReport(riskType: riskType),
            const SizedBox(height: 16),
            const _AnomaliesSection(),
            const SizedBox(height: 16),
            const _QuestionsSection(),
            const SizedBox(height: 16),
            const _ActionButton(
              icon: Icons.file_download_outlined,
              title: 'Export Health Summary',
              subtitle: 'Download PDF report for your doctor',
            ),
            const SizedBox(height: 10),
            const _ActionButton(
              icon: Icons.print_outlined,
              title: 'Print Summary',
              subtitle: 'Print-friendly format',
            ),
            const SizedBox(height: 24),
            const _DisclaimerBox(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medical Preparation',
                style: TextStyle(
                    color: _C.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: const TextStyle(color: _C.grey1, fontSize: 13)),
          ],
        ),
      ]),
    );
  }
}

class _IntroBox extends StatelessWidget {
  const _IntroBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Prepare for your doctor visit with a comprehensive summary of your SafeLife health data. Share this information with your healthcare provider for a more informed consultation.',
          style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}

class _HealthSummaryReport extends StatelessWidget {
  final String riskType;
  const _HealthSummaryReport({required this.riskType});

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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: _C.headerBlue,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Health Summary Report',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Text('Generated by SafeLife AI — February 23, 2026',
                            style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _summaryCard('Condition', riskType)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _summaryCard('Risk Level', 'Elevated Risk',
                              valueColor: _C.riskOrange)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _summaryCard('Primary Metric', '56 /100')),
                      const SizedBox(width: 10),
                      Expanded(child: _summaryCard('Monitoring Period', '30 days')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('AI Assessment Summary',
                      style: TextStyle(color: _C.grey2, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                   Text(
                    'SafeLife has identified a combination of subtle indicators that together suggest an emerging ${riskType.toLowerCase()} pattern. Your biometric trends and background variables show a converging pattern that warrants professional attention.',
                    style: const TextStyle(color: _C.white, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text('Trend Direction',
                      style: TextStyle(color: _C.grey2, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Text('Gradual increase over 30 days',
                      style: TextStyle(color: _C.white, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, {Color valueColor = _C.white}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2632),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _C.grey2, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AnomaliesSection extends StatelessWidget {
  const _AnomaliesSection();

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
                const Icon(Icons.warning_amber_rounded, color: _C.riskOrange, size: 20),
                const SizedBox(width: 8),
                const Text('Key Anomalies & Observations',
                    style: TextStyle(
                        color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _anomalyItem(1, 'Physical Activity', 'Your daily activity has decreased 30% over the past month, reducing metabolic efficiency.'),
            _anomalyItem(2, 'Sleep Quality', 'Poor sleep is strongly linked to metabolic disruption and insulin resistance.'),
            _anomalyItem(3, 'Blood Pressure Trend', 'Mild blood pressure elevation is a component of metabolic syndrome.'),
            _anomalyItem(4, 'Resting Heart Rate', 'Elevated RHR may indicate reduced cardiovascular efficiency.'),
            _anomalyItem(5, 'Activity Patterns', 'Prolonged sedentary periods have increased, affecting metabolic rate.'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16202A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF243447)),
              ),
              child: const Text(
                'Data Limitations:\nBlood glucose data not available from wearable — clinical testing recommended',
                style: TextStyle(color: _C.grey1, fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _anomalyItem(int num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2632),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF323D4D)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF9C4), shape: BoxShape.circle),
              child: Text('$num',
                  style: const TextStyle(
                      color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(color: _C.grey1, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionsSection extends StatelessWidget {
  const _QuestionsSection();

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
            const Text('Suggested Questions for Your Doctor',
                style: TextStyle(
                    color: _C.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _questionItem('Based on my wearable data showing 56/100, should I undergo clinical testing for metabolic risk?', true),
            _questionItem('What lifestyle changes would you recommend given these trends?', true),
            _questionItem('How often should I follow up on this condition?', false),
            _questionItem('Are there any clinical tests you\'d recommend to validate these findings?', false),
          ],
        ),
      ),
    );
  }

  Widget _questionItem(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2632),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
                checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: checked ? _C.blue : _C.grey2,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: _C.white, fontSize: 12.5))),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB), // Light grey background like in design
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'This report is generated by SafeLife AI based on wearable biometric data. It is not a medical diagnosis. Share with your healthcare provider for professional assessment.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
      ),
    );
  }
}

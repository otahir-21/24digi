import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _C {
  _C._();
  static const bg = Color(0xFF090910);
  static const card = Color(0xFF111118);
  static const cardBorder = Color(0xFF222230);
  static const white = Color(0xFFE8E8F0);
  static const grey1 = Color(0xFF9090A8);
  static const blue = Color(0xFF5C8AFF);
}

class PreventionGuidanceScreen extends StatelessWidget {
  final String riskType;
  const PreventionGuidanceScreen({super.key, this.riskType = 'Metabolic Risk'});

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
              title: 'Prevention Guidance',
              subtitle: riskType,
              icon: Icons.favorite_border_rounded,
              iconColor: _C.blue,
            ),
            const SizedBox(height: 20),
            _IntroBox(riskType: riskType),
            const SizedBox(height: 16),
            const _HabitSection(
              title: 'Immediate Habits',
              subtitle: 'Start today',
              icon: Icons.flash_on_rounded,
              iconBg: Color(0xFFE8F5E9),
              iconColor: Color(0xFF4CAF50),
              items: [
                'Take a 10-minute walk after each meal today',
                'Replace one sugary drink with water',
                'Set a timer to stand and move every 45 minutes',
              ],
            ),
            const SizedBox(height: 16),
            const _HabitSection(
              title: 'Weekly Improvements',
              subtitle: 'Build this week',
              icon: Icons.calendar_today_rounded,
              iconBg: Color(0xFFE3F2FD),
              iconColor: Color(0xFF2196F3),
              items: [
                'Aim for 150+ minutes of moderate exercise',
                'Include high-fiber foods in your diet',
                'Practice stress reduction techniques',
              ],
            ),
            const SizedBox(height: 16),
            const _HabitSection(
              title: 'Long-Term Prevention',
              subtitle: 'Sustained habits',
              icon: Icons.track_changes_rounded,
              iconBg: Color(0xFFF3E5F5),
              iconColor: Color(0xFF9C27B0),
              items: [
                'Achieve and maintain healthy body composition',
                'Annual metabolic health screening',
                'Build sustainable exercise habits',
                'Limit refined carbohydrate intake',
              ],
            ),
            const SizedBox(height: 16),
            const _WarningBox(),
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
            const Text('Prevention Guidance',
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
  final String riskType;
  const _IntroBox({required this.riskType});

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
        child: Text(
          'Prevention is the most powerful tool in healthcare. These personalized guidance items are based on SafeLife\'s analysis of your ${riskType.toLowerCase()} indicators and contributing factors.',
          style: const TextStyle(color: Color(0xFF006064), fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

class _HabitSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<String> items;

  const _HabitSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.items,
  });

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: _C.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: const TextStyle(color: _C.grey1, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(items.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2632),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF323D4D)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: _C.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(items[i],
                              style: const TextStyle(
                                  color: _C.white, fontSize: 13))),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFFAD5A1B), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 12.5, height: 1.5),
                  children: [
                    TextSpan(
                        text: 'This prevention guidance is personalized based on your wearable data analysis. These are wellness suggestions, not medical prescriptions. '),
                    TextSpan(
                        text: 'Always consult with a healthcare professional before making significant changes to your health routine, especially if you have existing medical conditions.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

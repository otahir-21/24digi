import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'fitness_target_date_screen.dart';

class FitnessGoalScreen extends StatefulWidget {
  final String selectedFocus;
  const FitnessGoalScreen({super.key, this.selectedFocus = 'Swimming'});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  String _activeTab = 'Distance';
  String _selectedGoal = 'Swim 500m';

  final List<String> _tabs = ['Distance', 'Speed', 'Technique'];
  
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Swim 500m',
      'subtitle': 'Build your base endurance\nwithout stopping.',
      'icon': Icons.directions_boat_filled_rounded,
    },
    {
      'title': 'Swim 1,000m',
      'subtitle': 'Continuous lap challenge\nfor intermediate.',
      'icon': Icons.waves_rounded,
    },
    {
      'title': 'Total 2km',
      'subtitle': 'Weekly accumulation target.',
      'icon': Icons.timer_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name?.toUpperCase() ?? 'USER';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const DigiPillHeader(showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'HI, $name',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 2.0 * s,
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    Text(
                      'Refine ${widget.selectedFocus} Goal',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 25 * s),
                    // Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.map((tab) {
                          final isActive = _activeTab == tab;
                          return Padding(
                            padding: EdgeInsets.only(right: 12 * s),
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = tab),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF2FFFCC) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20 * s),
                                  border: Border.all(
                                    color: isActive ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.2),
                                    width: 1 * s,
                                  ),
                                ),
                                child: Text(
                                  tab,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14 * s,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                                    color: isActive ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    // Goal Options
                    ..._goals.map((goal) {
                      final isSelected = _selectedGoal == goal['title'];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 15 * s),
                        child: _GoalCard(
                          s: s,
                          title: goal['title'],
                          subtitle: goal['subtitle'],
                          icon: goal['icon'],
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedGoal = goal['title']),
                        ),
                      );
                    }),
                    SizedBox(height: 30 * s),
                    // Status Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Goal',
                              style: GoogleFonts.outfit(
                                fontSize: 14 * s,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              _selectedGoal,
                              style: GoogleFonts.outfit(
                                fontSize: 24 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AI Estimate',
                              style: GoogleFonts.outfit(
                                fontSize: 13 * s,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8 * s,
                                  height: 8 * s,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2FFFCC),
                                  ),
                                ),
                                SizedBox(width: 8 * s),
                                Text(
                                  'Moderate',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16 * s,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 35 * s),
                    _ConfirmButton(
                      s: s,
                      label: 'Confirm',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FitnessTargetDateScreen(goalName: _selectedGoal)),
                        );
                      },
                    ),
                    SizedBox(height: 30 * s),
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

class _GoalCard extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.s,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20 * s),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2FFFCC) : const Color(0xFF0D1519),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(
            color: isSelected ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.1),
            width: 1.5 * s,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              ),
              child: Icon(icon, color: isSelected ? Colors.black : Colors.white.withOpacity(0.6), size: 24 * s),
            ),
            SizedBox(width: 15 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            _RadioIndicator(s: s, isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final double s;
  final bool isSelected;

  const _RadioIndicator({required this.s, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24 * s,
      height: 24 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.black : const Color(0xFF2FFFCC).withOpacity(0.4),
          width: 2 * s,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected ? Container(
        width: 12 * s,
        height: 12 * s,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
      ) : null,
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;

  const _ConfirmButton({required this.s, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: const LinearGradient(
            colors: [Color(0xFF2FFFCC), Color(0xFF2FFF9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FFFCC).withOpacity(0.3),
              blurRadius: 20 * s,
              offset: Offset(0, 10 * s),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 22 * s,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0D1519),
          ),
        ),
      ),
    );
  }
}

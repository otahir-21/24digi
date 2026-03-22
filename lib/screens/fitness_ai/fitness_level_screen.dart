import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'fitness_goal_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  String _selectedLevel = 'Intermediate';

  final List<Map<String, dynamic>> _levelOptions = [
    {
      'title': 'Beginner',
      'subtitle': 'Just starting my journey',
      'icon': Icons.keyboard_arrow_down_rounded,
    },
    {
      'title': 'Intermediate',
      'subtitle': 'Workout regularly and feel\ncomfortable with most\nexercises.',
      'icon': Icons.push_pin_rounded,
    },
    {
      'title': 'Advanced',
      'subtitle': 'I train consistently and\nhandle high-intensity\nworkouts.',
      'icon': Icons.bolt_rounded,
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
                    SizedBox(height: 35 * s),
                    Center(
                      child: Text(
                        'Choose your level',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 28 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 15 * s),
                    Center(
                      child: Text(
                        'This helps our AI personalize the\nideal workout intensity for your\nfitness level.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _levelOptions.length,
                      itemBuilder: (context, index) {
                        final item = _levelOptions[index];
                        final isSelected = _selectedLevel == item['title'];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20 * s),
                          child: _LevelCard(
                            s: s,
                            title: item['title']!,
                            subtitle: item['subtitle']!,
                            icon: item['icon']!,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedLevel = item['title']!),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20 * s),
                    _ContinueButton(
                      s: s,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FitnessGoalScreen()),
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

class _LevelCard extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
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
        duration: const Duration(milliseconds: 300),
        height: 180 * s,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.2),
            width: isSelected ? 2.5 * s : 1.0 * s,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                    blurRadius: 25 * s,
                    spreadRadius: 2 * s,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18 * s),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image - Clearly visible
              Image.asset(
                'assets/fitness_ai/fitness_strenght.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                color: isSelected ? null : Colors.black.withOpacity(0.35),
                colorBlendMode: BlendMode.darken,
              ),
              // Selection Overlay
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF00F0FF).withOpacity(0.1),
                        const Color(0xFF00F0FF).withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              // Floating Data Badges
              Positioned(
                top: 15 * s,
                right: 15 * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _DataBadge(s: s, icon: Icons.favorite_rounded, value: '145', label: 'BPM', isSelected: isSelected),
                    if (title == 'Intermediate') ...[
                      SizedBox(height: 8 * s),
                      _DataBadge(s: s, icon: Icons.favorite_rounded, value: '80', label: 'BPM', isSelected: isSelected),
                    ],
                  ],
                ),
              ),
              // Bottom Glass Section
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(15 * s),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D1519).withOpacity(0.85) : Colors.black.withOpacity(0.7),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1 * s,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8 * s),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(icon, color: isSelected ? Colors.black : Colors.white.withOpacity(0.6), size: 20 * s),
                      ),
                      SizedBox(width: 15 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 18 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: GoogleFonts.outfit(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // The target-like icon on the right
                      _SelectionIndicator(s: s, isSelected: isSelected),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataBadge extends StatelessWidget {
  final double s;
  final IconData icon;
  final String value;
  final String label;
  final bool isSelected;

  const _DataBadge({
    required this.s,
    required this.icon,
    required this.value,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF00F0FF) : Colors.white, size: 12 * s),
          SizedBox(width: 4 * s),
          Text(
            '$value $label',
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final double s;
  final bool isSelected;

  const _SelectionIndicator({required this.s, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28 * s,
      height: 28 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.3),
          width: 2 * s,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected ? Container(
        width: 14 * s,
        height: 14 * s,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2FFFCC),
        ),
        child: Icon(Icons.check, size: 10 * s, color: Colors.black),
      ) : null,
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final double s;
  final VoidCallback onTap;

  const _ContinueButton({required this.s, required this.onTap});

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
          'Continue',
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

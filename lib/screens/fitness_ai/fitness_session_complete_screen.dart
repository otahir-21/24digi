import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';

class FitnessSessionCompleteScreen extends StatefulWidget {
  const FitnessSessionCompleteScreen({super.key});

  @override
  State<FitnessSessionCompleteScreen> createState() => _FitnessSessionCompleteScreenState();
}

class _FitnessSessionCompleteScreenState extends State<FitnessSessionCompleteScreen> {
  double _rpeValue = 3; // 1: Easy, 2: Moderate, 3: Hard, 4: Max
  String _selectedFeeling = 'Drained';

  String get _rpeLabel {
    if (_rpeValue <= 1) return 'Easy';
    if (_rpeValue <= 2) return 'Moderate';
    if (_rpeValue <= 3) return 'Hard';
    return 'Max';
  }

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
            const DigiPillHeader(showBack: false),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: Column(
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
                    // Big Green Checkmark
                    Container(
                      width: 140 * s,
                      height: 140 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D1519),
                        border: Border.all(color: const Color(0xFF2FFFCC).withOpacity(0.1), width: 1.5 * s),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2FFFCC).withOpacity(0.15),
                            blurRadius: 40 * s,
                            spreadRadius: 5 * s,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.check_rounded, color: const Color(0xFF2FFFCC), size: 100 * s),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    Text(
                      'Session Complete',
                      style: GoogleFonts.outfit(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20 * s),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatChip(s: s, icon: Icons.timer_outlined, label: '45m'),
                        SizedBox(width: 15 * s),
                        _StatChip(s: s, icon: Icons.local_fire_department_rounded, label: '350 kcal'),
                      ],
                    ),
                    SizedBox(height: 40 * s),
                    Text(
                      'Great job. How did that feel?',
                      style: GoogleFonts.outfit(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    // Effort Level (RPE)
                    Padding(
                      padding: EdgeInsets.only(left: 10 * s),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Effort Level (RPE)',
                              style: GoogleFonts.outfit(
                                fontSize: 16 * s,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 10 * s),
                            Text(
                              _rpeLabel,
                              style: GoogleFonts.outfit(
                                fontSize: 32 * s,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2FFFCC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15 * s),
                    // Custom RPE Slider
                    _RPESlider(
                      s: s,
                      value: _rpeValue,
                      onChanged: (v) => setState(() => _rpeValue = v),
                    ),
                    SizedBox(height: 50 * s),
                    Text(
                      'Overall Feeling',
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 25 * s),
                    // Feeling Tiles
                    Row(
                      children: [
                        Expanded(
                          child: _FeelingCard(
                            s: s,
                            label: 'Felt Good',
                            imagePath: 'assets/fitness_ai/fitness_smile_icon.png',
                            isSelected: _selectedFeeling == 'Felt Good',
                            onTap: () => setState(() => _selectedFeeling = 'Felt Good'),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: _FeelingCard(
                            s: s,
                            label: 'Tired',
                            imagePath: 'assets/fitness_ai/fitness_tired_icon.png',
                            isSelected: _selectedFeeling == 'Tired',
                            onTap: () => setState(() => _selectedFeeling = 'Tired'),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: _FeelingCard(
                            s: s,
                            label: 'Drained',
                            imagePath: 'assets/fitness_ai/fitness_drained_icon.png',
                            isSelected: _selectedFeeling == 'Drained',
                            onTap: () => setState(() => _selectedFeeling = 'Drained'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 45 * s),
                    _DoneButton(
                      s: s,
                      onTap: () {
                         Navigator.of(context).popUntil((route) => route.isFirst);
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

class _StatChip extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;

  const _StatChip({required this.s, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D38).withOpacity(0.5),
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2FFFCC), size: 18 * s),
          SizedBox(width: 8 * s),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 18 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RPESlider extends StatelessWidget {
  final double s;
  final double value;
  final ValueChanged<double> onChanged;

  const _RPESlider({required this.s, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 10 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D38),
                borderRadius: BorderRadius.circular(5 * s),
              ),
            ),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final w = constraints.maxWidth;
                final activeW = w * (value - 1) / 3;
                return Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: activeW + 15 * s,
                    height: 10 * s,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2FFFCC), Color(0xFF2FFF9E)],
                      ),
                      borderRadius: BorderRadius.circular(5 * s),
                    ),
                  ),
                );
              },
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 10 * s,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: const Color(0xFF2FFFCC),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12 * s),
                overlayColor: const Color(0x332FFFCC),
              ),
              child: Slider(
                value: value,
                min: 1,
                max: 4,
                divisions: 3,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['EASY', 'MODERATE', 'HARD', 'MAX'].map((label) {
            return Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.2 * s,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeelingCard extends StatelessWidget {
  final double s;
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeelingCard({required this.s, required this.label, required this.imagePath, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1519),
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(
            color: isSelected ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 * s : 1 * s,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2FFFCC).withOpacity(0.1),
              blurRadius: 15 * s,
              spreadRadius: 2 * s,
            )
          ] : null,
        ),
        child: Column(
          children: [
            Image.asset(imagePath, width: 44 * s, height: 44 * s),
            SizedBox(height: 12 * s),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final double s;
  final VoidCallback onTap;

  const _DoneButton({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 65 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * s),
          gradient: const LinearGradient(
            colors: [Color(0xFF2FFFCC), Color(0xFF2FFF9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FFFCC).withOpacity(0.3),
              blurRadius: 20 * s,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'DONE',
          style: GoogleFonts.outfit(
            fontSize: 24 * s,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D1519),
            letterSpacing: 2.0 * s,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'fitness_level_screen.dart';

class FitnessFocusScreen extends StatefulWidget {
  const FitnessFocusScreen({super.key});

  @override
  State<FitnessFocusScreen> createState() => _FitnessFocusScreenState();
}

class _FitnessFocusScreenState extends State<FitnessFocusScreen> {
  String _selectedFocus = 'Swimming';
  double _daysPerWeek = 5;

  final List<Map<String, String>> _focusOptions = [
    {
      'title': 'Running',
      'subtitle': 'Endurance & Speed',
      'image': 'assets/fitness_ai/fitness_running.png',
    },
    {
      'title': 'Swimming',
      'subtitle': 'Form & Laps',
      'image': 'assets/fitness_ai/fitness_swimming.png',
    },
    {
      'title': 'Strength',
      'subtitle': 'Power & Hypertrophy',
      'image': 'assets/fitness_ai/fitness_strenght.png', // Misspelled as per assets
    },
    {
      'title': 'HIIT',
      'subtitle': 'Cardio & Burn',
      'image': 'assets/fitness_ai/fitness_hit.png',
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
                    SizedBox(height: 25 * s),
                    Text(
                      'What is your\nfocus today?',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 25 * s),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15 * s,
                        mainAxisSpacing: 15 * s,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _focusOptions.length,
                      itemBuilder: (context, index) {
                        final item = _focusOptions[index];
                        final isSelected = _selectedFocus == item['title'];
                        return _FocusCard(
                          s: s,
                          title: item['title']!,
                          subtitle: item['subtitle']!,
                          imagePath: item['image']!,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedFocus = item['title']!),
                        );
                      },
                    ),
                    SizedBox(height: 20 * s),
                    _AddActivityButton(s: s),
                    SizedBox(height: 35 * s),
                    Text(
                      'Weekly Commitment',
                      style: GoogleFonts.outfit(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Days Per Week',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 50 * s), // Space for tooltip
                    _WeeklyCommitmentSlider(
                      s: s,
                      value: _daysPerWeek,
                      onChanged: (v) => setState(() => _daysPerWeek = v),
                    ),
                    SizedBox(height: 40 * s),
                    _ContinueButton(
                      s: s,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FitnessLevelScreen()),
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

class _FocusCard extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _FocusCard({
    required this.s,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2.0 * s : 1.0 * s,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.2),
                    blurRadius: 15 * s,
                    spreadRadius: 2 * s,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * s),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(10 * s),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isSelected ? const Color(0xFF00F0FF).withOpacity(0.4) : Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
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

class _AddActivityButton extends StatelessWidget {
  final double s;
  const _AddActivityButton({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          style: BorderStyle.solid,
        ),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4 * s),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF26313A),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 16 * s),
          ),
          SizedBox(width: 10 * s),
          Text(
            'Add Other Activity',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCommitmentSlider extends StatelessWidget {
  final double s;
  final double value;
  final ValueChanged<double> onChanged;

  const _WeeklyCommitmentSlider({
    required this.s,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final thumbPos = (trackWidth - 20 * s) * (value - 1) / 6;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track Container
                Container(
                  height: 40 * s,
                  width: double.infinity,
                  color: Colors.transparent,
                ),
                // The actual track line
                Positioned(
                  top: 28 * s,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 6 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D38),
                      borderRadius: BorderRadius.circular(3 * s),
                    ),
                  ),
                ),
                // Active Track
                Positioned(
                  top: 28 * s,
                  left: 0,
                  width: thumbPos + 10 * s,
                  child: Container(
                    height: 6 * s,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFF2FFFCC)],
                      ),
                      borderRadius: BorderRadius.circular(3 * s),
                    ),
                  ),
                ),
                // Tick Marks
                Positioned(
                  top: 26 * s,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final isActive = (i + 1) <= value;
                      return Container(
                        width: 2 * s,
                        height: 10 * s,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF00F0FF) : const Color(0xFF5A6A74),
                          boxShadow: isActive ? [
                             BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.5), blurRadius: 4 * s)
                          ] : null,
                        ),
                      );
                    }),
                  ),
                ),
                // Tooltip and Thumb
                Positioned(
                  left: thumbPos,
                  top: -25 * s,
                  child: Column(
                    children: [
                      // Tooltip Speech Bubble
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FFFCC),
                          borderRadius: BorderRadius.circular(10 * s),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2FFFCC).withOpacity(0.4),
                              blurRadius: 10 * s,
                              offset: Offset(0, 4 * s),
                            ),
                          ],
                        ),
                        child: Text(
                          '${value.toInt()} Days',
                          style: GoogleFonts.outfit(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Triangle pointer
                      CustomPaint(
                        painter: _TrianglePainter(color: const Color(0xFF2FFFCC)),
                        size: Size(12 * s, 8 * s),
                      ),
                      SizedBox(height: 12 * s),
                      // Slider Thumb
                      Container(
                        width: 20 * s,
                        height: 20 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF00F0FF), width: 4 * s),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.6),
                              blurRadius: 12 * s,
                              spreadRadius: 2 * s,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Transparent Slider for interaction
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 40 * s,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
                    ),
                    child: Slider(
                      value: value,
                      min: 1,
                      max: 7,
                      divisions: 6,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 10 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isSelected = i + 1 == value.toInt();
            return Text(
              '${i + 1}',
              style: GoogleFonts.outfit(
                fontSize: 12 * s,
                color: isSelected ? const Color(0xFF2FFFCC) : Colors.white.withOpacity(0.4),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

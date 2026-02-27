import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import 'sign_up_setup5.dart';

class SignUpSetup4 extends StatefulWidget {
  const SignUpSetup4({super.key});

  @override
  State<SignUpSetup4> createState() => _SignUpSetup4State();
}

class _SignUpSetup4State extends State<SignUpSetup4> {
  final Set<String> _selectedAllergies = {'None'};
  final Set<String> _customAllergies = {};
  String? _selectedGoal;

  static const List<String> _allergies = [
    'None', 'Dairy', 'Eggs', 'Gluten',
    'Shellfish', 'Soy', 'Sesame', 'Fish',
  ];

  static const List<Map<String, dynamic>> _goals = [
    {
      'label': 'Balanced',
      'icon': Icons.balance_rounded,
      'color': Color(0xFF00F0FF),
    },
    {
      'label': 'High-Protein',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFFCE6AFF),
    },
    {
      'label': 'Vegan',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF40E0A0),
    },
    {
      'label': 'Light & fresh',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFFFFD166),
    },
  ];

  void _toggleAllergy(String label) {
    setState(() {
      if (label == 'None') {
        _selectedAllergies.clear();
        _customAllergies.clear();
        _selectedAllergies.add('None');
      } else {
        _selectedAllergies.remove('None');
        if (_selectedAllergies.contains(label)) {
          _selectedAllergies.remove(label);
          if (_selectedAllergies.isEmpty && _customAllergies.isEmpty) {
            _selectedAllergies.add('None');
          }
        } else {
          _selectedAllergies.add(label);
        }
      }
    });
  }

  void _showOtherDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1820),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C3E4A)),
        ),
        title: Text(
          'Add custom allergy',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: Colors.white),
          cursorColor: const Color(0xFF00F0FF),
          decoration: InputDecoration(
            hintText: 'e.g. Peanuts, Tree nuts...',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5A64)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C3E4A)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00F0FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF7A8A94))),
          ),
          TextButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  _selectedAllergies.remove('None');
                  _customAllergies.add(val);
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Add',
                style: GoogleFonts.inter(
                    color: const Color(0xFF00F0FF),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      resizeToAvoidBottomInset: true,
      contentPadding: (s) => EdgeInsets.symmetric(
        horizontal: 22 * s,
        vertical: 10 * s,
      ),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                        // ── Top bar ──
                        SetupTopBar(s: s, filledCount: 3),

                        SizedBox(height: 8 * s),

                        // ── Title ──
                        Text(
                          'Nutrition Profile',
                          style: GoogleFonts.inter(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 6 * s),

                        // ── Info card ──
                        InfoBox(
                          s: s,
                          text: 'Help out AI build your perfect menu. Select any allergies or intolerances.',
                        ),

                        SizedBox(height: 8 * s),

                        // ── Food Allergies label ──
                        SectionLabel(s: s, text: 'Food Allergies'),

                        SizedBox(height: 10 * s),

                        // ── Allergy chips ──
                        Wrap(
                          spacing: 8 * s,
                          runSpacing: 8 * s,
                          children: [
                            ..._allergies.map((a) => _AllergyChip(
                                  s: s,
                                  label: a,
                                  selected: _selectedAllergies.contains(a),
                                  onTap: () => _toggleAllergy(a),
                                )),
                            ..._customAllergies.map((a) => _AllergyChip(
                                  s: s,
                                  label: a,
                                  selected: true,
                                  onTap: () {
                                    setState(() {
                                      _customAllergies.remove(a);
                                      if (_selectedAllergies.isEmpty &&
                                          _customAllergies.isEmpty) {
                                        _selectedAllergies.add('None');
                                      }
                                    });
                                  },
                                )),
                            _OtherChip(s: s, onTap: _showOtherDialog),
                          ],
                        ),

                        SizedBox(height: 8 * s),

                        // ── Dietary Goal label ──
                        SectionLabel(s: s, text: 'Dietary Goal'),

                        SizedBox(height: 8 * s),

                        // ── Goal tiles ──
                        ..._goals.map((g) {
                          final label = g['label'] as String;
                          final icon = g['icon'] as IconData;
                          final color = g['color'] as Color;
                          final isSelected = _selectedGoal == label;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4 * s),
                            child: _GoalTile(
                              s: s,
                              label: label,
                              icon: icon,
                              accentColor: color,
                              selected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedGoal = label),
                            ),
                          );
                        }),

                        SizedBox(height: 6 * s),

                        // ── Privacy text ──
                        Center(
                          child: Text(
                            'Private & secure. You can update this later.',
                            style: GoogleFonts.inter(
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF5A6A74),
                            ),
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        // ── Continue button ──
                        Center(
                          child: PrimaryButton(
                            s: s,
                            label: 'CONTINUE',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpSetup5(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 6 * s),
        ],
      ),
    );
  }
}

// ── Allergy pill chip ──────────────────────────────────────────────────────────

class _AllergyChip extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AllergyChip({
    required this.s,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50 * s),
          color: selected
              ? const Color.fromRGBO(0, 240, 255, 0.12)
              : const Color.fromRGBO(10, 18, 26, 0.85),
          border: Border.all(
            color: selected
                ? const Color(0xFF00F0FF)
                : const Color(0xFF2C3E4A),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x3300F0FF),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w400,
            color: selected ? const Color(0xFF00F0FF) : const Color(0xFFB0BEC5),
          ),
        ),
      ),
    );
  }
}

// ── "Other..." chip ────────────────────────────────────────────────────────────

class _OtherChip extends StatefulWidget {
  final double s;
  final VoidCallback onTap;
  const _OtherChip({required this.s, required this.onTap});

  @override
  State<_OtherChip> createState() => _OtherChipState();
}

class _OtherChipState extends State<_OtherChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50 * s),
          color: _pressed
              ? const Color.fromRGBO(0, 240, 255, 0.10)
              : Colors.transparent,
          border: Border.all(
            color: _pressed
                ? const Color(0xFF00F0FF)
                : const Color(0xFF2C3E4A),
            width: _pressed ? 1.5 : 1.0,
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Color(0x3300F0FF),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          'Other ...',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w400,
            color: _pressed
                ? const Color(0xFF00F0FF)
                : const Color(0xFF7A8A94),
          ),
        ),
      ),
    );
  }
}

// ── Dietary goal tile ──────────────────────────────────────────────────────────

class _GoalTile extends StatelessWidget {
  final double s;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _GoalTile({
    required this.s,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * s,
          vertical: 11 * s,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * s),
          color: selected
              ? Color.fromRGBO(
                  (accentColor.r * 255).round(), (accentColor.g * 255).round(), (accentColor.b * 255).round(), 0.08)
              : const Color.fromRGBO(10, 18, 26, 0.85),
        ),
        child: CustomPaint(
          painter: _TileGradientBorder(
            radius: 14 * s,
            selected: selected,
            accentColor: accentColor,
          ),
          child: Row(
            children: [
              // Icon box
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30 * s,
                height: 30 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7 * s),
                  color: Color.fromRGBO(
                    (accentColor.r * 255).round(),
                    (accentColor.g * 255).round(),
                    (accentColor.b * 255).round(),
                    selected ? 0.20 : 0.10,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 15 * s,
                  color:
                      selected ? accentColor : const Color(0xFF5A6A74),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w400,
                    color: selected
                        ? Colors.white
                        : const Color(0xFFB0BEC5),
                  ),
                ),
              ),
              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20 * s,
                height: 20 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00F0FF)
                        : const Color(0xFF2C3E4A),
                    width: selected ? 2.0 : 1.2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8 * s,
                          height: 8 * s,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00F0FF),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gradient border painter ────────────────────────────────────────────────────

class _TileGradientBorder extends CustomPainter {
  final double radius;
  final bool selected;
  final Color accentColor;

  const _TileGradientBorder({
    required this.radius,
    required this.selected,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = selected
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                accentColor.withAlpha(180),
                const Color(0x0000F0FF),
                const Color(0x0000F0FF),
                const Color(0xAAFFC0FF),
                const Color(0xFFCE6AFF),
                const Color(0x00CE6AFF),
              ],
              stops: const [0.0, 0.18, 0.38, 0.55, 0.72, 0.88, 1.0],
            ).createShader(rect)
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00F0FF),
                Color(0x8800F0FF),
                Color(0x00000000),
                Color(0x00000000),
                Color(0x88CE6AFF),
                Color(0xFFCE6AFF),
                Color(0x00CE6AFF),
              ],
              stops: [0.0, 0.18, 0.38, 0.55, 0.72, 0.88, 1.0],
            ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _TileGradientBorder old) =>
      old.selected != selected || old.accentColor != accentColor;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import '../../widgets/digi_gradient_border.dart';
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
    'None',
    'Dairy',
    'Eggs',
    'Gluten',
    'Shellfish',
    'Soy',
    'Sesame',
    'Fish',
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
    {'label': 'Vegan', 'icon': Icons.eco_rounded, 'color': Color(0xFF40E0A0)},
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
          side: const BorderSide(color: Color(0xFF26313A)),
        ),
        title: Text(
          'Add custom allergy',
          style: GoogleFonts.inter(
            color: const Color(0xFFEAF2F5),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: const Color(0xFFEAF2F5)),
          cursorColor: const Color(0xFF00F0FF),
          decoration: InputDecoration(
            hintText: 'e.g. Peanuts, Tree nuts...',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5A64)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF26313A)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00F0FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF7A8A94)),
            ),
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
            child: Text(
              'Add',
              style: GoogleFonts.inter(
                color: const Color(0xFF00F0FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      setupMode: true,
      resizeToAvoidBottomInset: true,
      contentPadding: (s) =>
          EdgeInsets.symmetric(horizontal: 17 * s, vertical: 12 * s),
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──
          SetupTopBar(s: s, filledCount: 3),

          SizedBox(height: 24 * s),

          // ── Title ──
          Text(
            'Nutrition Profile',
            style: GoogleFonts.inter(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 20 * s),

          // ── Info card ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15 * s),
              color: const Color(0xFF26313A).withOpacity(0.3),
              border: Border.all(color: const Color(0xFF26313A), width: 1),
            ),
            child: Text(
              'Help out AI build your perfect menu. Select any allergies or intolerances.',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7680),
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Food Allergies label ──
          Text(
            'Food Allergies',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 16 * s),

          // ── Allergy chips ──
          Wrap(
            spacing: 8 * s,
            runSpacing: 8 * s,
            children: [
              ..._allergies.map(
                (a) => _AllergyChip(
                  s: s,
                  label: a,
                  selected: _selectedAllergies.contains(a),
                  onTap: () => _toggleAllergy(a),
                ),
              ),
              ..._customAllergies.map(
                (a) => _AllergyChip(
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
                ),
              ),
              _OtherChip(s: s, onTap: _showOtherDialog),
            ],
          ),

          SizedBox(height: 24 * s),

          // ── Dietary Goal label ──
          Text(
            'Dietary Goal',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 16 * s),

          // ── Goal tiles ──
          ..._goals.map((g) {
            final label = g['label'] as String;
            final isSelected = _selectedGoal == label;
            return Padding(
              padding: EdgeInsets.only(bottom: 12 * s),
              child: _GoalTile(
                s: s,
                label: label,
                selected: isSelected,
                onTap: () => setState(() => _selectedGoal = label),
              ),
            );
          }),

          SizedBox(height: 24 * s),

          // ── Privacy text ──
          Center(
            child: Text(
              'Private & secure. You can update this later.',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5A6A74),
              ),
            ),
          ),

          SizedBox(height: 20 * s),

          // ── Continue button ──
          Center(
            child: PrimaryButton(
              s: s,
              label: 'CONTINUE',
              onTap: () async {
                final auth = context.read<AuthProvider>();
                final allergies =
                    _selectedAllergies.contains('None') &&
                        _customAllergies.isEmpty
                    ? <String>['None']
                    : [
                        ..._selectedAllergies.where((x) => x != 'None'),
                        ..._customAllergies,
                      ];
                await auth.updateNutrition(
                  ProfileNutritionPayload(
                    foodAllergies: allergies.isEmpty ? null : allergies,
                    otherAllergyText: _customAllergies.isEmpty
                        ? null
                        : _customAllergies.join(', '),
                    dietaryGoal: _selectedGoal,
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpSetup5()),
                );
              },
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
      child: CustomPaint(
        painter: DigiGradientBorderPainter(radius: 50 * s, strokeWidth: 1.18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50 * s),
            color: selected
                ? const Color(0xFF00F0FF).withOpacity(0.12)
                : const Color(0xFF26313A).withOpacity(0.3),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w400,
              color: selected
                  ? const Color(0xFF00F0FF)
                  : const Color(0xFFB0BEC5),
            ),
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
      child: CustomPaint(
        painter: DigiGradientBorderPainter(radius: 50 * s, strokeWidth: 1.18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50 * s),
            color: _pressed
                ? const Color(0xFF00F0FF).withOpacity(0.10)
                : const Color(0xFF26313A).withOpacity(0.3),
          ),
          alignment: Alignment.center,
          child: Text(
            'Other ...',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w400,
              color: _pressed
                  ? const Color(0xFF00F0FF)
                  : const Color(0xFF7A8A94),
            ),
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
  final bool selected;
  final VoidCallback onTap;

  const _GoalTile({
    required this.s,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DigiGradientBorderPainter(radius: 14 * s, strokeWidth: 1.18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * s),
            color: const Color(0xFF26313A).withOpacity(0.3),
          ),
          child: Row(
            children: [
              // Left placeholder box
              Container(
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * s),
                  color: const Color(0xFF26313A).withOpacity(0.5),
                ),
              ),
              SizedBox(width: 14 * s),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              // Radio indicator
              Container(
                width: 22 * s,
                height: 22 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00F0FF)
                        : const Color(0xFF26313A),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10 * s,
                          height: 10 * s,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import 'sign_up_setup7.dart';

class SignUpSetup6 extends StatefulWidget {
  const SignUpSetup6({super.key});

  @override
  State<SignUpSetup6> createState() => _SignUpSetup6State();
}

class _SignUpSetup6State extends State<SignUpSetup6> {
  String? _selectedGoal;
  String? _selectedBuild;

  static const List<String> _goals = [
    'Improve Fitness',
    'Muscle gain\n(hypertrophy)',
    'Losing weight',
    'Increase Endurance',
    'Stay Healthy',
  ];

  static const List<String> _builds = [
    'Lean',
    'Average',
    'Muscular',
    'Athletic',
    'Higher body fat',
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      setupMode: true,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      // ── Top bar ──
                      SetupTopBar(s: s, filledCount: 5),

                      SizedBox(height: 8 * s),

                      // ── Title ──
                      Text(
                        'Define your Path',
                        style: GoogleFonts.inter(
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEAF2F5),
                          height: 1.25,
                        ),
                      ),

                      SizedBox(height: 6 * s),

                      // ── Info card ──
                      InfoBox(
                        s: s,
                        text: 'Help out AI customize Your nutrition and workout plan based on your aspirations.',
                      ),

                      SizedBox(height: 14 * s),

                      // ── Primary Goal label ──
                      SectionLabel(s: s, text: 'Primary Goal'),
                      SizedBox(height: 10 * s),

                      // ── Goal grid (2×2 + 1 full-width) ──
                      Column(
                        children: [
                          // Row 1
                          Row(
                            children: [
                              Expanded(
                                child: _GoalTile(
                                  s: s,
                                  label: _goals[0],
                                  selected: _selectedGoal == _goals[0],
                                  onTap: () => setState(
                                      () => _selectedGoal = _goals[0]),
                                ),
                              ),
                              SizedBox(width: 8 * s),
                              Expanded(
                                child: _GoalTile(
                                  s: s,
                                  label: _goals[1],
                                  selected: _selectedGoal == _goals[1],
                                  onTap: () => setState(
                                      () => _selectedGoal = _goals[1]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * s),
                          // Row 2
                          Row(
                            children: [
                              Expanded(
                                child: _GoalTile(
                                  s: s,
                                  label: _goals[2],
                                  selected: _selectedGoal == _goals[2],
                                  onTap: () => setState(
                                      () => _selectedGoal = _goals[2]),
                                ),
                              ),
                              SizedBox(width: 8 * s),
                              Expanded(
                                child: _GoalTile(
                                  s: s,
                                  label: _goals[3],
                                  selected: _selectedGoal == _goals[3],
                                  onTap: () => setState(
                                      () => _selectedGoal = _goals[3]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * s),
                          // Row 3 — full width
                          _GoalTile(
                            s: s,
                            label: _goals[4],
                            selected: _selectedGoal == _goals[4],
                            onTap: () =>
                                setState(() => _selectedGoal = _goals[4]),
                            fullWidth: true,
                          ),
                        ],
                      ),

                      SizedBox(height: 14 * s),

                      // ── Current Build label ──
                      SectionLabel(s: s, text: 'Current Build'),
                      SizedBox(height: 10 * s),

                      // ── Build tiles ──
                      ..._builds.map((b) {
                        final selected = _selectedBuild == b;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 5 * s),
                          child: _BuildTile(
                            s: s,
                            label: b,
                            selected: selected,
                            onTap: () =>
                                setState(() => _selectedBuild = b),
                          ),
                        );
                      }),

                      SizedBox(height: 10 * s),

                      // ── Continue button ──
                      Center(
                        child: PrimaryButton(
                          s: s,
                          label: 'CONTINUE',
                          onTap: () async {
                            final auth = context.read<AuthProvider>();
                            await auth.updateGoals(ProfileGoalsPayload(
                              primaryGoal: _selectedGoal,
                              currentBuild: _selectedBuild,
                            ));
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpSetup7(),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 12 * s),
        ],
      ),
    );
  }
}


// ── Goal tile (grid cell) ─────────────────────────────────────────────────────

class _GoalTile extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _GoalTile({
    required this.s,
    required this.label,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: fullWidth ? double.infinity : null,
        height: fullWidth ? 48 * s : 64 * s,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * s,
          vertical: 8 * s,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * s),
          color: selected
              ? const Color.fromRGBO(0, 240, 255, 0.08)
              : const Color.fromRGBO(10, 18, 26, 0.85),
        ),
        child: CustomPaint(
          painter: SmoothGradientBorder(
            radius: 14 * s,
            selected: selected,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
                color: selected ? const Color(0xFFEAF2F5) : const Color(0xFFD0DCE4),
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Build tile (radio row) ────────────────────────────────────────────────────

class _BuildTile extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BuildTile({
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
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * s,
          vertical: 12 * s,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * s),
          color: selected
              ? const Color.fromRGBO(0, 240, 255, 0.08)
              : const Color.fromRGBO(10, 18, 26, 0.85),
        ),
        child: CustomPaint(
          painter: SmoothGradientBorder(
            radius: 12 * s,
            selected: selected,
          ),
          child: Row(
            children: [
              // Icon swatch
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6 * s),
                  color: selected
                      ? const Color.fromRGBO(0, 240, 255, 0.18)
                      : const Color.fromRGBO(0, 240, 255, 0.06),
                ),
                child: Icon(
                  Icons.accessibility_new_rounded,
                  size: 14 * s,
                  color: selected
                      ? const Color(0xFF00F0FF)
                      : const Color(0xFF5A6A74),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? const Color(0xFFEAF2F5)
                        : const Color(0xFFD0DCE4),
                  ),
                ),
              ),
              // Radio dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18 * s,
                height: 18 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00F0FF)
                        : const Color(0xFF26313A),
                    width: selected ? 2.0 : 1.2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 7 * s,
                          height: 7 * s,
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

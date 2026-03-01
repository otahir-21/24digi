import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import '../../widgets/digi_gradient_border.dart';
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
      contentPadding: (s) =>
          EdgeInsets.symmetric(horizontal: 17 * s, vertical: 12 * s),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──
          SetupTopBar(s: s, filledCount: 5),

          SizedBox(height: 24 * s),

          // ── Title ──
          Text(
            'Define your Path',
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
              'Help out AI customize Your nutrition and workout plan based on your aspirations.',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7680),
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Primary Goal label ──
          Text(
            'Primary Goal',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),

          // ── Goal grid ──
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _GoalTile(
                      s: s,
                      label: _goals[0],
                      selected: _selectedGoal == _goals[0],
                      onTap: () => setState(() => _selectedGoal = _goals[0]),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _GoalTile(
                      s: s,
                      label: _goals[1],
                      selected: _selectedGoal == _goals[1],
                      onTap: () => setState(() => _selectedGoal = _goals[1]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(
                    child: _GoalTile(
                      s: s,
                      label: _goals[2],
                      selected: _selectedGoal == _goals[2],
                      onTap: () => setState(() => _selectedGoal = _goals[2]),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _GoalTile(
                      s: s,
                      label: _goals[3],
                      selected: _selectedGoal == _goals[3],
                      onTap: () => setState(() => _selectedGoal = _goals[3]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: _GoalTile(
                    s: s,
                    label: _goals[4],
                    selected: _selectedGoal == _goals[4],
                    onTap: () => setState(() => _selectedGoal = _goals[4]),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24 * s),

          // ── Current Build label ──
          Text(
            'Current Build',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),

          ..._builds.map((b) {
            final selected = _selectedBuild == b;
            return Padding(
              padding: EdgeInsets.only(bottom: 12 * s),
              child: _BuildTile(
                s: s,
                label: b,
                selected: selected,
                onTap: () => setState(() => _selectedBuild = b),
              ),
            );
          }),

          SizedBox(height: 32 * s),

          // ── Continue button ──
          Center(
            child: PrimaryButton(
              s: s,
              label: 'CONTINUE',
              onTap: () async {
                final auth = context.read<AuthProvider>();
                await auth.updateGoals(
                  ProfileGoalsPayload(
                    primaryGoal: _selectedGoal,
                    currentBuild: _selectedBuild,
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpSetup7()),
                );
              },
            ),
          ),

          SizedBox(height: 24 * s),
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
          height: 62 * s,
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * s),
            color: const Color(0xFF26313A).withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
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

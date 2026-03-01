import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/digi_gradient_border.dart';
import '../home_screen.dart';

class SignUpSetup7 extends StatefulWidget {
  const SignUpSetup7({super.key});

  @override
  State<SignUpSetup7> createState() => _SignUpSetup7State();
}

class _SignUpSetup7State extends State<SignUpSetup7> {
  static String _str(String? v) => v != null && v.isNotEmpty ? v : '—';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final p = auth.profile;
        final profileRows = [
          _ReviewRow(label: 'Name', value: _str(p?.name)),
          _ReviewRow(
            label: 'Age',
            value: p?.age != null ? '${p!.age}' : _str(p?.dateOfBirth),
          ),
          _ReviewRow(label: 'Gender', value: _str(p?.gender)),
          _ReviewRow(
            label: 'Height',
            value: p?.heightCm != null ? '${p!.heightCm} cm' : '—',
          ),
          _ReviewRow(
            label: 'Weight',
            value: p?.weightKg != null ? '${p!.weightKg} kg' : '—',
          ),
        ];
        final goalsRows = [
          _ReviewRow(label: 'Primary Goal', value: _str(p?.primaryGoal)),
          _ReviewRow(label: 'Current Build', value: _str(p?.currentBuild)),
          _ReviewRow(
            label: 'Commitment',
            value: p?.workoutsPerWeek != null
                ? '${p!.workoutsPerWeek} Days/Week'
                : '—',
          ),
        ];
        final nutritionRows = [
          _ReviewRow(label: 'Dietary Preferences', value: _str(p?.dietaryGoal)),
          _ReviewRow(
            label: 'Food Allergies',
            value: (p?.foodAllergies != null && p!.foodAllergies!.isNotEmpty)
                ? p.foodAllergies!.join(', ')
                : 'None',
          ),
          _ReviewRow(label: 'Activity Level', value: _str(p?.activityLevel)),
          _ReviewRow(
            label: 'Preferred Workouts',
            value:
                (p?.preferredWorkouts != null &&
                    p!.preferredWorkouts!.isNotEmpty)
                ? p.preferredWorkouts!.join(', ')
                : '—',
          ),
          _ReviewRow(label: 'Primary Goal', value: _str(p?.primaryGoal)),
          _ReviewRow(label: 'Current Build', value: _str(p?.currentBuild)),
          if (p != null &&
              p.healthConsiderations != null &&
              p.healthConsiderations!.isNotEmpty)
            _ReviewRow(
              label: 'Health Considerations',
              value: p.healthConsiderations!.join(', '),
            ),
        ];

        return ScreenShell(
          scrollable: true,
          setupMode: true,
          contentPadding: (s) =>
              EdgeInsets.symmetric(horizontal: 17 * s, vertical: 12 * s),
          builder: (s) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF00F0FF),
                          size: 22 * s,
                        ),
                      ),
                      Text(
                        'Last Step',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7680),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Review & Finish',
                    style: GoogleFonts.inter(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24 * s),

              // ── Full progress bar ──
              Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      height: 3 * s,
                      margin: EdgeInsets.only(right: i < 4 ? 4 * s : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2 * s),
                        color: const Color(0xFF00F0FF),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24 * s),

              // ── Title ──
              Text(
                'Review Your Details',
                style: GoogleFonts.inter(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 20 * s),

              // ── Info card ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 14 * s,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15 * s),
                  color: const Color(0xFF26313A).withOpacity(0.3),
                  border: Border.all(color: const Color(0xFF26313A), width: 1),
                ),
                child: Text(
                  'Confirm your details to enable intelligent, AI-driven personalization for your plan.',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7680),
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 24 * s),

              // ── Profile section ──
              _ReviewSection(
                s: s,
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                onEdit: () {},
                rows: profileRows,
              ),

              SizedBox(height: 12 * s),

              // ── Goals section ──
              _ReviewSection(
                s: s,
                icon: Icons.flag_outlined,
                title: 'Goals',
                onEdit: () {},
                rows: goalsRows,
              ),

              SizedBox(height: 12 * s),

              // ── Nutrition section ──
              _ReviewSection(
                s: s,
                icon: Icons.tune_rounded,
                title: 'Nutrition, goals & Health',
                onEdit: () {},
                rows: nutritionRows,
              ),

              SizedBox(height: 32 * s),

              // ── FINISH SETUP button ──
              Center(
                child: PrimaryButton(
                  s: s,
                  label: 'FINISH SETUP',
                  onTap: () async {
                    final auth = context.read<AuthProvider>();
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    const consents = ProfileConsents(
                      termsAccepted: true,
                      privacyAccepted: true,
                      healthDisclaimerAccepted: true,
                    );
                    final ok = await auth.finishProfile(consents);
                    if (!mounted) return;
                    if (ok) {
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            auth.errorMessage ?? 'Failed to finish setup',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              SizedBox(height: 24 * s),
            ],
      ),
    );
      },
    );
  }
}

// ── Review section card ───────────────────────────────────────────────────────

class _ReviewRow {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});
}

class _ReviewSection extends StatelessWidget {
  final double s;
  final IconData icon;
  final String title;
  final VoidCallback onEdit;
  final List<_ReviewRow> rows;

  const _ReviewSection({
    required this.s,
    required this.icon,
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DigiGradientBorderPainter(radius: 16 * s, strokeWidth: 1.18),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          color: const Color(0xFF26313A).withOpacity(0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(icon, size: 20 * s, color: Colors.white),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    children: [
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7680),
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(
                        Icons.edit_outlined,
                        size: 14 * s,
                        color: const Color(0xFF6B7680),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    children: [
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7A8A94),
                        ),
                      ),
                      SizedBox(width: 3 * s),
                      Icon(
                        Icons.edit_outlined,
                        size: 12 * s,
                        color: const Color(0xFF7A8A94),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8 * s),

            // Divider
            Container(height: 1, color: const Color(0xFF1E2E3A)),

            // Data rows
            ...rows.map(
              (row) => Padding(
                padding: EdgeInsets.symmetric(vertical: 7 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF7A8A94),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        softWrap: true,
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

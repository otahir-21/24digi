import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../home_screen.dart';

class SignUpSetup7 extends StatefulWidget {
  const SignUpSetup7({super.key});

  @override
  State<SignUpSetup7> createState() => _SignUpSetup7State();
}

class _SignUpSetup7State extends State<SignUpSetup7> {
  // ── Placeholder review data ──────────────────────────────────────────────
  static const _profile = {
    'Name': 'User Name',
    'Age': '29',
    'Gender': 'Male',
    'Height': '180 cm',
    'Weight': '84 kg',
  };

  static const _goals = {
    'Primary Goal': 'Improve Fitness',
    'Focus Area': 'Nutrition & Sleep',
    'Commitment': '3 Days/Week',
  };

  static const _nutrition = {
    'Dietary Preferences': 'Balanced',
    'Food Allergies': 'None',
    'Activity Level': 'Lightly Active',
    'Preferred Workouts': 'Sports',
    'Primary Goal': 'Improve Fitness',
    'Current Build': 'Average',
  };

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      // ── Top bar ──
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: const Color(0xFF00F0FF),
                              size: 20 * s,
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Text(
                              'Review & Finish',
                              style: GoogleFonts.inter(
                                fontSize: 15 * s,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * s,
                              vertical: 3 * s,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20 * s),
                              color: const Color.fromRGBO(0, 240, 255, 0.10),
                              border: Border.all(
                                color: const Color(0xFF00F0FF),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Last Step',
                              style: GoogleFonts.inter(
                                fontSize: 10 * s,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF00F0FF),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8 * s),

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

                      SizedBox(height: 12 * s),

                      // ── Title ──
                      Text(
                        'Review Your Details',
                        style: GoogleFonts.inter(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: 6 * s),

                      // ── Info card ──
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * s,
                          vertical: 8 * s,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12 * s),
                          color: const Color.fromRGBO(255, 255, 255, 0.04),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.08),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Confirm your details to enable intelligent, AI-driven personalization for your plan.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5 * s,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF7A8A94),
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 12 * s),

                      // ── Profile section ──
                      _ReviewSection(
                        s: s,
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        onEdit: () {},
                        rows: _profile.entries
                            .map((e) => _ReviewRow(label: e.key, value: e.value))
                            .toList(),
                      ),

                      SizedBox(height: 8 * s),

                      // ── Goals section ──
                      _ReviewSection(
                        s: s,
                        icon: Icons.flag_outlined,
                        title: 'Goals',
                        onEdit: () {},
                        rows: _goals.entries
                            .map((e) => _ReviewRow(label: e.key, value: e.value))
                            .toList(),
                      ),

                      SizedBox(height: 8 * s),

                      // ── Nutrition section ──
                      _ReviewSection(
                        s: s,
                        icon: Icons.tune_rounded,
                        title: 'Nutrition, goals & Health',
                        onEdit: () {},
                        rows: _nutrition.entries
                            .map((e) => _ReviewRow(label: e.key, value: e.value))
                            .toList(),
                      ),

                      SizedBox(height: 16 * s),

                      // ── FINISH SETUP button ──
                      Center(
                        child: PrimaryButton(
                          s: s,
                          label: 'FINISH SETUP',
                          width: 230,
                          height: 48,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          ),
                        ),
                      ),

                      SizedBox(height: 12 * s),
        ],
      ),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * s),
        color: const Color.fromRGBO(10, 18, 26, 0.85),
      ),
      child: CustomPaint(
          painter: SmoothGradientBorder(radius: 16 * s),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 4 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(icon,
                      size: 16 * s, color: const Color(0xFF00F0FF)),
                  SizedBox(width: 6 * s),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w600,
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
              Container(
                height: 1,
                color: const Color(0xFF1E2E3A),
              ),

              // Data rows
              ...rows.map((row) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 7 * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          row.label,
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF7A8A94),
                          ),
                        ),
                        Text(
                          row.value,
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

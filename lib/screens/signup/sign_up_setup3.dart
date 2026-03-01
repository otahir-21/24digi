import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import '../../widgets/digi_gradient_border.dart';
import 'sign_up_setup4.dart';

class SignUpSetup3 extends StatefulWidget {
  const SignUpSetup3({super.key});

  @override
  State<SignUpSetup3> createState() => _SignUpSetup3State();
}

class _SignUpSetup3State extends State<SignUpSetup3> {
  final Set<String> _selected = {};

  static const List<Map<String, dynamic>> _options = [
    {
      'label': 'Heart Conditions',
      'icon': Icons.favorite_border_rounded,
      'color': Color(0xFFFF6B8A),
    },
    {
      'label': 'Blood Pressure Concerns',
      'icon': Icons.monitor_heart_outlined,
      'color': Color(0xFFCE6AFF),
    },
    {
      'label': 'Breathing or lungs',
      'icon': Icons.air_rounded,
      'color': Color(0xFF00F0FF),
    },
    {
      'label': 'Sleep & recovery',
      'icon': Icons.bedtime_outlined,
      'color': Color(0xFF7B8FFF),
    },
    {
      'label': 'Blood sugar & metabolism',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFF40E0A0),
    },
    {
      'label': 'None / Prefer not to say',
      'icon': Icons.do_not_disturb_alt_outlined,
      'color': Color(0xFF7A8A94),
    },
  ];

  void _toggleOption(String label) {
    setState(() {
      if (label == 'None / Prefer not to say') {
        _selected.clear();
        _selected.add(label);
      } else {
        _selected.remove('None / Prefer not to say');
        if (_selected.contains(label)) {
          _selected.remove(label);
        } else {
          _selected.add(label);
        }
      }
    });
  }

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
          SetupTopBar(s: s, filledCount: 2),

          SizedBox(height: 24 * s),

          // ── Title ──
          Text(
            'Do you have any health\nconsiderations?',
            style: GoogleFonts.inter(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.25,
            ),
          ),

          SizedBox(height: 20 * s),

          // ── Info card ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15 * s),
              color: const Color(0xFF26313A).withOpacity(0.3),
              border: Border.all(color: const Color(0xFF26313A), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: const Color(0xFF00F0FF),
                  size: 16 * s,
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF6B7680),
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text:
                              'Sharing this helps our AI personalize insights and alerts adjust intensity and recommendations safely. Your data is encrypted and private. ',
                        ),
                        TextSpan(
                          text: 'This is not a medical diagnosis.',
                          style: TextStyle(color: Color(0xFF4A5A64)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Option list ──
          ..._options
              .where((opt) => opt['label'] != 'None / Prefer not to say')
              .map((opt) {
                final label = opt['label'] as String;
                final isSelected = _selected.contains(label);

                return Padding(
                  padding: EdgeInsets.only(bottom: 12 * s),
                  child: _HealthOptionTile(
                    s: s,
                    label: label,
                    selected: isSelected,
                    onTap: () => _toggleOption(label),
                  ),
                );
              }),

          // ── Divider before None ──
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            child: Container(height: 1, color: const Color(0xFF26313A)),
          ),

          // ── None option ──
          _HealthOptionTile(
            s: s,
            label: 'None / Prefer not to say',
            selected: _selected.contains('None / Prefer not to say'),
            onTap: () => _toggleOption('None / Prefer not to say'),
          ),

          SizedBox(height: 32 * s),

          // ── Continue button ──
          Center(
            child: PrimaryButton(
              s: s,
              label: 'CONTINUE',
              onTap: () async {
                final auth = context.read<AuthProvider>();
                await auth.updateHealth(
                  ProfileHealthPayload(
                    healthConsiderations: _selected.isEmpty
                        ? null
                        : _selected.toList(),
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpSetup4()),
                );
              },
            ),
          ),

          SizedBox(height: 12 * s),

          Center(
            child: Text(
              'By creating an account, you agree to sharing basic health and activity data.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF5A6A74),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual health option tile ──────────────────────────────────────────────

class _HealthOptionTile extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HealthOptionTile({
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
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
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

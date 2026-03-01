import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
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
      customCardHeightRatio: 0.62,
      contentPadding: (s) => EdgeInsets.symmetric(
        horizontal: 22 * s, vertical: 8 * s),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                        // ── Top bar ──
                        SetupTopBar(s: s, filledCount: 2),

                        SizedBox(height: 8 * s),

                        // ── Title ──
                        Text(
                          'Do you have any health\nconsiderations?',
                          style: GoogleFonts.inter(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEAF2F5),
                            height: 1.25,
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        // ── Info card ──
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * s,
                            vertical: 9 * s,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12 * s),
                            color: const Color.fromRGBO(0, 240, 255, 0.06),
                            border: Border.all(
                              color: const Color.fromRGBO(0, 240, 255, 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: const Color(0xFF00F0FF),
                                size: 14 * s,
                              ),
                              SizedBox(width: 8 * s),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 10 * s,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFF7A8A94),
                                      height: 1.5,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text:
                                            'Sharing this helps our AI personalize insights and alerts adjust intensity and recommendations safely. Your data is encrypted and private. ',
                                      ),
                                      TextSpan(
                                        text:
                                            'This is not a medical diagnosis.',
                                        style: TextStyle(
                                          color: Color(0xFF4A5A64),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 6 * s),

                        // ── Option list ──
                        ..._options.map((opt) {
                          final label = opt['label'] as String;
                          final icon = opt['icon'] as IconData;
                          final color = opt['color'] as Color;
                          final isSelected = _selected.contains(label);

                          return Padding(
                            padding: EdgeInsets.only(bottom: 4 * s),
                            child: _HealthOptionTile(
                              s: s,
                              label: label,
                              icon: icon,
                              accentColor: color,
                              selected: isSelected,
                              onTap: () => _toggleOption(label),
                            ),
                          );
                        }),

                        SizedBox(height: 14 * s),

                        // ── Continue button ──
                        Center(
                          child: PrimaryButton(
                            s: s,
                            label: 'CONTINUE',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpSetup4(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 6 * s),

                        Center(
                          child: Text(
                            'By creating an account, you agree to sharing basic health and activity data.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
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
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _HealthOptionTile({
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
          vertical: 8 * s,
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
                  color: selected ? accentColor : const Color(0xFF5A6A74),
                ),
              ),
              SizedBox(width: 11 * s),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w400,
                    color: selected ? const Color(0xFFEAF2F5) : const Color(0xFFB0BEC5),
                  ),
                ),
              ),
              // Checkbox circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20 * s,
                height: 20 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.transparent
                      : Colors.transparent,
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

// ── Gradient border painter for tiles ─────────────────────────────────────────

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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import 'sign_up_setup6.dart';

class SignUpSetup5 extends StatefulWidget {
  const SignUpSetup5({super.key});

  @override
  State<SignUpSetup5> createState() => _SignUpSetup5State();
}

class _SignUpSetup5State extends State<SignUpSetup5> {
  String? _activityLevel;
  final Set<String> _workouts = {};
  double _weekFrequency = 3;
  final Set<String> _daysOff = {};
  bool _daysDropdownOpen = false;

  static const List<Map<String, String>> _activityOptions = [
    {'label': 'Mostly Inactive', 'sub': 'Little planned movement'},
    {'label': 'Lightly Active', 'sub': 'Some walking of light activity'},
    {'label': 'Moderately Active', 'sub': 'Exercise or sports few times a week'},
    {'label': 'Very Active', 'sub': 'Training, Sport, or intense activity most days'},
  ];

  static const List<String> _workoutOptions = [
    'Walking / Light movement',
    'Strength training',
    'Cardio workout',
    'Sports',
    'Yoga / stretching',
    'At-home Workouts',
    'Gym Workouts',
    'No preference / not sure',
  ];

  static const List<String> _allDays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      setupMode: true,
      resizeToAvoidBottomInset: false,
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                        SetupTopBar(s: s, filledCount: 4),

                        SizedBox(height: 8 * s),

                        // ── Title ──
                        Text(
                          "Let's calibrate your profile.",
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
                          text: 'This helps our AI tailor challenges to your current activity level and preferences.',
                        ),

                        SizedBox(height: 10 * s),

                        // ── Activity Level ──
                        SectionLabel(s: s, text: 'Activity Level'),
                        SizedBox(height: 10 * s),

                        ..._activityOptions.map((opt) {
                          final label = opt['label']!;
                          final sub = opt['sub']!;
                          final selected = _activityLevel == label;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 5 * s),
                            child: _ActivityTile(
                              s: s,
                              label: label,
                              sublabel: sub,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _activityLevel = label),
                            ),
                          );
                        }),

                        SizedBox(height: 10 * s),

                        // ── Preferred Workouts ──
                        SectionLabel(s: s, text: 'Preferred Workouts'),
                        SizedBox(height: 10 * s),

                        Wrap(
                          spacing: 8 * s,
                          runSpacing: 8 * s,
                          children: _workoutOptions.map((w) {
                            final selected = _workouts.contains(w);
                            return _WorkoutChip(
                              s: s,
                              label: w,
                              selected: selected,
                              onTap: () => setState(() {
                                if (selected) {
                                  _workouts.remove(w);
                                } else {
                                  _workouts.remove('No preference / not sure');
                                  if (w == 'No preference / not sure') {
                                    _workouts.clear();
                                  }
                                  _workouts.add(w);
                                }
                              }),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 10 * s),

                        // ── Week Frequency ──
                        SectionLabel(s: s, text: 'Week frequency'),
                        SizedBox(height: 6 * s),

                        // Labels row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(8, (i) {
                            return Text(
                              '$i',
                              style: GoogleFonts.inter(
                                fontSize: 12 * s,
                                color: i == _weekFrequency.round()
                                    ? const Color(0xFF00F0FF)
                                    : const Color(0xFF5A6A74),
                                fontWeight: i == _weekFrequency.round()
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            );
                          }),
                        ),

                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2 * s,
                            activeTrackColor: const Color(0xFF00F0FF),
                            inactiveTrackColor: const Color(0xFF26313A),
                            thumbColor: const Color(0xFF00F0FF),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 7 * s,
                            ),
                            overlayColor: const Color(0x2200F0FF),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 14 * s,
                            ),
                          ),
                          child: Slider(
                            value: _weekFrequency,
                            min: 0,
                            max: 7,
                            divisions: 7,
                            onChanged: (v) =>
                                setState(() => _weekFrequency = v),
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        // ── Days off ──
                        SectionLabel(s: s, text: 'What are your days off?'),
                        SizedBox(height: 8 * s),

                        // Dropdown trigger
                        GestureDetector(
                          onTap: () => setState(
                              () => _daysDropdownOpen = !_daysDropdownOpen),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14 * s,
                              vertical: 13 * s,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12 * s),
                              color: _daysDropdownOpen
                                  ? const Color.fromRGBO(0, 240, 255, 0.06)
                                  : const Color.fromRGBO(10, 18, 26, 0.85),
                              border: Border.all(
                                color: _daysDropdownOpen
                                    ? const Color(0xFF00F0FF)
                                    : const Color(0xFF26313A),
                                width: _daysDropdownOpen ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _daysOff.isEmpty
                                        ? ''
                                        : _daysOff.join(', '),
                                    style: GoogleFonts.inter(
                                      fontSize: 13 * s,
                                      color: _daysOff.isEmpty
                                          ? Colors.transparent
                                          : const Color(0xFFB0BEC5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _daysDropdownOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: _daysDropdownOpen
                                      ? const Color(0xFF00F0FF)
                                      : const Color(0xFF5A6A74),
                                  size: 20 * s,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Dropdown list
                        if (_daysDropdownOpen)
                          Container(
                            margin: EdgeInsets.only(top: 4 * s),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12 * s),
                              color: const Color(0xFF0D1820),
                              border: Border.all(
                                color: const Color(0xFF26313A),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: _allDays.asMap().entries.map((e) {
                                final idx = e.key;
                                final day = e.value;
                                final selected = _daysOff.contains(day);
                                final isLast = idx == _allDays.length - 1;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (selected) {
                                      _daysOff.remove(day);
                                    } else {
                                      _daysOff.add(day);
                                    }
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : const Border(
                                              bottom: BorderSide(
                                                color: Color(0xFF26313A),
                                                width: 1,
                                              ),
                                            ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14 * s,
                                      vertical: 11 * s,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            day,
                                            style: GoogleFonts.inter(
                                              fontSize: 13 * s,
                                              fontWeight: FontWeight.w400,
                                              color: selected
                                                  ? const Color(0xFFEAF2F5)
                                                  : const Color(0xFFB0BEC5),
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
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
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Color(0xFF00F0FF),
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        SizedBox(height: 12 * s),

                        // ── Continue button ──
                        Center(
                          child: PrimaryButton(
                            s: s,
                            label: 'CONTINUE',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpSetup6(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16 * s),
        ],
      ),
    );
  }
}


// ── Activity tile ──────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final double s;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.s,
    required this.label,
    required this.sublabel,
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
          vertical: 10 * s,
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
                  Icons.directions_run_rounded,
                  size: 14 * s,
                  color: selected
                      ? const Color(0xFF00F0FF)
                      : const Color(0xFF5A6A74),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w500,
                        color: selected ? const Color(0xFFEAF2F5) : const Color(0xFFD0DCE4),
                      ),
                    ),
                    Text(
                      '"$sublabel"',
                      style: GoogleFonts.inter(
                        fontSize: 10.5 * s,
                        fontWeight: FontWeight.w300,
                        color: selected
                            ? const Color(0xFF7AEEFF)
                            : const Color(0xFF5A6A74),
                      ),
                    ),
                  ],
                ),
              ),
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

// ── Workout chip ───────────────────────────────────────────────────────────────

class _WorkoutChip extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WorkoutChip({
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
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50 * s),
          color: selected
              ? const Color.fromRGBO(0, 240, 255, 0.12)
              : const Color.fromRGBO(10, 18, 26, 0.85),
          border: Border.all(
            color: selected
                ? const Color(0xFF00F0FF)
                : const Color(0xFF26313A),
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
            fontSize: 12 * s,
            fontWeight: FontWeight.w400,
            color: selected ? const Color(0xFF00F0FF) : const Color(0xFFB0BEC5),
          ),
        ),
      ),
    );
  }
}

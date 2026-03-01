import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../api/models/profile_models.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import '../../widgets/digi_gradient_border.dart';
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
    {
      'label': 'Moderately Active',
      'sub': 'Exercise or sports few times a week',
    },
    {
      'label': 'Very Active',
      'sub': 'Training, Sport, or intense activity most days',
    },
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
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      setupMode: true,
      resizeToAvoidBottomInset: false,
      contentPadding: (s) =>
          EdgeInsets.symmetric(horizontal: 17 * s, vertical: 12 * s),
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SetupTopBar(s: s, filledCount: 4),

          SizedBox(height: 24 * s),

          // ── Title ──
          Text(
            "Let’s calibrate your profile.",
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
              'This helps our AI tailor challenges to your current activity level and preferences.',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7680),
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Activity Level ──
          Text(
            'Activity Level',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),

          ..._activityOptions.map((opt) {
            final label = opt['label']!;
            final sub = opt['sub']!;
            final selected = _activityLevel == label;
            return Padding(
              padding: EdgeInsets.only(bottom: 12 * s),
              child: _ActivityTile(
                s: s,
                label: label,
                sublabel: sub,
                selected: selected,
                onTap: () => setState(() => _activityLevel = label),
              ),
            );
          }),

          SizedBox(height: 24 * s),

          // ── Preferred Workouts ──
          Text(
            'Preferred Workouts',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),

          Wrap(
            spacing: 12 * s,
            runSpacing: 12 * s,
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

          SizedBox(height: 24 * s),

          // ── Week Frequency ──
          Text(
            'Week frequency',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20 * s),

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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * s),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2 * s,
                activeTrackColor: const Color(0xFF00F0FF),
                inactiveTrackColor: const Color(0xFF26313A),
                thumbColor: const Color(0xFF00F0FF),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7 * s),
                overlayColor: const Color(0x2200F0FF),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * s),
                activeTickMarkColor: const Color(0xFF00F0FF),
                inactiveTickMarkColor: const Color(0xFF26313A),
                tickMarkShape: const RoundSliderTickMarkShape(
                  tickMarkRadius: 2.5,
                ),
              ),
              child: Slider(
                value: _weekFrequency,
                min: 0,
                max: 7,
                divisions: 7,
                onChanged: (v) => setState(() => _weekFrequency = v),
              ),
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Days off ──
          Text(
            'what are you days off?',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),

          // Dropdown trigger
          GestureDetector(
            onTap: () => setState(() => _daysDropdownOpen = !_daysDropdownOpen),
            child: CustomPaint(
              painter: DigiGradientBorderPainter(
                radius: 12 * s,
                strokeWidth: 1.18,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 13 * s,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * s),
                  color: const Color(0xFF26313A).withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _daysOff.isEmpty ? '' : _daysOff.join(', '),
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          color: const Color(0xFFB0BEC5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white,
                      size: 24 * s,
                    ),
                  ],
                ),
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
                border: Border.all(color: const Color(0xFF26313A), width: 1),
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
                            duration: const Duration(milliseconds: 180),
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
                  );
                }).toList(),
              ),
            ),

          SizedBox(height: 32 * s),

          // ── Continue button ──
          Center(
            child: PrimaryButton(
              s: s,
              label: 'CONTINUE',
              onTap: () async {
                final auth = context.read<AuthProvider>();
                await auth.updateActivity(
                  ProfileActivityPayload(
                    activityLevel: _activityLevel,
                    preferredWorkouts: _workouts.isEmpty
                        ? null
                        : _workouts.toList(),
                    workoutsPerWeek: _weekFrequency.round(),
                    daysOff: _daysOff.isEmpty ? null : _daysOff.toList(),
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpSetup6()),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '"$sublabel"',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7680),
                      ),
                    ),
                  ],
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

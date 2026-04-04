import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'c_by_ai_calculating_screen.dart';
import 'who_health_targets.dart';

/// Step 2 of 2 in the onboarding: user sets their targets.
/// Receives [userInfo] from Step 1 (profile) and merges target fields before
/// navigating to the calculating screen.
class CByAiTargetSetupScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const CByAiTargetSetupScreen({super.key, required this.userInfo});

  @override
  State<CByAiTargetSetupScreen> createState() =>
      _CByAiTargetSetupScreenState();
}

class _CByAiTargetSetupScreenState extends State<CByAiTargetSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final WhoHealthTargets _who;

  // Target controllers
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _targetWaistCtrl;
  late TextEditingController _targetHipCtrl;
  late TextEditingController _targetNeckCtrl;

  // Goal type
  String? _goal; // lose / gain / maintain
  String? _dietaryPreference; // balanced / high_protein / vegan / light_fresh

  static const _cyan = Color(0xFF00F0FF);
  static const _border = Color(0xFF1E2D38);

  static const List<String> _goals = ['lose', 'maintain', 'gain'];
  static const Map<String, String> _goalDisplay = {
    'lose': '🔥 Lose Weight',
    'maintain': '⚖️ Maintain Weight',
    'gain': '💪 Gain Muscle',
  };

  static const List<String> _dietPrefs = [
    'balanced',
    'high_protein',
    'vegan',
    'light_fresh',
  ];
  static const Map<String, String> _dietDisplay = {
    'balanced': 'Balanced',
    'high_protein': 'High Protein',
    'vegan': 'Vegan',
    'light_fresh': 'Light & Fresh',
  };

  @override
  void initState() {
    super.initState();
    _who = WhoHealthTargets.compute(widget.userInfo);
    _goal = _who.suggestedGoal;
    _dietaryPreference = 'balanced';

    _targetWeightCtrl = TextEditingController(
      text: _who.suggestedTargetWeightKg.toStringAsFixed(1),
    );
    _targetWaistCtrl = TextEditingController(
      text: _who.suggestedTargetWaistCm.toStringAsFixed(1),
    );
    _targetHipCtrl = TextEditingController(
      text: _who.suggestedTargetHipCm > 0
          ? _who.suggestedTargetHipCm.toStringAsFixed(1)
          : '',
    );
    _targetNeckCtrl = TextEditingController(
      text: _who.suggestedTargetNeckCm > 0
          ? _who.suggestedTargetNeckCm.toStringAsFixed(1)
          : '',
    );
    // Recompute estimate whenever the user edits the target weight.
    _targetWeightCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _targetWeightCtrl.dispose();
    _targetWaistCtrl.dispose();
    _targetHipCtrl.dispose();
    _targetNeckCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    // Merge target info into the existing userInfo map
    final merged = Map<String, dynamic>.from(widget.userInfo);
    merged['goal'] = _goal ?? 'maintain';
    merged['dietary_preference'] = _dietaryPreference ?? 'balanced';
    merged['target_weight'] =
        double.tryParse(_targetWeightCtrl.text.trim()) ?? 0.0;
    merged['target_waist_circumference'] =
        double.tryParse(_targetWaistCtrl.text.trim()) ?? 0.0;
    merged['target_hip_circumference'] =
        _targetHipCtrl.text.trim().isEmpty
            ? 0.0
            : double.tryParse(_targetHipCtrl.text.trim()) ?? 0.0;
    merged['target_neck_circumference'] =
        _targetNeckCtrl.text.trim().isEmpty
            ? 0.0
            : double.tryParse(_targetNeckCtrl.text.trim()) ?? 0.0;
    merged['plan_period'] = 7; // 7-day plan

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CByAiCalculatingScreen(userInfo: merged),
      ),
    );
  }

  /// Returns a human-readable estimated timeline to reach target weight.
  /// Assumes 0.5 kg/week loss or 0.25 kg/week gain.
  String _estimatedTimeline() {
    final currentWeight =
        (widget.userInfo['weight'] as num?)?.toDouble() ?? 70.0;
    final targetWeight =
        double.tryParse(_targetWeightCtrl.text.trim()) ?? currentWeight;
    final delta = (currentWeight - targetWeight).abs();
    final goal = _goal ?? 'maintain';

    if (goal == 'maintain' || delta < 0.5) return 'You\'re already close to your target!';

    // Rate: 0.5 kg/week for loss, 0.25 kg/week for gain
    final weeklyRate = goal == 'lose' ? 0.5 : 0.25;
    final weeks = (delta / weeklyRate).ceil();
    final months = (weeks / 4.3).ceil();

    if (weeks <= 4) return '~$weeks week${weeks == 1 ? '' : 's'}';
    if (months == 1) return '~1 month';
    return '~$months months';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final currentWeight =
        (widget.userInfo['weight'] as num?)?.toDouble() ?? 70.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/c_by_ai/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Blur + dark overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: .55)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const DigiPillHeader(),
                SizedBox(height: 8 * s),

                // ─── Header with step indicator ─────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    children: [
                      // Step indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stepDot(s, 1, 2, 'Profile'),
                          _stepLine(s, done: true),
                          _stepDot(s, 2, 2, 'Targets'),
                        ],
                      ),
                      SizedBox(height: 16 * s),
                      Text(
                        'YOUR TARGETS',
                        style: GoogleFonts.outfit(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w600,
                          color: _cyan,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'C BY AI',
                        style: GoogleFonts.outfit(
                          fontSize: 32 * s,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        'Targets below are pre-filled from your profile using general WHO-style guidance for adults. You can change anything.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          color: Colors.white.withValues(alpha: .55),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * s),

                // ─── Scrollable form ─────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * s,
                      vertical: 4 * s,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WhoGuidanceCard(s: s, who: _who),
                          SizedBox(height: 14 * s),

                          // ── Time-to-target estimate ────────────
                          _TimeToTargetCard(
                            s: s,
                            currentWeight: currentWeight,
                            timeline: _estimatedTimeline(),
                            goal: _goal ?? 'maintain',
                          ),
                          SizedBox(height: 14 * s),
                          // ── Goal Section ───────────────────────
                          _SectionCard(
                            s: s,
                            title: 'FITNESS GOAL',
                            children: [
                              Text(
                                'What\'s your primary goal?',
                                style: GoogleFonts.outfit(
                                  fontSize: 11 * s,
                                  color: Colors.white.withValues(alpha: .55),
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              ...List.generate(_goals.length, (i) {
                                final g = _goals[i];
                                final isSelected = _goal == g;
                                return GestureDetector(
                                  onTap: () => setState(() => _goal = g),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(bottom: 10 * s),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16 * s,
                                      vertical: 14 * s,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _cyan.withValues(alpha: .15)
                                          : Colors.white.withValues(alpha: .04),
                                      borderRadius:
                                          BorderRadius.circular(12 * s),
                                      border: Border.all(
                                        color: isSelected
                                            ? _cyan
                                            : Colors.white.withValues(
                                                alpha: .1),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _goalDisplay[g] ?? g,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14 * s,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white60,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isSelected)
                                          Icon(Icons.check_circle_rounded,
                                              color: _cyan, size: 20 * s),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (_goal == null) ...[
                                Text(
                                  '  Please select a goal',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9 * s,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 14 * s),

                          // ── Target Measurements ────────────────
                          _SectionCard(
                            s: s,
                            title: 'TARGET MEASUREMENTS',
                            children: [
                              Text(
                                'All fields below are editable — tap to change any number before continuing.',
                                style: GoogleFonts.outfit(
                                  fontSize: 10 * s,
                                  color: Colors.white.withValues(alpha: .45),
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 10 * s),
                              // Hint chip
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * s,
                                  vertical: 8 * s,
                                ),
                                margin: EdgeInsets.only(bottom: 14 * s),
                                decoration: BoxDecoration(
                                  color: _cyan.withValues(alpha: .08),
                                  borderRadius: BorderRadius.circular(8 * s),
                                  border: Border.all(
                                    color: _cyan.withValues(alpha: .2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.straighten_rounded,
                                        color: _cyan, size: 14 * s),
                                    SizedBox(width: 8 * s),
                                    Expanded(
                                      child: Text(
                                        'Current weight: ${currentWeight.toStringAsFixed(1)} kg · '
                                        'Suggested targets use WHO-style BMI & waist guidance · cm',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10 * s,
                                          color: _cyan.withValues(alpha: .8),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _buildField(
                                s: s,
                                label: 'Target Weight (kg)',
                                controller: _targetWeightCtrl,
                                hint: 'e.g. 65',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final n = double.tryParse(v.trim());
                                  if (n == null || n < 20 || n > 500) {
                                    return 'Invalid weight';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 14 * s),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Target Waist (cm)',
                                      controller: _targetWaistCtrl,
                                      hint: 'e.g. 75',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 30 || n > 250) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10 * s),
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Target Hip (cm)',
                                      controller: _targetHipCtrl,
                                      hint: 'e.g. 90',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      validator: (v) {
                                        if (v != null && v.trim().isNotEmpty) {
                                          final n = double.tryParse(v.trim());
                                          if (n == null || n < 30 || n > 300) {
                                            return 'Invalid';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 14 * s),

                              _buildField(
                                s: s,
                                label: 'Target Neck (cm)',
                                controller: _targetNeckCtrl,
                                hint: 'e.g. 36',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                validator: (v) {
                                  if (v != null && v.trim().isNotEmpty) {
                                    final n = double.tryParse(v.trim());
                                    if (n == null || n < 10 || n > 100) {
                                      return 'Invalid';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 14 * s),

                          // ── Dietary Preference ─────────────────
                          _SectionCard(
                            s: s,
                            title: 'DIETARY PREFERENCE',
                            children: [
                              Text(
                                'Choose your preferred meal style',
                                style: GoogleFonts.outfit(
                                  fontSize: 11 * s,
                                  color: Colors.white.withValues(alpha: .55),
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10 * s,
                                mainAxisSpacing: 10 * s,
                                childAspectRatio: 2.8,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _dietPrefs.map((pref) {
                                  final isSelected =
                                      _dietaryPreference == pref;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _dietaryPreference = pref),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _cyan.withValues(alpha: .15)
                                            : Colors.white.withValues(
                                                alpha: .04),
                                        borderRadius:
                                            BorderRadius.circular(10 * s),
                                        border: Border.all(
                                          color: isSelected
                                              ? _cyan
                                              : Colors.white.withValues(
                                                  alpha: .1),
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _dietDisplay[pref] ?? pref,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12 * s,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white60,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_dietaryPreference == null) ...[
                                SizedBox(height: 4 * s),
                                Text(
                                  '  Please select a dietary preference',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9 * s,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 14 * s),

                          // ── 7-Day Plan Info Card ───────────────
                          Container(
                            padding: EdgeInsets.all(16 * s),
                            decoration: BoxDecoration(
                              color: _cyan.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(16 * s),
                              border: Border.all(
                                color: _cyan.withValues(alpha: .25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44 * s,
                                  height: 44 * s,
                                  decoration: BoxDecoration(
                                    color: _cyan.withValues(alpha: .2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.calendar_today_rounded,
                                      color: _cyan, size: 22 * s),
                                ),
                                SizedBox(width: 14 * s),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '7-Day Meal Plan',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14 * s,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4 * s),
                                      Text(
                                        'AI will generate a full week of personalised meals based on your targets.',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11 * s,
                                          color: Colors.white54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 28 * s),

                          // ── Continue Button ────────────────────
                          _ContinueButton(
                            s: s,
                            onTap: () {
                              // Validate goal and dietary pref manually
                              bool extraValid = true;
                              if (_goal == null) {
                                extraValid = false;
                              }
                              if (_dietaryPreference == null) {
                                extraValid = false;
                              }
                              if (!extraValid) {
                                setState(() {}); // Trigger rebuild to show error
                                return;
                              }
                              _onContinue();
                            },
                          ),

                          SizedBox(height: 24 * s),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(double s, int step, int currentStep, String label) {
    final isActive = step == currentStep;
    final isDone = step < currentStep;
    return Column(
      children: [
        Container(
          width: 28 * s,
          height: 28 * s,
          decoration: BoxDecoration(
            color: isActive
                ? _cyan
                : (isDone ? _cyan.withValues(alpha: .5) : Colors.white12),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isDone ? _cyan : Colors.white24,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isDone
              ? Icon(Icons.check_rounded, color: Colors.black, size: 14 * s)
              : Text(
                  '$step',
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.black : Colors.white54,
                  ),
                ),
        ),
        SizedBox(height: 4 * s),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9 * s,
            color: isActive || isDone ? _cyan : Colors.white38,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(double s, {bool done = false}) {
    return Container(
      width: 48 * s,
      height: 1.5,
      margin: EdgeInsets.only(bottom: 16 * s),
      color: done ? _cyan.withValues(alpha: .5) : Colors.white24,
    );
  }

  // ── Field Builder ─────────────────────────────────────────────────────────

  Widget _buildField({
    required double s,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10 * s,
            fontWeight: FontWeight.w600,
            color: _cyan.withValues(alpha: .8),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6 * s),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white),
          cursorColor: _cyan,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 12 * s,
              color: Colors.white.withValues(alpha: .3),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: .06),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14 * s,
              vertical: 12 * s,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: _cyan.withValues(alpha: .2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide: BorderSide(color: _cyan, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * s),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle:
                GoogleFonts.outfit(fontSize: 9 * s, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final double s;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.s,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18 * s),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(
              color: const Color(0xFF00F0FF).withValues(alpha: .2),
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: .09),
                Colors.white.withValues(alpha: .03),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3 * s,
                    height: 14 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F0FF),
                      borderRadius: BorderRadius.circular(2 * s),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF00F0FF).withValues(alpha: .6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .65),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * s),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ── WHO-style guidance (educational) ─────────────────────────────────────────

class _WhoGuidanceCard extends StatelessWidget {
  final double s;
  final WhoHealthTargets who;

  const _WhoGuidanceCard({required this.s, required this.who});

  static const _cyan = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _cyan.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.health_and_safety_outlined, color: _cyan, size: 20 * s),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'World Health Organization — reference',
                      style: GoogleFonts.outfit(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      who.disclaimer,
                      style: GoogleFonts.outfit(
                        fontSize: 10 * s,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          ...who.referenceBullets.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: 8 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('· ', style: TextStyle(color: _cyan, fontSize: 12 * s)),
                  Expanded(
                    child: Text(
                      line,
                      style: GoogleFonts.outfit(
                        fontSize: 11 * s,
                        color: Colors.white.withValues(alpha: .82),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Fitness goal, diet style, and every measurement field can be edited before you generate your plan.',
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: _cyan.withValues(alpha: .85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time-to-Target Card ───────────────────────────────────────────────────────

class _TimeToTargetCard extends StatelessWidget {
  final double s;
  final double currentWeight;
  final String timeline;
  final String goal;

  const _TimeToTargetCard({
    required this.s,
    required this.currentWeight,
    required this.timeline,
    required this.goal,
  });

  static const _cyan = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String label;
    switch (goal) {
      case 'lose':
        icon = Icons.trending_down_rounded;
        label = 'Estimated time to reach your target weight';
        break;
      case 'gain':
        icon = Icons.trending_up_rounded;
        label = 'Estimated time to reach your target weight';
        break;
      default:
        icon = Icons.check_circle_outline_rounded;
        label = 'Estimated time to reach your target weight';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2B2E),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _cyan.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _cyan, size: 22 * s),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10 * s,
                    color: Colors.white54,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  timeline,
                  style: GoogleFonts.outfit(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w800,
                    color: _cyan,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'At healthy rate',
                style: GoogleFonts.outfit(
                  fontSize: 9 * s,
                  color: Colors.white30,
                ),
              ),
              Text(
                goal == 'lose' ? '0.5 kg/week' : goal == 'gain' ? '0.25 kg/week' : '—',
                style: GoogleFonts.outfit(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Continue Button ───────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final double s;
  final VoidCallback onTap;
  const _ContinueButton({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(
            color: const Color(0xFF00F0FF).withValues(alpha: .6),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: .15),
              Colors.white.withValues(alpha: .05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withValues(alpha: .18),
              blurRadius: 20,
              spreadRadius: -4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GENERATE MY 7-DAY PLAN',
              style: GoogleFonts.outfit(
                fontSize: 15 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 8 * s),
            Icon(
              Icons.auto_awesome_rounded,
              color: const Color(0xFF00F0FF),
              size: 18 * s,
            ),
          ],
        ),
      ),
    );
  }
}

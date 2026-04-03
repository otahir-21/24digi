import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_target_setup_screen.dart';
import 'providers/c_by_ai_provider.dart';

class CByAiProfileSetupScreen extends StatefulWidget {
  const CByAiProfileSetupScreen({super.key});

  @override
  State<CByAiProfileSetupScreen> createState() =>
      _CByAiProfileSetupScreenState();
}

class _CByAiProfileSetupScreenState extends State<CByAiProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers – personal info
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _neckCtrl;
  late TextEditingController _waistCtrl;
  late TextEditingController _hipCtrl;

  // Dropdowns
  String? _gender;
  String? _activityLevel;

  bool _initialized = false;
  bool _isSaving = false;

  static const List<String> _genders = ['male', 'female', 'other'];
  static const List<String> _activityLevels = [
    'Mostly inactive (< 1 day/week)',
    'Lightly active (1–2 days/week)',
    'Moderately active (3–5 days/week)',
    'Very active (6–7 days/week)',
  ];

  static const _cyan = Color(0xFF00F0FF);
  static const _border = Color(0xFF1E2D38);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _neckCtrl = TextEditingController();
    _waistCtrl = TextEditingController();
    _hipCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromProfile());
  }

  void _initFromProfile() {
    if (_initialized) return;
    final auth = context.read<AuthProvider>();
    final p = auth.profile;
    if (p != null) {
      _nameCtrl.text = p.name ?? '';
      _ageCtrl.text = p.age?.toString() ?? '';
      _heightCtrl.text = p.heightCm?.toStringAsFixed(0) ?? '';
      _weightCtrl.text = p.weightKg?.toStringAsFixed(0) ?? '';
      _gender = _genders.contains(p.gender) ? p.gender : null;
      _activityLevel = _activityLevels.contains(p.activityLevel)
          ? p.activityLevel
          : null;
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _neckCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    final neck = double.tryParse(_neckCtrl.text.trim()) ?? 38.0;
    final waist = double.tryParse(_waistCtrl.text.trim()) ?? 80.0;
    final hip = double.tryParse(_hipCtrl.text.trim()) ?? 95.0;
    final gender = _gender ?? 'male';
    final measurementError = validateBodyFatCircumferences(
      gender: gender,
      neckCm: neck,
      waistCm: waist,
      hipCm: hip,
    );
    if (measurementError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(measurementError)),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Build the userInfo map
    final userInfo = {
      'name': _nameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 25,
      'height': double.tryParse(_heightCtrl.text.trim()) ?? 175.0,
      'weight': double.tryParse(_weightCtrl.text.trim()) ?? 70.0,
      'gender': gender,
      'activity_level': _activityLevel ?? 'Moderately active (3–5 days/week)',
      'neck_circumference': neck,
      'waist_circumference': waist,
      'hip_circumference': hip,
    };

    // Save profile info back to Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final updateData = <String, dynamic>{
          'name': userInfo['name'],
          'age': userInfo['age'],
          'height_cm': userInfo['height'],
          'weight_kg': userInfo['weight'],
          'gender': userInfo['gender'],
          'activity_level': userInfo['activity_level'],
          'neck_circumference': userInfo['neck_circumference'],
          'waist_circumference': userInfo['waist_circumference'],
          'hip_circumference': userInfo['hip_circumference'],
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance
            .collection('profile')
            .doc(uid)
            .set(updateData, SetOptions(merge: true));

        // Update AuthProvider in memory too
        if (mounted) {
          // Firestore doc is the source of truth; AuthProvider will auto-update
          // on next profile fetch — no in-memory patch needed here.
        }
      }
    } catch (e) {
      log('Profile update error: $e');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Navigate to Target Setup Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CByAiTargetSetupScreen(userInfo: userInfo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

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
                const ShopTopBar(),
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
                          _stepDot(s, 1, 1, 'Profile'),
                          _stepLine(s),
                          _stepDot(s, 2, 1, 'Targets'),
                        ],
                      ),
                      SizedBox(height: 16 * s),
                      Text(
                        'YOUR PROFILE',
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
                        'Review and update your info — it will be saved to your profile.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          color: Colors.white.withValues(alpha: .55),
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
                          // ── Personal Info ──────────────────────
                          _SectionCard(
                            s: s,
                            title: 'PERSONAL INFO',
                            children: [
                              _buildField(
                                s: s,
                                label: 'Full Name',
                                controller: _nameCtrl,
                                hint: 'Enter your name',
                                keyboardType: TextInputType.name,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                              SizedBox(height: 14 * s),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Age',
                                      controller: _ageCtrl,
                                      hint: 'e.g. 25',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        final n = int.tryParse(v.trim());
                                        if (n == null || n < 10 || n > 120) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12 * s),
                                  Expanded(
                                    child: _buildDropdown(
                                      s: s,
                                      label: 'Gender',
                                      value: _gender,
                                      items: _genders,
                                      displayMap: const {
                                        'male': 'Male',
                                        'female': 'Female',
                                        'other': 'Other',
                                      },
                                      hint: 'Select',
                                      onChanged: (v) =>
                                          setState(() => _gender = v),
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 14 * s),

                          // ── Body Measurements ──────────────────
                          _SectionCard(
                            s: s,
                            title: 'BODY MEASUREMENTS',
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Height (cm)',
                                      controller: _heightCtrl,
                                      hint: 'e.g. 175',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
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
                                        if (n == null || n < 50 || n > 300) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12 * s),
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Weight (kg)',
                                      controller: _weightCtrl,
                                      hint: 'e.g. 70',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
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
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14 * s),

                              // Circumferences in a 3-column row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Neck (cm)',
                                      controller: _neckCtrl,
                                      hint: 'e.g. 38',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
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
                                        if (n == null || n < 10 || n > 100) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8 * s),
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Waist (cm)',
                                      controller: _waistCtrl,
                                      hint: 'e.g. 80',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
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
                                  SizedBox(width: 8 * s),
                                  Expanded(
                                    child: _buildField(
                                      s: s,
                                      label: 'Hip (cm)',
                                      controller: _hipCtrl,
                                      hint: 'e.g. 95',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      validator: (v) {
                                        // Required for all, server enforces >= 30
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 30 || n > 300) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 14 * s),

                          // ── Activity Level ─────────────────────
                          _SectionCard(
                            s: s,
                            title: 'ACTIVITY LEVEL',
                            children: [
                              _buildDropdown(
                                s: s,
                                label: 'Activity Level',
                                value: _activityLevel,
                                items: _activityLevels,
                                hint: 'Select your activity level',
                                onChanged: (v) =>
                                    setState(() => _activityLevel = v),
                                validator: (v) => v == null
                                    ? 'Please select your activity level'
                                    : null,
                              ),
                            ],
                          ),

                          SizedBox(height: 28 * s),

                          // ── Next Button ────────────────────────
                          _ActionButton(
                            s: s,
                            label: 'NEXT: SET TARGETS',
                            isLoading: _isSaving,
                            onTap: _onNext,
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
              color: isActive ? _cyan : Colors.white24,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
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
            color: isActive ? _cyan : Colors.white38,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(double s) {
    return Container(
      width: 48 * s,
      height: 1.5,
      margin: EdgeInsets.only(bottom: 16 * s),
      color: Colors.white24,
    );
  }

  // ── Text Field Builder ────────────────────────────────────────────────────

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
          decoration: _inputDecoration(s: s, hint: hint),
        ),
      ],
    );
  }

  // ── Dropdown Builder ──────────────────────────────────────────────────────

  Widget _buildDropdown({
    required double s,
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? displayMap,
    required String hint,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          dropdownColor: const Color(0xFF0D1921),
          iconEnabledColor: _cyan,
          isExpanded: true,
          decoration: _inputDecoration(s: s, hint: hint),
          items: items.map((item) {
            final display = displayMap?[item] ?? item;
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                display,
                style: GoogleFonts.outfit(
                  fontSize: 12 * s,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required double s, required String hint}) {
    return InputDecoration(
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
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10 * s),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.redAccent),
    );
  }
}

// ── Section Card ─────────────────────────────────────────────────────────────

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
                          color: const Color(0xFF00F0FF).withValues(alpha: .6),
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

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final double s;
  final VoidCallback onTap;
  final String label;
  final bool isLoading;
  const _ActionButton({
    required this.s,
    required this.onTap,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Color(0xFF00F0FF),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF00F0FF),
                    size: 18 * s,
                  ),
                ],
              ),
      ),
    );
  }
}



import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_calculating_screen.dart';

class CByAiProfileSetupScreen extends StatefulWidget {
  const CByAiProfileSetupScreen({super.key});

  @override
  State<CByAiProfileSetupScreen> createState() =>
      _CByAiProfileSetupScreenState();
}

class _CByAiProfileSetupScreenState extends State<CByAiProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    // Build the userInfo map that the start API expects
    final userInfo = {
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 25,
      'height': double.tryParse(_heightCtrl.text.trim()) ?? 175.0,
      'weight': double.tryParse(_weightCtrl.text.trim()) ?? 70.0,
      'gender': _gender ?? 'male',
      'activity_level': _activityLevel ?? 'Moderately active (3–5 days/week)',
      'neck_circumference': double.tryParse(_neckCtrl.text.trim()) ?? 38.0,
      'waist_circumference': double.tryParse(_waistCtrl.text.trim()) ?? 80.0,
      'hip_circumference': double.tryParse(_hipCtrl.text.trim()) ?? 95.0,
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CByAiCalculatingScreen(userInfo: userInfo),
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

                // ─── Title ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    children: [
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
                        'Review and complete your info to get your personalised meal plan.',
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
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = int.tryParse(v.trim());
                                        if (n == null || n < 10 || n > 120)
                                          return 'Invalid';
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
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 50 || n > 300)
                                          return 'Invalid';
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
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 20 || n > 500)
                                          return 'Invalid';
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
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 10 || n > 100)
                                          return 'Invalid';
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
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = double.tryParse(v.trim());
                                        if (n == null || n < 30 || n > 250)
                                          return 'Invalid';
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

                          // ── Continue Button ────────────────────
                          _ContinueButton(s: s, onTap: _onContinue),

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

  // ── Text Field Builder ──────────────────────────────────────────────────────

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

  // ── Dropdown Builder ────────────────────────────────────────────────────────

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
                style:
                    GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white),
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

// ── Section Card ───────────────────────────────────────────────────────────────

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
              // Section header
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

// ── Continue Button ────────────────────────────────────────────────────────────

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
        child: Text(
          'CONTINUE',
          style: GoogleFonts.outfit(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_shell.dart';
import '../../widgets/setup_widgets.dart';
import 'sign_up_setup3.dart';

class SignUpSetup2 extends StatefulWidget {
  const SignUpSetup2({super.key});

  @override
  State<SignUpSetup2> createState() => _SignUpSetup2State();
}

class _SignUpSetup2State extends State<SignUpSetup2> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required double s,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    Widget? suffix,
  }) {
    return _PurpleBorderBox(
      s: s,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: GoogleFonts.inter(
          fontSize: 14 * s,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB0BEC5),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7680),
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * s,
            vertical: 12 * s,
          ),
          isDense: true,
        ),
        cursorColor: const Color(0xFF00F0FF),
      ),
    );
  }

  Widget _buildUnitField({
    required double s,
    required TextEditingController controller,
    required String hint,
    required String unit,
  }) {
    return _PurpleBorderBox(
      s: s,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB0BEC5),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7680),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 10 * s,
                ),
                isDense: true,
              ),
              cursorColor: const Color(0xFF00F0FF),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 14 * s),
            child: Text(
              unit,
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7680),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelRow(IconData icon, String label, double s) {
    return Row(
      children: [
        Icon(icon, size: 20 * s, color: const Color(0xFFC084FC)),
        SizedBox(width: 8 * s),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFEAF2F5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      resizeToAvoidBottomInset: true,
      setupMode: true,
      contentPadding: (s) => EdgeInsets.symmetric(
        horizontal: 24 * s,
        vertical: 12 * s,
      ),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          SetupTopBar(s: s, filledCount: 1),
          SizedBox(height: 4 * s),
          Text(
            'This helps AI understand your starting fitness level. You can update it anytime.',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFA8B3BA),
              height: 1.35,
            ),
          ),

          const Spacer(flex: 2),

          // ── Name ──
          _labelRow(Icons.person_outline_rounded, 'Name', s),
          SizedBox(height: 4 * s),
          _buildField(s: s, controller: _nameController, hint: 'Your Name'),

          const Spacer(flex: 2),

          // ── Date of Birth ──
          _labelRow(Icons.calendar_today_outlined, 'Date of Birth', s),
          SizedBox(height: 4 * s),
          _buildField(
            s: s,
            controller: _dobController,
            hint: 'DD / MM / YYYY',
            keyboardType: TextInputType.datetime,
            suffix: Icon(
              Icons.calendar_month_outlined,
              color: const Color(0xFF5A6A74),
              size: 18 * s,
            ),
          ),

          const Spacer(flex: 2),

          // ── Height / Weight ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelRow(Icons.straighten_rounded, 'Height', s),
                    SizedBox(height: 4 * s),
                    _buildUnitField(
                      s: s,
                      controller: _heightController,
                      hint: '0',
                      unit: 'cm',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelRow(Icons.monitor_weight_outlined, 'Weight', s),
                    SizedBox(height: 4 * s),
                    _buildUnitField(
                      s: s,
                      controller: _weightController,
                      hint: '0',
                      unit: 'kg',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(flex: 2),

          // ── Gender ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GenderCircle(
                s: s,
                label: 'Female',
                selected: _selectedGender == 'Female',
                imagePath: 'assets/fonts/female.png',
                onTap: () => setState(() => _selectedGender = 'Female'),
              ),
              _GenderCircle(
                s: s,
                label: 'Male',
                selected: _selectedGender == 'Male',
                imagePath: 'assets/fonts/male.png',
                onTap: () => setState(() => _selectedGender = 'Male'),
              ),
            ],
          ),

          const Spacer(flex: 3),

          // ── Continue + Disclaimer ──
          Center(
            child: PrimaryButton(
              s: s,
              label: 'CONTINUE',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpSetup3()),
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Center(
            child: Text(
              'By creating an account, you agree to sharing basic health and activity data when you connect a 24DIGI device.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFA8B3BA),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurpleBorderBox extends StatelessWidget {
  final double s;
  final Widget child;

  const _PurpleBorderBox({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * s),
        border: Border.all(
          color: const Color(0xFFC084FC), // Figma purple
          width: 1.18,
        ),
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15 * s),
        child: child,
      ),
    );
  }
}

class _GenderCircle extends StatelessWidget {
  final double s;
  final String label;
  final bool selected;
  final String imagePath;
  final VoidCallback onTap;

  const _GenderCircle({
    required this.s,
    required this.label,
    required this.selected,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 82 * s,
            height: 82 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: selected
                    ? const Color(0xFFC084FC)
                    : const Color(0xFF26313A),
                width: selected ? 2.5 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0x55C084FC),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 82 * s,
                height: 82 * s,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                color: selected ? null : const Color(0xFF4A5A64),
                colorBlendMode: selected ? null : BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                label == 'Female' ? Icons.female_rounded : Icons.male_rounded,
                size: 14 * s,
                color: selected
                    ? (label == 'Female' ? const Color(0xFFFF6B8A) : const Color(0xFF6FFFE9))
                    : const Color(0xFFA8B3BA),
              ),
              SizedBox(width: 4 * s),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w500,
                  color: selected ? const Color(0xFFEAF2F5) : const Color(0xFFA8B3BA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
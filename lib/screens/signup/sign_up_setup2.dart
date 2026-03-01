import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/digi_gradient_border.dart';
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

  Widget _labelRow(String label, double s) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 16 * s,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      resizeToAvoidBottomInset: true,
      setupMode: true,
      contentPadding: (s) =>
          EdgeInsets.symmetric(horizontal: 17 * s, vertical: 12 * s),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          SetupTopBar(s: s, filledCount: 1),
          SizedBox(height: 24 * s),
          Text(
            'This helps AI understand your starting fitness level. You can update it anytime.',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFA8B3BA),
              height: 1.35,
            ),
          ),

          SizedBox(height: 24 * s),

          // ── Name ──
          _labelRow('Name', s),
          SizedBox(height: 4 * s),
          _buildField(s: s, controller: _nameController, hint: 'Your Name'),

          SizedBox(height: 24 * s),

          // ── Date of Birth ──
          _labelRow('Date of Birth', s),
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

          SizedBox(height: 24 * s),

          // ── Height / Weight ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelRow('Height', s),
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
                    _labelRow('Weight', s),
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

          SizedBox(height: 24 * s),

          // ── Gender ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderCircle(
                s: s,
                label: 'Female',
                selected: _selectedGender == 'Female',
                imagePath: 'assets/fonts/female.png',
                onTap: () => setState(() => _selectedGender = 'Female'),
              ),
              SizedBox(width: 40 * s),
              _GenderCircle(
                s: s,
                label: 'Male',
                selected: _selectedGender == 'Male',
                imagePath: 'assets/fonts/male.png',
                onTap: () => setState(() => _selectedGender = 'Male'),
              ),
            ],
          ),

          SizedBox(height: 24 * s),

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
        color: Colors.transparent,
      ),
      child: CustomPaint(
        painter: DigiGradientBorderPainter(radius: 15 * s, strokeWidth: 1.18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15 * s),
          child: child,
        ),
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
    final size = 96.0 * s;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? const Color(0xFF00F0FF)
                    : const Color(0xFF26313A),
                width: 2 * s,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00F0FF).withOpacity(0.12),
                  const Color(0xFFCE6AFF).withOpacity(0.12),
                ],
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

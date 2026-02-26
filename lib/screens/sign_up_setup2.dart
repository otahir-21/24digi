import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../painters/smooth_gradient_border.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import '../widgets/setup_widgets.dart';
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
    return _GradientBorderBox(
      s: s,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: GoogleFonts.inter(
          fontSize: 15 * s,
          fontWeight: FontWeight.w300,
          color: const Color(0xFFB0BEC5),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 15 * s,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF4A5A64),
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * s,
            vertical: 14 * s,
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
    return _GradientBorderBox(
      s: s,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFB0BEC5),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF4A5A64),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 14 * s,
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
                fontSize: 13 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5A6A74),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      resizeToAvoidBottomInset: true,
      contentPadding: (s) => EdgeInsets.symmetric(
        horizontal: 24 * s,
        vertical: 22 * s,
      ),
      builder: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SetupTopBar(s: s, filledCount: 1),

                      SizedBox(height: 8 * s),

                      Text(
                        'This helps AI understand your starting fitness level.',
                        style: GoogleFonts.inter(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF7A8A94),
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'Name',
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      _buildField(
                        s: s,
                        controller: _nameController,
                        hint: 'Your Name',
                      ),

                      const Spacer(),

                      Text(
                        'Date of Birth',
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 8 * s),
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

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Height',
                                  style: GoogleFonts.inter(
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 8 * s),
                                _buildUnitField(
                                  s: s,
                                  controller: _heightController,
                                  hint: '0',
                                  unit: 'cm',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight',
                                  style: GoogleFonts.inter(
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 8 * s),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _GenderCircle(
                            s: s,
                            label: 'Female',
                            selected: _selectedGender == 'Female',
                            imagePath: 'assets/fonts/female.png',
                            onTap: () =>
                                setState(() => _selectedGender = 'Female'),
                          ),
                          _GenderCircle(
                            s: s,
                            label: 'Male',
                            selected: _selectedGender == 'Male',
                            imagePath: 'assets/fonts/male.png',
                            onTap: () =>
                                setState(() => _selectedGender = 'Male'),
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      Center(
                        child: PrimaryButton(
                          s: s,
                          label: 'CONTINUE',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpSetup3(),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10 * s),

                      Center(
                        child: Text(
                          'By creating an account, you agree to sharing basic health and activity data.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF5A6A74),
                            height: 1.6,
                          ),
                        ),
                      ),
        ],
      ),
    );
  }
}

class _GradientBorderBox extends StatelessWidget {
  final double s;
  final Widget child;

  const _GradientBorderBox({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 12 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * s),
        child: Container(
          color: const Color.fromRGBO(10, 18, 26, 0.85),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100 * s,
            height: 100 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(10, 18, 26, 0.85),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00F0FF)
                    : const Color(0xFF2C3E4A),
                width: selected ? 2.0 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0x5500F0FF),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 100 * s,
                height: 100 * s,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                color: selected ? null : const Color(0xFF4A5A64),
                colorBlendMode: selected ? null : BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w400,
              color: selected ? Colors.white : const Color(0xFF7A8A94),
            ),
          ),
        ],
      ),
    );
  }
}
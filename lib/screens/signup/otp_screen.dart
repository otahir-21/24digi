import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/screen_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: false,
      resizeToAvoidBottomInset: true,
      builder: (s) => Stack(
          children: [
                    // ── Content from top ──
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30 * s),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60 * s),

                          // ── Enter OTP title ──
                          Text(
                            'Enter OTP',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22 * s,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),

                          SizedBox(height: 36 * s),

                          // ── 4 OTP boxes ──
                          Row(
                            children: List.generate(4, (i) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5 * s),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _OtpBox(
                                      s: s,
                                      controller: _controllers[i],
                                      focusNode: _focusNodes[i],
                                      onChanged: (v) => _onChanged(v, i),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          SizedBox(height: 28 * s),

                          // ── Resend OTP ──
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Resend OTP',
                              style: GoogleFonts.inter(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF7A8A94),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF7A8A94),
                                letterSpacing: 0.4,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── VERIFY button pinned to bottom ──
                    Positioned(
                      bottom: 36 * s,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/setup2'),
                        child: Text(
                          'VERIFY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'LemonMilk',
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
        ),
    );
  }
}

// ── Single OTP digit box ──────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final double s;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.s,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(12, 22, 30, 0.85),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: const Color(0xFF1E2E3A),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.0,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: const Color(0xFF00F0FF),
      ),
    );
  }
}

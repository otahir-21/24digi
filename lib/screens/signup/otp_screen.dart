import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/digi_gradient_border.dart';
import '../../widgets/screen_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _otpCode() => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: false,
      resizeToAvoidBottomInset: true,
      customCardHeightRatio: 0.65, // Design ratio
      centerCard: true,
      contentPadding: (s) => EdgeInsets.zero,
      builder: (s) => Stack(
        children: [
          // ── Content ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100 * s,
                ), // Approx centering vertically in card
                // ── Enter OTP title ──
                Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),

                SizedBox(height: 32 * s),

                // ── 4 OTP boxes ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_otpLength, (i) {
                    return Container(
                      width: 54 * s,
                      height: 54 * s,
                      margin: EdgeInsets.symmetric(horizontal: 6 * s),
                      child: _OtpBox(
                        s: s,
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        onChanged: (v) => _onChanged(v, i),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 36 * s),

                // ── Resend OTP ──
                GestureDetector(
                  onTap: () async {
                    final auth = context.read<AuthProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await auth.resendFirebaseOtp();
                    if (!mounted) return;
                    if (ok) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('OTP resent')),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(auth.errorMessage ?? 'Resend failed'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7680),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF6B7680),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── VERIFY button pinned to bottom ──
          Positioned(
            bottom: 40 * s,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final code = _otpCode();
                if (code.length != _otpLength) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter full OTP')),
                  );
                  return;
                }
                final auth = context.read<AuthProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final ok = await auth.verifyFirebasePhone(code);
                if (!mounted) return;
                if (!ok) {
                  if (auth.isProfileComplete) {
                    navigator.pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  } else {
                    navigator.pushNamedAndRemoveUntil(
                      '/setup2',
                      (route) => false,
                    );
                  }
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage ?? 'Verification failed'),
                    ),
                  );
                }
              },
              child: Text(
                'VERIFY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5 * s,
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
    return CustomPaint(
      painter: DigiGradientBorderPainter(radius: 8 * s, strokeWidth: 1.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF26313A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(8 * s),
        ),
        child: Center(
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
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            cursorColor: const Color(0xFF00F0FF),
          ),
        ),
      ),
    );
  }
}

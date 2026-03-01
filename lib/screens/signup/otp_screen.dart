import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/screen_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _otpCode() =>
      _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: true,
      resizeToAvoidBottomInset: true,
      builder: (s) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 30 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60 * s),

            Text(
              'Enter OTP',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEAF2F5),
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
            if (context.watch<AuthProvider>().otpSentTo != null)
              Padding(
                padding: EdgeInsets.only(top: 8 * s),
                child: Text(
                  'Sent to ${context.watch<AuthProvider>().otpSentTo}',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: const Color(0xFF7A8A94),
                  ),
                ),
              ),

            SizedBox(height: 36 * s),

            Row(
              children: List.generate(_otpLength, (i) {
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

            SizedBox(height: 36 * s),

            GestureDetector(
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
                if (ok) {
                  if (auth.isProfileComplete) {
                    navigator.pushNamedAndRemoveUntil('/home', (route) => false);
                  } else {
                    navigator.pushNamedAndRemoveUntil('/setup2', (route) => false);
                  }
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(auth.errorMessage ?? 'Verification failed')),
                  );
                }
              },
              child: Text(
                'VERIFY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEAF2F5),
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
            ),

            SizedBox(height: 24 * s),
          ],
        ),
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
      painter: _OtpBoxBorderPainter(radius: 15 * s, strokeWidth: 1.18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(34, 43, 54, 0.4),
          borderRadius: BorderRadius.circular(15 * s),
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
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            cursorColor: const Color(0xFF6FFFE9),
          ),
        ),
      ),
    );
  }
}

class _OtpBoxBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;

  const _OtpBoxBorderPainter({required this.radius, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF33FFE8), // Cyan
          Color(0xFFCE6AFF), // Purple
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

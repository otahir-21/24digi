import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/screen_shell.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      scrollable: false,
      resizeToAvoidBottomInset: true,
      contentPadding: (s) => EdgeInsets.zero,
      builder: (s) {
        TextStyle labelStyle(double size) => GoogleFonts.inter(
              fontSize: size * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEAF2F5),
              letterSpacing: 0.4,
            );

        InputDecoration fieldDecor(String hint) => InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFA8B3BA),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF26313A), width: 1.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00F0FF), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 6 * s),
              isDense: true,
            );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 18 * s),
              Center(child: _AvatarCircle(s: s)),
              SizedBox(height: 16 * s),

              Text('Mobile Number', style: labelStyle(18)),
              SizedBox(height: 4 * s),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  color: const Color(0xFFB0BEC5),
                  fontWeight: FontWeight.w300,
                ),
                decoration: fieldDecor('+971 0000000000'),
                cursorColor: const Color(0xFF00F0FF),
              ),

              SizedBox(height: 12 * s),

              Center(
                child: Text(
                  'or',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA8B3BA),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              SizedBox(height: 12 * s),

              Text('E-mail', style: labelStyle(18)),
              SizedBox(height: 4 * s),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  color: const Color(0xFFB0BEC5),
                  fontWeight: FontWeight.w300,
                ),
                decoration: fieldDecor('You@Domain.com'),
                cursorColor: const Color(0xFF00F0FF),
              ),

              SizedBox(height: 8 * s),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13 * s,
                      color: const Color(0xFFA8B3BA),
                    ),
                    SizedBox(width: 6 * s),
                    Expanded(
                      child: Text(
                        'You will receive an OTP to the entered\nphone number/email ID',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFFA8B3BA),
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Center(
                child: GestureDetector(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    if (ApiConfig.bypassOtpForDev) {
                      navigator.pushNamed('/setup2');
                      return;
                    }
                    final phone = _phoneController.text.trim();
                    final email = _emailController.text.trim();
                    final usePhone = phone.isNotEmpty;
                    if (!usePhone && email.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Enter phone number or email')),
                      );
                      return;
                    }
                    final auth = context.read<AuthProvider>();
                    if (!usePhone) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Please use phone number to sign in')),
                      );
                      return;
                    }
                    final result = await auth.startFirebasePhoneVerification(phone);
                    if (!mounted) return;
                    if (result == 'code_sent') {
                      navigator.pushNamed('/otp');
                    } else if (result == 'auto_verified') {
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
                    'LOGIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEAF2F5),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 14 * s),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Glassmorphic avatar circle with cyan/purple gradient
// ─────────────────────────────────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final double s;
  const _AvatarCircle({required this.s});

  @override
  Widget build(BuildContext context) {
    final size = 90.0 * s;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AvatarPainter(),
        child: Center(
          child: Icon(
            Icons.person,
            size: size * 0.55,
            color: const Color(0xFFEAF2F5),
          ),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background fill with radial gradients (matching Figma)
    // Gradient 1: Cyan from top-left
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.6),
        radius: 1.5,
        colors: const [
          Color(0x3333FFE8),
          Color(0x166EBFF4),
          Color(0x004690D5),
        ],
        stops: const [0.0, 0.77, 1.0],
      ).createShader(rect);

    // Gradient 2: Pink/magenta from bottom-right
    final paint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, 0.6),
        radius: 1.3,
        colors: const [
          Color(0x33FF3582),
          Color(0x22FF4B95),
          Color(0x00FF58A0),
        ],
        stops: const [0.0, 0.76, 1.0],
      ).createShader(rect);

    // Draw the shape (pill-like rounded rectangle per Figma path)
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint1);
    canvas.drawPath(path, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:ui';
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
      scrollable: true,
      resizeToAvoidBottomInset: true,
      contentPadding: (s) => EdgeInsets.zero,
      customCardHeightRatio: 0.76, // Tall card for Login
      centerCard: true,
      builder: (s) {
        TextStyle labelStyle(double size) => GoogleFonts.inter(
          fontSize: size * s,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFFFFFF),
          letterSpacing: 0.2 * s,
        );

        InputDecoration fieldDecor(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7680),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF26313A), width: 1.0),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00F0FF), width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8 * s),
          isDense: true,
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32 * s),
              Center(child: _AvatarCircle(s: s)),
              SizedBox(height: 32 * s),

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
                decoration: fieldDecor('+9710000000000'),
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

              SizedBox(height: 24 * s),

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
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                      letterSpacing: 1.5 * s,
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
    final size = 150.0 * s;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40 * s, sigmaY: 40 * s),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.6, -0.6),
              radius: 1.0,
              colors: [
                const Color(0xFF00F0FF).withOpacity(0.08),
                const Color(0xFFCE6AFF).withOpacity(0.04),
                const Color(0xFF000000).withOpacity(0.12),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5 * s,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: size * 0.55,
              color: const Color(0xFFFFFFFF).withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/screen_shell.dart';

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
      builder: (s) {
        TextStyle labelStyle(double size) => GoogleFonts.inter(
              fontSize: size * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.4,
            );

        InputDecoration fieldDecor(String hint) => InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF7A8A94),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2C3E4A), width: 1.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00F0FF), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 6 * s),
              isDense: true,
            );

        return Stack(
          children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30 * s),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  SizedBox(height: 32 * s),

                  // ── Avatar circle ──
                  Center(child: _AvatarCircle(s: s)),

                  SizedBox(height: 28 * s),

                  // ── Mobile Number ──
                  Text('Mobile Number', style: labelStyle(15)),
                  SizedBox(height: 6 * s),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      color: const Color(0xFFB0BEC5),
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: fieldDecor('+9710000000000'),
                    cursorColor: const Color(0xFF00F0FF),
                  ),

                  SizedBox(height: 18 * s),

                  // ── "or" divider ──
                  Center(
                    child: Text(
                      'or',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7A8A94),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 18 * s),

                  // ── E-mail ──
                  Text('E-mail', style: labelStyle(15)),
                  SizedBox(height: 6 * s),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      color: const Color(0xFFB0BEC5),
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: fieldDecor('You@Domain.com'),
                    cursorColor: const Color(0xFF00F0FF),
                  ),

                  SizedBox(height: 18 * s),

                  // ── OTP info note ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2 * s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13 * s,
                          color: const Color(0xFF5A6A74),
                        ),
                        SizedBox(width: 6 * s),
                        Expanded(
                          child: Text(
                            'You will receive an OTP to the entered\nphone number/email ID',
                            style: GoogleFonts.inter(
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF5A6A74),
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── LOGIN button pinned to bottom ──
            Positioned(
              bottom: 36 * s,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/otp'),
                child: Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Glassmorphic avatar circle with cyan/purple gradient ring
// ─────────────────────────────────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final double s;
  const _AvatarCircle({required this.s});

  @override
  Widget build(BuildContext context) {
    final size = 90.0 * s;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: [
            Color(0xFF0D2A30),
            Color(0xFF060F18),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4400F0FF),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Color(0x33CE6AFF),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blur inside
          Positioned.fill(
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Gradient border ring
          Positioned.fill(
            child: CustomPaint(painter: _CircleBorderPainter()),
          ),
          // Person icon
          Center(
            child: Icon(
              Icons.person,
              size: size * 0.55,
              color: const Color(0xFFB0BEC5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0x9900F0FF),
          Color(0x00FFFFFF),
          Color(0x99CE6AFF),
          Color(0x008726B7),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawOval(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

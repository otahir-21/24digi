import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'dart:math' as math;
import 'widgets/profile_top_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeYellow = const Color(0xFFFFB061);
    final uiCyan = const Color(0xFF00F0FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * s),
                    _buildTitleSection(s, themeYellow),
                    SizedBox(height: 24 * s),
                    Center(child: _buildEffectivePill(s)),
                    SizedBox(height: 24 * s),
                    _buildIntroCard(s),
                    SizedBox(height: 32 * s),
                    _buildTermsList(s, uiCyan, themeYellow),
                    SizedBox(height: 48 * s),
                    _buildFooter(s, themeYellow),
                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(double s, Color themeYellow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.description_outlined, color: themeYellow, size: 28 * s),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: GoogleFonts.inter(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                'Last updated February 2026',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEffectivePill(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: const Color(0xFFFFB061),
            size: 14 * s,
          ),
          SizedBox(width: 8 * s),
          Text(
            'Effective: February 1, 2026',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(double s) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        'Welcome to 24DIGI! These Terms of Service govern your use of our fitness, Health tracking application and related services. Please read them carefully before using the app.',
        style: GoogleFonts.inter(
          fontSize: 13 * s,
          color: Colors.white54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildTermsList(double s, Color uiCyan, Color themeYellow) {
    final List<Map<String, String>> terms = [
      {
        'title': '1. Acceptance of Terms',
        'content':
            'By creating an account or using 24DIGI ("the App"), you agree to be bound by these Terms of Service. If you do not agree, you may not access or use the App. We reserve the right to update these terms at any time, and continued use after changes constitutes acceptance.',
      },
      {
        'title': '2. Account Registration',
        'content':
            'You must provide accurate, current, and complete information when registering. You are responsible for maintaining the confidentiality of your account credentials and for all activity under your account. You must be at least 13 years of age to use the App. Users between 13-18 require parental consent.',
      },
      {
        'title': '3. Health & Fitness Disclaimer',
        'content':
            '24DIGI provides fitness tracking and wellness information for general informational purposes only. The App is not a substitute for professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider before beginning any fitness program or making changes to your health routine.',
      },
      {
        'title': '4. User Content & Conduct',
        'content':
            'You retain ownership of content you create or upload. By using the App, you grant 24DIGI a non-exclusive, royalty-free license to use your content for service improvement. You agree not to misuse the App, attempt unauthorized access, or use it for any unlawful purpose.',
      },
      {
        'title': '5. Gamification & Virtual Rewards',
        'content':
            'XP, levels, badges, achievements, and other virtual rewards have no monetary value and cannot be exchanged, traded, or redeemed for real currency. 24DIGI reserves the right to modify, reset, or remove gamification features at any time without prior notice.',
      },
      {
        'title': '6. Subscription & Payments',
        'content':
            'Premium features require an active subscription. Subscriptions auto-renew unless cancelled at least 24 hours before the renewal date. Refunds are handled through your respective app store (Apple App Store or Google Play). Free trial periods, if offered, convert to paid subscriptions unless cancelled.',
      },
      {
        'title': '7. Data Collection & Privacy',
        'content':
            'Your privacy is important to us. Health data, activity metrics, and personal information are collected and processed in accordance with our Privacy Policy. We use industry-standard encryption to protect your data. See our Privacy Policy for full details.',
      },
      {
        'title': '8. Third-Party Integrations',
        'content':
            'The App may integrate with third-party fitness devices, apps, and services. 24DIGI is not responsible for the accuracy or availability of third-party services. Your use of connected services is subject to their respective terms and policies.',
      },
      {
        'title': '9. Intellectual Property',
        'content':
            'All content, features, and functionality of 24DIGI — including but not limited to text, graphics, logos, icons, the gamification system, UI design, and software — are the exclusive property of 24DIGI and are protected by international copyright, trademark, and other intellectual property laws.',
      },
      {
        'title': '10. Limitation of Liability',
        'content':
            '24DIGI is provided "as is" without warranties of any kind. We shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App. In no event shall our total liability exceed the amount you paid for the App in the preceding 12 months.',
      },
      {
        'title': '11. Termination',
        'content':
            'We may terminate or suspend your account at any time for violations of these Terms. You may delete your account at any time through the App settings. Upon termination, your right to use the App ceases immediately. Data retention follows our Privacy Policy guidelines.',
      },
      {
        'title': '12. Governing Law',
        'content':
            'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which 24DIGI operates. Any disputes arising from these Terms shall be resolved through binding arbitration rather than in court.',
      },
    ];

    return Column(
      children: terms
          .map((term) => _buildTermItem(term, s, uiCyan, themeYellow))
          .toList(),
    );
  }

  Widget _buildTermItem(
    Map<String, String> term,
    double s,
    Color borderColor,
    Color titleColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: borderColor.withOpacity(0.5),
          width: 1.5,
          dashSize: 4,
          gapSize: 4,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20 * s),
          color:
              Colors.transparent, // Background handled by parent or transparent
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                term['title']!,
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 12 * s),
              Text(
                term['content']!,
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white54,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double s, Color themeYellow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            'Questions about our Terms?',
            style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white38),
          ),
          SizedBox(height: 4 * s),
          Text(
            'legal@24digi.app',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: themeYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double dashSize;
  final double gapSize;

  DashedBorderPainter({
    required this.color,
    this.width = 1.0,
    this.dashSize = 5.0,
    this.gapSize = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // Top
    _drawDashedLine(canvas, paint, const Offset(0, 0), Offset(size.width, 0));
    // Right
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, 0),
      Offset(size.width, size.height),
    );
    // Bottom
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, size.height),
      Offset(0, size.height),
    );
    // Left
    _drawDashedLine(canvas, paint, Offset(0, size.height), const Offset(0, 0));
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double dashTotal = dashSize + gapSize;
    final int dashCount = (distance / dashTotal).floor();

    final double dxStep = (dx / distance) * dashTotal;
    final double dyStep = (dy / distance) * dashTotal;

    for (int i = 0; i < dashCount; i++) {
      final double xStart = start.dx + dxStep * i;
      final double yStart = start.dy + dyStep * i;
      final double xEnd = xStart + (dx / distance) * dashSize;
      final double yEnd = yStart + (dy / distance) * dashSize;

      // Do not draw past the end point
      final segmentDist = math.sqrt(
        math.pow(xEnd - start.dx, 2) + math.pow(yEnd - start.dy, 2),
      );
      if (segmentDist <= distance) {
        canvas.drawLine(Offset(xStart, yStart), Offset(xEnd, yEnd), paint);
      } else {
        canvas.drawLine(Offset(xStart, yStart), end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

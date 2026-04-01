import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../providers/challenge_provider.dart';
import '../../services/challenge_service.dart';
import 'challenge_dashboard_screen.dart';

class ChallengePaymentScreen extends StatefulWidget {
  const ChallengePaymentScreen({super.key});

  @override
  State<ChallengePaymentScreen> createState() => _ChallengePaymentScreenState();
}

class _ChallengePaymentScreenState extends State<ChallengePaymentScreen> {
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      CustomSnackBar.show(context, message: 'User not found. Please log in again.', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final service = ChallengeService();
      await service.enrollUser(uid, 500);
      
      if (!mounted) return;
      
      // Update provider state
      await context.read<ChallengeProvider>().checkEnrollment();
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChallengeDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(context, message: 'Payment failed: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/challenge/challenge_background.png',
            fit: BoxFit.cover,
          ),
          
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20 * s),
                // Top header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const Spacer(),
                
                // Enrollment Card
                _buildEnrollmentCard(s),
                
                const Spacer(flex: 2),
                
                // Disclaimer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40 * s, vertical: 24 * s),
                  child: Text(
                    'Access is permanent once unlocked.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white24,
                      fontSize: 12 * s,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF00FF88),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24 * s),
                    Text(
                      'PROCESSING ENROLLMENT...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard(double s) {
    return Container(
      width: 320 * s,
      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 40 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withOpacity(0.85),
        borderRadius: BorderRadius.circular(32 * s),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Theme Header
          Text(
            'CHALLENGE ZONE',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00FF88),
              letterSpacing: 4,
            ),
          ),
          
          SizedBox(height: 32 * s),
          
          // Point Icon with Glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110 * s,
                height: 110 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/challenge/challenge_24_gold.png',
                width: 90 * s,
                height: 90 * s,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  'assets/profile/profile_digi_point.png',
                  width: 35 * s,
                  height: 35 * s,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32 * s),
          
          Text(
            'Enrollment Required',
            style: GoogleFonts.outfit(
              fontSize: 22 * s,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 12 * s),
          
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 15 * s,
                color: Colors.white54,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'You have to use '),
                TextSpan(
                  text: '500 DG POINTS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00FF88),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(text: ' to enter the challenge section and unlock exclusive competitions.'),
              ],
            ),
          ),
          
          SizedBox(height: 48 * s),
          
          GestureDetector(
            onTap: _isProcessing ? null : _handlePayment,
            child: Container(
              width: double.infinity,
              height: 58 * s,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF88), Color(0xFF00D1FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18 * s),
              ),
              alignment: Alignment.center,
              child: Text(
                'PAY 500 DG POINT',
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF020A10),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16 * s),
          
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'REDEEM LATER',
              style: GoogleFonts.outfit(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white24,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

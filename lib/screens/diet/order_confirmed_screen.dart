import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'live_tracking_screen.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF161D24),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16 * s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28 * s,
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Large Circle
            Container(
              width: 180 * s,
              height: 180 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B6B), width: 6),
              ),
            ),

            SizedBox(height: 40 * s),

            Text(
              'Order Confirmed!',
              style: GoogleFonts.inter(
                fontSize: 28 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 16 * s),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40 * s),
              child: Text(
                'Your order has been placed successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),

            SizedBox(height: 32 * s),

            Text(
              'Delivery by Thu, 29th, 4:00 PM',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20 * s),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
                );
              },
              child: Text(
                'Track my order',
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B6B),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 60 * s,
                vertical: 40 * s,
              ),
              child: Text(
                'If you have any questions, please reach out directly to our customer support',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  color: Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

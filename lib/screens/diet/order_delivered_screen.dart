import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'leave_review_screen.dart';

class OrderDeliveredScreen extends StatelessWidget {
  const OrderDeliveredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
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
              'Order Delivered!',
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
                'Your order has been successfully delivered, enjoy it!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),

            SizedBox(height: 60 * s),

            GestureDetector(
              onTap: () => _navigateToReview(context),
              child: Text(
                'Rate your delivery',
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 24 * s),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () => _navigateToReview(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    child: Icon(
                      index == 0
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFF6B6B),
                      size: 24 * s,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 60 * s,
                vertical: 40 * s,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white38,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'If you have any questions, please reach out directly to our ',
                    ),
                    TextSpan(
                      text: 'customer support',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaveReviewScreen()),
    );
  }
}

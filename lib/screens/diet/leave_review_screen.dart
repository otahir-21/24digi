import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class LeaveReviewScreen extends StatelessWidget {
  const LeaveReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 10 * s,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Leave a Review',
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D24),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    children: [
                      SizedBox(height: 40 * s),
                      // Dish Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24 * s),
                        child: Image.asset(
                          'assets/diet/diet_best_seller_1.png', // Placeholder
                          width: 160 * s,
                          height: 160 * s,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 24 * s),
                      Text(
                        '24 Chicken',
                        style: GoogleFonts.inter(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * s),
                        child: Text(
                          "We'd love to know what you think of your dish.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 32 * s),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6 * s),
                            child: Icon(
                              Icons.star_outline_rounded,
                              color: const Color(0xFFFF6B6B),
                              size: 36 * s,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32 * s),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Leave us your comment!',
                          style: GoogleFonts.inter(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * s),

                      // Comment Box
                      Container(
                        width: double.infinity,
                        height: 100 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161D24),
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(
                            color: const Color(0xFFFF6B6B).withOpacity(0.5),
                          ),
                        ),
                        padding: EdgeInsets.all(16 * s),
                        child: Text(
                          'Write Review...',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white38,
                          ),
                        ),
                      ),

                      SizedBox(height: 40 * s),

                      Row(
                        children: [
                          Expanded(
                            child: _ReviewButton(
                              s: s,
                              label: 'Cancel',
                              isOutline: true,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 20 * s),
                          Expanded(
                            child: _ReviewButton(
                              s: s,
                              label: 'Submit',
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40 * s),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final double s;
  final String label;
  final bool isOutline;
  final VoidCallback onTap;

  const _ReviewButton({
    required this.s,
    required this.label,
    this.isOutline = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48 * s,
        decoration: BoxDecoration(
          color: isOutline ? const Color(0xFF35414B) : const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(24 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

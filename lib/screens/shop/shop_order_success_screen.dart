import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_gender_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopOrderSuccessScreen extends StatelessWidget {
  const ShopOrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Text(
                      'Check out',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Step Indicator
                    _buildStepIndicator(s),

                    SizedBox(height: 60 * s),

                    Text(
                      'Order Completed',
                      style: GoogleFonts.outfit(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEBC17B),
                      ),
                    ),

                    SizedBox(height: 40 * s),

                    // Styled Gift Bag Icon with Checkmark
                    _buildSuccessIcon(s),

                    SizedBox(height: 60 * s),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      child: Text(
                        'Thank you for your purchase.\nYou can view your order in \'My Orders\'\nsection.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Continue Shopping Button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ShopGenderScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 60 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10 * s,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue shopping',
                          style: GoogleFonts.outfit(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

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

  Widget _buildStepIndicator(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on_rounded, color: Colors.white70, size: 22 * s),
        _buildDots(s),
        Icon(Icons.payment_rounded, color: Colors.white70, size: 22 * s),
        _buildDots(s),
        Container(
          width: 24 * s,
          height: 24 * s,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.black, size: 16 * s),
        ),
      ],
    );
  }

  Widget _buildDots(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * s),
      child: Row(
        children: List.generate(
          5,
          (i) => Container(
            margin: EdgeInsets.symmetric(horizontal: 2 * s),
            width: 3 * s,
            height: 3 * s,
            decoration: const BoxDecoration(
              color: Colors.white38,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(double s) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 140 * s,
          color: const Color(0xFFEBC17B).withOpacity(0.8),
        ),
        Positioned(
          bottom: 15 * s,
          right: 15 * s,
          child: Container(
            padding: EdgeInsets.all(4 * s),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.black, size: 32 * s),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'shop_welcome_screen.dart';
import 'shop_orders_screen.dart';

class ShopOrderSuccessScreen extends StatelessWidget {
  const ShopOrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF3D352F), // Dark brown/charcoal
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
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.0,
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
                    SizedBox(height: 32 * s),
                    
                    // Stepper / Progress Indicator
                    _buildStepper(s),
                    
                    const Spacer(flex: 2),
                    
                    // Order Completed Heading
                    Text(
                      'Order Completed',
                      style: GoogleFonts.outfit(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEBC17B),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Large Success Icon
                    _buildSuccessIcon(s),
                    
                    const Spacer(flex: 2),
                    
                    // Success Message
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopOrdersScreen())),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * s),
                        child: Text(
                          'Thank you for your purchase.\nYou can view your order in \'My Orders\' section.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFEBC17B).withOpacity(0.8),
                            height: 1.4,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // Continue shopping Button
                    GestureDetector(
                      onTap: () {
                         // Navigate back to Shop Root (Welcome or Category)
                         Navigator.of(context).pushAndRemoveUntil(
                           MaterialPageRoute(builder: (_) => const ShopWelcomeScreen()),
                           (route) => route.isFirst,
                         );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue shopping',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s, 
                            fontWeight: FontWeight.w700, 
                            color: const Color(0xFFEBC17B),
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

  Widget _buildStepper(double s) {
    return Row(
      children: [
        _stepIcon(Icons.location_on_rounded, true, s),
        _stepLine(true, s),
        _stepIcon(Icons.payment_rounded, true, s),
        _stepLine(true, s),
        _stepIcon(Icons.check_circle_rounded, true, s),
      ],
    );
  }

  Widget _stepIcon(IconData icon, bool isActive, double s) {
    return Container(
      width: 44 * s,
      height: 44 * s,
      decoration: BoxDecoration(
        color: isActive ? Colors.white10 : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: isActive ? Colors.white : Colors.white24, size: 24 * s),
    );
  }

  Widget _stepLine(bool isActive, double s) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) => _dot(isActive, s)),
      ),
    );
  }

  Widget _dot(bool isActive, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s),
      child: Container(
        width: 4 * s, height: 4 * s,
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.white24, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildSuccessIcon(double s) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 200 * s,
          color: const Color(0xFFEBC17B).withOpacity(0.8),
        ),
        Positioned(
          bottom: 20 * s,
          right: 20 * s,
          child: Container(
            padding: EdgeInsets.all(8 * s),
            decoration: const BoxDecoration(color: Color(0xFF3D352F), shape: BoxShape.circle),
            child: Icon(
              Icons.check_circle_rounded,
              size: 80 * s,
              color: const Color(0xFFEBC17B),
            ),
          ),
        ),
      ],
    );
  }
}

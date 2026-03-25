import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_rate_product_screen.dart';

class ShopOrderDeliveredScreen extends StatelessWidget {
  const ShopOrderDeliveredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40 * s),
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
                    SizedBox(height: 48 * s),
                    
                    // Success Circle Ring
                    Container(
                      width: 180 * s,
                      height: 180 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEFDFCF).withOpacity(0.8), width: 10 * s),
                      ),
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    Text(
                      'Order Delivered!',
                      style: GoogleFonts.outfit(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20 * s),
                    Text(
                      'Your order has been succesfully\ndelivered, enjoy it!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopRateProductScreen())),
                      child: Column(
                        children: [
                          Text(
                            'Rate your delivery',
                            style: GoogleFonts.outfit(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16 * s),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) => Icon(
                              Icons.star_outline_rounded,
                              size: 28 * s,
                              color: Colors.white,
                            )),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      'If you have any questions, please reach out\ndirectly to our customer support',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        color: Colors.white38,
                        height: 1.4,
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
}

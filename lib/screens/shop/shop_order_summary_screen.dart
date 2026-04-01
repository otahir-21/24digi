import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_gender_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_live_tracking_screen.dart';

class ShopOrderSummaryScreen extends StatelessWidget {
  const ShopOrderSummaryScreen({super.key});

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                    SizedBox(height: 24 * s),
                    Text(
                      'Order #1524',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Tracking Banner
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShopLiveTrackingScreen(),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your order is on the way',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFEBC17B),
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                  Text(
                                    'Click here to track your order',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12 * s,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 48 * s,
                              color: const Color(0xFFEBC17B),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Order Details Section
                    _buildOrderDetails(s),

                    SizedBox(height: 32 * s),

                    // Itemized breakdown
                    _summaryItem('Sportwear Set', 'x1', '200', s),
                    _summaryItem('Cotton T-shirt', 'x1', '200', s),

                    SizedBox(height: 12 * s),
                    Divider(color: Colors.white10),
                    SizedBox(height: 12 * s),

                    _rowItem('Sub Total', '200', s),
                    _rowItem('Shipping', '0.00', s, showCoin: false),

                    SizedBox(height: 12 * s),
                    Divider(color: Colors.white10, thickness: 1.5 * s),
                    SizedBox(height: 12 * s),

                    _rowItem('Total', '200', s, isTotal: true),

                    SizedBox(height: 48 * s),

                    // Continue shopping Button
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

  Widget _buildOrderDetails(double s) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order number',
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                color: const Color(0xFFEBC17B),
              ),
            ),
            Text(
              '#1524',
              style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tracking Number',
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                color: const Color(0xFFEBC17B),
              ),
            ),
            Text(
              'IK287368838',
              style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery address',
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                color: const Color(0xFFEBC17B),
              ),
            ),
            SizedBox(width: 20 * s),
            Expanded(
              child: Text(
                'SBI Building, Software Park',
                textAlign: TextAlign.right,
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryItem(String name, String qty, String price, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            qty,
            style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70),
          ),
          SizedBox(width: 40 * s),
          Text(
            price,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6 * s),
          Image.asset(
            'assets/profile/profile_digi_point.png',
            width: 22 * s,
            height: 22 * s,
          ),
        ],
      ),
    );
  }

  Widget _rowItem(
    String label,
    String value,
    double s, {
    bool isTotal = false,
    bool showCoin = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 16 * s : 14 * s,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? Colors.white : Colors.white70,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: isTotal ? 18 * s : 16 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (showCoin) ...[
              SizedBox(width: 6 * s),
              Image.asset(
                'assets/profile/profile_digi_point.png',
                width: 22 * s,
                height: 22 * s,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

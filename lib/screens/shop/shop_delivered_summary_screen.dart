import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_order_delivered_screen.dart';

class ShopDeliveredSummaryScreen extends StatelessWidget {
  const ShopDeliveredSummaryScreen({super.key});

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
                      'Order #1514',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Delivered Banner
                    Container(
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
                                  'Your order is delivered',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16 * s,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEBC17B),
                                  ),
                                ),
                                SizedBox(height: 8 * s),
                                Text(
                                  'Rate product to get 5 points for collect.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12 * s,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 40 * s,
                            color: const Color(0xFFEBC17B),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Order Details Section
                    _buildOrderDetails(s),

                    SizedBox(height: 32 * s),

                    // Itemized breakdown
                    _summaryItem('Maxi Dress', 'x1', '200', s),
                    _summaryItem('Linen Dress', 'x1', '200', s),
                    
                    SizedBox(height: 24 * s),
                    _rowItem('Sub Total', '200', s),
                    _rowItem('Shipping', '0.00', s, showCoin: false),
                    SizedBox(height: 12 * s),
                    Divider(color: Colors.white10),
                    SizedBox(height: 12 * s),
                    _rowItem('Total', '200', s, isTotal: true),

                    SizedBox(height: 48 * s),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            child: Container(
                              height: 50 * s,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Return home',
                                style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopOrderDeliveredScreen())),
                            child: Container(
                              height: 50 * s,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFDFCF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Rate',
                                style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
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
            Text('Order number', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38)),
            Text('#1514', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tracking Number', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38)),
            Text('IK987362341', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery address', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38)),
            Text('Umm Al Quwain - Al Madar', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  Widget _summaryItem(String name, String qty, String price, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      child: Row(
        children: [
          Expanded(child: Text(name, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70))),
          Text(qty, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
          SizedBox(width: 40 * s),
          Text(price, style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(width: 6 * s),
          Image.asset('assets/profile/profile_digi_point.png', width: 22 * s, height: 22 * s),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value, double s, {bool isTotal = false, bool showCoin = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: isTotal ? 16 * s : 14 * s, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400, color: isTotal ? Colors.white : Colors.white38)),
        Row(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: isTotal ? 18 * s : 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
            if (showCoin) ...[
              SizedBox(width: 6 * s),
              Image.asset('assets/profile/profile_digi_point.png', width: 22 * s, height: 22 * s),
            ],
          ],
        ),
      ],
    );
  }
}

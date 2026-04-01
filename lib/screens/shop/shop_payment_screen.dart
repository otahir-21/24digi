import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_order_success_screen.dart'; // The Order Confirmed screen
import 'shop_shipping_address_screen.dart';

class ShopPaymentScreen extends StatelessWidget {
  const ShopPaymentScreen({super.key});

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
                      'Payment',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Order Summary Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * s,
                            vertical: 4 * s,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF32302E),
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                          child: Text(
                            'Edit',
                            style: GoogleFonts.outfit(
                              fontSize: 12 * s,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _summaryItem('Sportwear Set', 'x1', '200', s),
                    _summaryItem('Cotton T-shirt', 'x1', '200', s),
                    SizedBox(height: 12 * s),
                    Divider(color: Colors.white10),
                    SizedBox(height: 12 * s),
                    _rowItem('Sub Total', '200', s),
                    _rowItem('Shipping', '0.00', s, showCoin: false),
                    SizedBox(height: 12 * s),
                    Divider(color: Colors.white10),
                    SizedBox(height: 12 * s),
                    _rowItem('Total', '200', s, isTotal: true),

                    SizedBox(height: 48 * s),

                    // Shipping Address Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping Address',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShopShippingAddressScreen(),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.white70,
                            size: 20 * s,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * s),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                        vertical: 14 * s,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1813),
                        borderRadius: BorderRadius.circular(24 * s),
                      ),
                      child: Text(
                        '778 Al Madar, Umm Al Quwain',
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Delivery Time
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Delivery Time',
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: GoogleFonts.outfit(
                            fontSize: 12 * s,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          '2-3 Days',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 48 * s),

                    // Buttons
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShopOrderSuccessScreen(),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBC17B),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Confirm and Pay',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
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

  Widget _summaryItem(String name, String qty, String price, double s) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_add_address_screen.dart';
import 'shop_order_success_screen.dart'; // Or wherever checkout leads

class ShopShippingAddressScreen extends StatefulWidget {
  const ShopShippingAddressScreen({super.key});

  @override
  State<ShopShippingAddressScreen> createState() => _ShopShippingAddressScreenState();
}

class _ShopShippingAddressScreenState extends State<ShopShippingAddressScreen> {
  int _selectedAddressIndex = 0;

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
                    SizedBox(height: 32 * s),
                    Text(
                      'Choose the\nShipping Address',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Address List Container
                    Container(
                      padding: EdgeInsets.all(20 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2622),
                        borderRadius: BorderRadius.circular(24 * s),
                      ),
                      child: Column(
                        children: [
                          _buildAddressCard(0, s),
                          SizedBox(height: 16 * s),
                          _buildAddressCard(1, s),
                          SizedBox(height: 16 * s),
                          _buildAddressCard(2, s),
                          SizedBox(height: 24 * s),
                          
                          // Add Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ShopAddAddressScreen()),
                              ),
                              child: Container(
                                width: 44 * s,
                                height: 44 * s,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E1C1A),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add, color: Colors.white, size: 24 * s),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48 * s),

                    // Continue Button
                    GestureDetector(
                      onTap: () {
                        // For now navigate to Success as a placeholder for checkout flow
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShopOrderSuccessScreen()),
                        );
                      },
                      child: Container(
                        width: 250 * s,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBC17B),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'continue',
                          style: GoogleFonts.outfit(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
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

  Widget _buildAddressCard(int index, double s) {
    bool isSelected = _selectedAddressIndex == index;

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEFDFCF),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'John Doe',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopAddAddressScreen(isEditing: true)),
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.outfit(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDB3022),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          Text(
            '24 GYM Building\nAl Madar2, Umm Al Quwain , UAE',
            style: GoogleFonts.outfit(
              fontSize: 13 * s,
              color: Colors.black.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: () => setState(() => _selectedAddressIndex = index),
            child: Row(
              children: [
                Container(
                  width: 20 * s,
                  height: 20 * s,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(4 * s),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: isSelected 
                      ? Icon(Icons.check, size: 14 * s, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12 * s),
                Text(
                  'Use as the shipping address',
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_cart_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopProductDetailScreen extends StatefulWidget {
  const ShopProductDetailScreen({super.key});

  @override
  State<ShopProductDetailScreen> createState() =>
      _ShopProductDetailScreenState();
}

class _ShopProductDetailScreenState extends State<ShopProductDetailScreen> {
  String _selectedSize = 'L';
  String _selectedColor = 'Black';

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images (Main image)
                  Stack(
                    children: [
                      Image.asset(
                        'assets/shop/shop_main_1.png',
                        width: double.infinity,
                        height: 520 * s,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 520 * s,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              const Color(0xFF332F2B).withOpacity(0.8),
                              const Color(0xFF332F2B),
                            ],
                            stops: const [0.0, 0.4, 0.9, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12 * s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'H&M',
                              style: GoogleFonts.outfit(
                                fontSize: 24 * s,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFEBC17B),
                              ),
                            ),
                            Text(
                              '\$51',
                              style: GoogleFonts.outfit(
                                fontSize: 24 * s,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * s),
                        Text(
                          'H&M Pullover',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 16 * s),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16 * s,
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            Text(
                              '(10)',
                              style: GoogleFonts.outfit(
                                fontSize: 14 * s,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32 * s),

                        // Dropdowns for Size and Color
                        Row(
                          children: [
                            _buildDropdown(
                              'Size',
                              _selectedSize,
                              ['S', 'M', 'L', 'XL'],
                              (val) => setState(() => _selectedSize = val!),
                              s,
                            ),
                            SizedBox(width: 16 * s),
                            _buildDropdown(
                              'Color',
                              _selectedColor,
                              ['Black', 'Gray', 'White'],
                              (val) => setState(() => _selectedColor = val!),
                              s,
                            ),
                            const Spacer(),
                            // Favorite Button
                            Container(
                              width: 48 * s,
                              height: 48 * s,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Icon(
                                Icons.favorite_outline,
                                color: Colors.white,
                                size: 24 * s,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32 * s),

                        Text(
                          'Short dress in soft jersey with a fitted upper part, flared skirt and ruffle trim at the hem. Very comfortable and stylish for daily wear.',
                          style: GoogleFonts.outfit(
                            fontSize: 16 * s,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),

                        SizedBox(height: 120 * s), // Spacing for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Top Bar
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: const ShopTopBar(),
            ),

            // Add to Cart Button (Bottom Fixed)
            Positioned(
              bottom: 40 * s,
              left: 24 * s,
              right: 24 * s,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShopCartScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1813),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 15 * s,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ADD TO BAG',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    double s,
  ) {
    return Container(
      width: 120 * s,
      height: 48 * s,
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 20 * s,
          ),
          dropdownColor: const Color(0xFF1B1813),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16 * s,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

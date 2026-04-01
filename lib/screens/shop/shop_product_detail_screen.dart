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
  State<ShopProductDetailScreen> createState() => _ShopProductDetailScreenState();
}

class _ShopProductDetailScreenState extends State<ShopProductDetailScreen> {
  String _selectedSize = 'M';
  Color _selectedColor = const Color(0xFFC68E4E);

  final List<String> _sizes = ['S', 'M', 'L', 'XL', '2XL'];
  final List<Color> _colors = [
    const Color(0xFFC68E4E), // Brown
    const Color(0xFFDB3022), // Red
    const Color(0xFF1B1E28), // Dark Blue
    const Color(0xFF4A5F6B), // Greyish Navy
    const Color(0xFFF1F1F1), // Off White
    const Color(0xFF5D4037), // Darker Brown
    const Color(0xFFEBC17B), // Goldish
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A), // Dark charcoal background matching design
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 20 * s),

                    // Main Product Image
                    Center(
                      child: Container(
                        width: 345 * s,
                        height: 380 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/shop/shop_main_1.png', // Fallback to provided asset
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * s),

                    // Title & Price Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Men's Printed Pullover Hoodie",
                                style: GoogleFonts.outfit(
                                  fontSize: 12 * s,
                                  color: Colors.white60,
                                ),
                              ),
                              Text(
                                "Price",
                                style: GoogleFonts.outfit(
                                  fontSize: 12 * s,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * s),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nike Club Fleece',
                                style: GoogleFonts.outfit(
                                  fontSize: 26 * s,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEBC17B),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '200',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28 * s,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFEBC17B),
                                    ),
                                  ),
                                  SizedBox(width: 8 * s),
                                  Image.asset(
                                    'assets/profile/profile_digi_point.png',
                                    width: 32 * s,
                                    height: 32 * s,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Thumbnail Gallery
                    _buildGallery(s),
                    SizedBox(height: 24 * s),

                    // Selection Section (Size & Color)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Size', 'Size Guide', s),
                          SizedBox(height: 16 * s),
                          _buildSizeGrid(s),
                          SizedBox(height: 32 * s),
                          _buildSectionTitle('Color', '', s),
                          SizedBox(height: 16 * s),
                          _buildColorRow(s),
                          SizedBox(height: 32 * s),
                          _buildSectionTitle('Description', '', s),
                          SizedBox(height: 12 * s),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.outfit(
                                fontSize: 14 * s,
                                height: 1.6,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'The Nike Throwback Pullover Hoodie is made from premium French terry fabric that blends a performance feel with ',
                                ),
                                TextSpan(
                                  text: 'Read More..',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFEBC17B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32 * s),
                          _buildSectionTitle('Reviews', 'View All', s),
                          SizedBox(height: 16 * s),
                          _buildReviewCard(s),
                        ],
                      ),
                    ),
                    SizedBox(height: 120 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Sticky Add to Cart Button
      bottomSheet: _buildBottomBar(s),
    );
  }

  Widget _buildGallery(double s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Row(
        children: List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.only(right: 12 * s),
            width: 76 * s,
            height: 60 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * s),
              image: const DecorationImage(
                image: AssetImage('assets/shop/shop_main_1.png'),
                fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action, double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEBC17B),
            ),
          ),
      ],
    );
  }

  Widget _buildSizeGrid(double s) {
    return Row(
      children: _sizes.map((size) {
        bool isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: Container(
            width: 60 * s,
            height: 48 * s,
            margin: EdgeInsets.only(right: 8 * s),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEBC17B) : const Color(0xFF1B1813),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            alignment: Alignment.center,
            child: Text(
              size,
              style: GoogleFonts.outfit(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorRow(double s) {
    return Row(
      children: _colors.map((color) {
        bool isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            margin: EdgeInsets.only(right: 12 * s),
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20 * s,
                backgroundImage: const AssetImage('assets/fonts/male.png'),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ronald Richards',
                      style: GoogleFonts.outfit(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '13 Sep, 2025',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '4.8 rating',
                    style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        Icons.star,
                        size: 10 * s,
                        color: i < 4 ? Colors.amber : Colors.white30,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            'Super comfortable and warm with a great fit. The fleece is soft, the print looks good, and it holds up well after washing. Perfect for everyday wear.',
            style: GoogleFonts.outfit(
              fontSize: 13 * s,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double s) {
    return Container(
      color: const Color(0xFF1E1C1A),
      padding: EdgeInsets.fromLTRB(24 * s, 10 * s, 24 * s, 30 * s),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShopCartScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 60 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1813),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/profile/profile_digi_point.png', // Placeholder for bag icon if needed, or stick to the check.
                width: 24 * s,
                height: 24 * s,
                color: const Color(0xFFEBC17B),
              ),
              SizedBox(width: 12 * s),
              Text(
                'Add To Cart',
                style: GoogleFonts.outfit(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

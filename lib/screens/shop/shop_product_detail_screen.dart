import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'shop_cart_screen.dart';

class ShopProductDetailScreen extends StatefulWidget {
  const ShopProductDetailScreen({super.key});

  @override
  State<ShopProductDetailScreen> createState() => _ShopProductDetailScreenState();
}

class _ShopProductDetailScreenState extends State<ShopProductDetailScreen> {
  String _selectedSize = 'S';
  Color _selectedColor = Colors.orange;

  final List<String> _sizes = ['S', 'M', 'L', 'XL', '2XL'];
  final List<Color> _colors = [
    Colors.orange,
    Colors.redAccent,
    const Color(0xFF1B2329),
    const Color(0xFF4A5F6A),
    Colors.white,
    Colors.brown,
    const Color(0xFFEBC17B),
  ];

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20 * s),
                      child: Image.asset(
                        'assets/shop/nike_hoodie.png',
                        width: double.infinity,
                        height: 380 * s,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    SizedBox(height: 12 * s),
                    
                    // Product Title & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                  "Men's Printed Pullover Hoodie",
                                  style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white70),
                               ),
                               SizedBox(height: 12 * s),
                               Text(
                                  "Nike Club Fleece",
                                  style: GoogleFonts.outfit(
                                    fontSize: 24 * s, 
                                    fontWeight: FontWeight.w800, 
                                    color: const Color(0xFFEBC17B),
                                  ),
                               ),
                             ],
                           ),
                         ),
                         Row(
                           children: [
                             Text(
                                "200",
                                style: GoogleFonts.outfit(
                                  fontSize: 28 * s, 
                                  fontWeight: FontWeight.w800, 
                                  color: Colors.white,
                                ),
                             ),
                             SizedBox(width: 8 * s),
                             _dpIcon(s, size: 40),
                           ],
                         ),
                      ],
                    ),
                    
                    SizedBox(height: 20 * s),
                    
                    // Image Gallery
                    SizedBox(
                      height: 80 * s,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, __) => SizedBox(width: 12 * s),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80 * s,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12 * s),
                              image: DecorationImage(
                                image: AssetImage('assets/shop/nike_hoodie.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 24 * s),
                    
                    // Size Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Size', style: GoogleFonts.outfit(fontSize: 16 * s, color: const Color(0xFFEBC17B), fontWeight: FontWeight.w600)),
                        Text('Size Guide', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(height: 12 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _sizes.map((size) => _buildSelectionBox(size, _selectedSize == size, s, (val) => setState(() => _selectedSize = val))).toList(),
                    ),
                    
                    SizedBox(height: 24 * s),
                    
                    // Color Selector
                    Text('Color', style: GoogleFonts.outfit(fontSize: 16 * s, color: const Color(0xFFEBC17B), fontWeight: FontWeight.w600)),
                    SizedBox(height: 12 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _colors.map((color) => _buildColorCircle(color, _selectedColor == color, s, (val) => setState(() => _selectedColor = val))).toList(),
                    ),
                    
                    SizedBox(height: 24 * s),
                    
                    // Description
                    Text('Description', style: GoogleFonts.outfit(fontSize: 16 * s, color: const Color(0xFFEBC17B), fontWeight: FontWeight.w600)),
                    SizedBox(height: 12 * s),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70, height: 1.5),
                        children: [
                          const TextSpan(text: "The Nike Throwback Pullover Hoodie is made from premium French terry fabric that blends a performance feel with "),
                          TextSpan(
                            text: "Read More..",
                            style: GoogleFonts.outfit(color: const Color(0xFFEBC17B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32 * s),
                    
                    // Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reviews', style: GoogleFonts.outfit(fontSize: 16 * s, color: const Color(0xFFEBC17B), fontWeight: FontWeight.w600)),
                        Text('View All', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(height: 16 * s),
                    _buildReviewCard(s),
                    
                    SizedBox(height: 100 * s), // Spacing for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildAddToCartButton(context, s),
    );
  }

  Widget _buildSelectionBox(String label, bool isSelected, double s, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        width: 60 * s,
        height: 50 * s,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B1813) : const Color(0xFF1B1813).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12 * s),
          border: isSelected ? Border.all(color: const Color(0xFF00F0FF), width: 1.5) : Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.outfit(fontSize: 16 * s, color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildColorCircle(Color color, bool isSelected, double s, Function(Color) onTap) {
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32 * s,
        height: 32 * s,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.5), blurRadius: 8)] : null,
        ),
      ),
    );
  }

  Widget _buildReviewCard(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 20 * s, backgroundImage: AssetImage('assets/fonts/male.png')),
            SizedBox(width: 12 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ronald Richards', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12 * s, color: Colors.white38),
                    SizedBox(width: 4 * s),
                    Text('13 Sep, 2025', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('4.8 rating', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white70)),
                Row(
                  children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_border, color: Colors.orange, size: 10 * s)),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        Text(
          "Super comfortable and warm with a great fit. The fleece is soft, the print looks good, and it holds up well after washing. Perfect for everyday wear.",
          style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, double s) {
    return Container(
      color: const Color(0xFF3D352F),
      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 20 * s),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopCartScreen())),
        child: Container(
          width: double.infinity,
          height: 60 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1813),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_rounded, color: const Color(0xFFEBC17B), size: 24 * s),
              SizedBox(width: 12 * s),
              Text(
                'Add To Cart',
                style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: const Color(0xFFEBC17B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dpIcon(double s, {double size = 14}) {
    return Container(
      width: size * s * 0.7, height: size * s * 0.7,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F0FF), width: 1.5)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: size * s * 0.25, fontWeight: FontWeight.w900, color: const Color(0xFF00F0FF))),
    );
  }
}

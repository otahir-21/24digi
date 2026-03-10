import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';

class ShopRateProductScreen extends StatefulWidget {
  const ShopRateProductScreen({super.key});

  @override
  State<ShopRateProductScreen> createState() => _ShopRateProductScreenState();
}

class _ShopRateProductScreenState extends State<ShopRateProductScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

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
                      'Rate Product',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    // Promo banner
                    _buildPromoBanner(s),
                    
                    SizedBox(height: 32 * s),
                    
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Icon(
                            index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFEBC17B),
                            size: 44 * s,
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 32 * s),
                    
                    // Text Input
                    _buildTextInput(s),
                    
                    SizedBox(height: 24 * s),
                    
                    // Photo Upload Placeholders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _uploadBox(Icons.image_outlined, s),
                        SizedBox(width: 16 * s),
                        _uploadBox(Icons.camera_alt_outlined, s),
                      ],
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    // Submit Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 60 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Submit Review',
                          style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: const Color(0xFFEBC17B)),
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

  Widget _buildPromoBanner(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard_rounded, color: const Color(0xFFEBC17B), size: 24 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              "Submit your review to get 5 points",
              style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 24 * s),
        ],
      ),
    );
  }

  Widget _buildTextInput(double s) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5).withOpacity(0.9), // Light beige
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _reviewController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Would you like to write anything about this product?',
              hintStyle: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black45),
              border: InputBorder.none,
            ),
            style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black, height: 1.5),
          ),
          Text(
            '50 characters',
            style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _uploadBox(IconData icon, double s) {
    return Container(
      width: 60 * s, height: 60 * s,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white24, style: BorderStyle.solid),
      ),
      child: Icon(icon, color: Colors.white38, size: 24 * s),
    );
  }
}

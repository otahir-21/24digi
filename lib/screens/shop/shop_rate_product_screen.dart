import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopRateProductScreen extends StatefulWidget {
  const ShopRateProductScreen({super.key});

  @override
  State<ShopRateProductScreen> createState() => _ShopRateProductScreenState();
}

class _ShopRateProductScreenState extends State<ShopRateProductScreen> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
                      'Rate Product',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Bonus Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 16 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1813),
                        borderRadius: BorderRadius.circular(12 * s),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard_rounded, color: const Color(0xFFEBC17B), size: 24 * s),
                          SizedBox(width: 16 * s),
                          Expanded(
                            child: Text(
                              'Submit your review to get 5 points',
                              style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white70),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20 * s),
                        ],
                      ),
                    ),

                    SizedBox(height: 40 * s),

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        bool isSelected = index < _selectedStars;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStars = index + 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8 * s),
                            child: Icon(
                              Icons.star_rounded,
                              size: 44 * s,
                              color: isSelected ? const Color(0xFFEBC17B) : Colors.white24,
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 48 * s),

                    // Text Field
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24 * s),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _commentController,
                            maxLines: 6,
                            style: GoogleFonts.outfit(fontSize: 15 * s, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Would you like to write anything about this product?',
                              hintStyle: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black38),
                              border: InputBorder.none,
                            ),
                          ),
                          Text(
                            '50 characters',
                            style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.black38),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Upload Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _uploadBox(Icons.image_outlined, s),
                        SizedBox(width: 24 * s),
                        _uploadBox(Icons.camera_alt_outlined, s),
                      ],
                    ),

                    SizedBox(height: 48 * s),

                    // Submit Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: Container(
                        width: double.infinity,
                        height: 56 * s,
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

  Widget _uploadBox(IconData icon, double s) {
    return Container(
      width: 70 * s,
      height: 70 * s,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white24, style: BorderStyle.solid, width: 1.5),
      ),
      child: ClipRRect(
         borderRadius: BorderRadius.circular(16 * s),
         child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Icon(icon, color: Colors.white, size: 28 * s),
            ),
         ),
      ),
    );
  }
}

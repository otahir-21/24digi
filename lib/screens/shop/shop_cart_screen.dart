import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'shop_order_success_screen.dart';

class ShopCartScreen extends StatelessWidget {
  const ShopCartScreen({super.key});

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
                      'My Bag',
                      style: GoogleFonts.outfit(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    // Cart Items
                    _CartItem(
                      s: s,
                      image: 'assets/shop/shop_main_5.png',
                      title: 'Pullover',
                      color: 'Black',
                      size: 'L',
                      price: '200',
                    ),
                    SizedBox(height: 20 * s),
                    _CartItem(
                      s: s,
                      image: 'assets/shop/shop_main_4.png',
                      title: 'T-Shirt',
                      color: 'Gray',
                      size: 'L',
                      price: '200',
                    ),
                    SizedBox(height: 20 * s),
                    _CartItem(
                      s: s,
                      image: 'assets/shop/shop_main_3.png',
                      title: 'Sport Dress',
                      color: 'Black',
                      size: 'M',
                      price: '200',
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    // Promo Code Input
                    _PromoCodeInput(s: s),
                    
                    SizedBox(height: 48 * s),
                    
                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                            'Total amount:',
                            style: GoogleFonts.outfit(fontSize: 16 * s, color: Colors.white70),
                         ),
                         Row(
                           children: [
                             Text(
                                "200",
                                style: GoogleFonts.outfit(
                                  fontSize: 24 * s, 
                                  fontWeight: FontWeight.w800, 
                                  color: Colors.white,
                                ),
                             ),
                             SizedBox(width: 8 * s),
                             _dpIcon(s, size: 32),
                           ],
                         ),
                      ],
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    // Check Out Button
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopOrderSuccessScreen())),
                      child: Container(
                        width: double.infinity,
                        height: 60 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Check Out',
                          style: GoogleFonts.outfit(fontSize: 20 * s, fontWeight: FontWeight.w800, color: const Color(0xFFEBC17B)),
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

  Widget _dpIcon(double s, {double size = 14}) {
    return Container(
      width: size * s * 0.7, height: size * s * 0.7,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F0FF), width: 1.5)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: size * s * 0.25, fontWeight: FontWeight.w900, color: const Color(0xFF00F0FF))),
    );
  }
}

class _CartItem extends StatelessWidget {
  final double s;
  final String image;
  final String title;
  final String color;
  final String size;
  final String price;

  const _CartItem({
    required this.s, required this.image, required this.title, 
    required this.color, required this.size, required this.price
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(16 * s)),
            child: Image.asset(image, width: 100 * s, height: 100 * s, fit: BoxFit.cover),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: const Color(0xFFEBC17B))),
                      Icon(Icons.more_vert_rounded, color: Colors.white60, size: 20 * s),
                    ],
                  ),
                  Text('Color: $color    Size: $size', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                  const Spacer(),
                  Row(
                    children: [
                      _QuantityBtn(icon: Icons.remove, s: s),
                      SizedBox(width: 16 * s),
                      Text('1', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(width: 16 * s),
                      _QuantityBtn(icon: Icons.add, s: s),
                      const Spacer(),
                      Text(price, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(width: 4 * s),
                      _dpIcon(s, size: 24),
                      SizedBox(width: 12 * s),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final double s;
  const _QuantityBtn({required this.icon, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32 * s, height: 32 * s,
      decoration: BoxDecoration(color: const Color(0xFF26313A), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16 * s),
    );
  }
}

class _PromoCodeInput extends StatelessWidget {
  final double s;
  const _PromoCodeInput({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50 * s,
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5).withOpacity(0.9), // Light beige
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter your promo code',
                hintStyle: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black45),
                border: InputBorder.none,
              ),
              style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black),
            ),
          ),
          Container(
            width: 32 * s, height: 32 * s,
            decoration: BoxDecoration(color: const Color(0xFF1B1813), shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18 * s),
          ),
        ],
      ),
    );
  }
}

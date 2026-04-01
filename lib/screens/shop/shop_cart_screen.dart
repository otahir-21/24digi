import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_shipping_address_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopCartScreen extends StatefulWidget {
  const ShopCartScreen({super.key});

  @override
  State<ShopCartScreen> createState() => _ShopCartScreenState();
}

class _ShopCartScreenState extends State<ShopCartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Sportwear Set',
      'color': 'Cream',
      'size': 'L',
      'price': 200,
      'quantity': 1,
      'image': 'assets/shop/shop_main_1.png',
    },
    {
      'name': 'Turtleneck Sweater',
      'color': 'White',
      'size': 'M',
      'price': 200,
      'quantity': 1,
      'image': 'assets/shop/shop_main_2.png',
    },
    {
      'name': 'Cotton T-shirt',
      'color': 'Black',
      'size': 'L',
      'price': 200,
      'quantity': 1,
      'image': 'assets/shop/shop_main_3.png',
    },
  ];

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Designer brown matching screens
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
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
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'Your Cart',
                        style: GoogleFonts.outfit(
                          fontSize: 34 * s,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Cart List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (_, __) => SizedBox(height: 20 * s),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _CartItemCard(
                            s: s,
                            item: item,
                            onIncrement: () => setState(() => item['quantity']++),
                            onDecrement: () => setState(() {
                              if (item['quantity'] > 1) item['quantity']--;
                            }),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 24 * s),
                    
                    // Summary Section
                    _buildSummaryCard(s),
                    
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

  Widget _buildSummaryCard(double s) {
    return Container(
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Product price', _totalAmount.toInt().toString(), s),
          SizedBox(height: 16 * s),
          const Divider(color: Colors.white10),
          SizedBox(height: 16 * s),
          _buildSummaryRow('Shipping', 'Freeship', s, isTextValue: true),
          SizedBox(height: 16 * s),
          const Divider(color: Colors.white10),
          SizedBox(height: 16 * s),
          _buildSummaryRow('Subtotal', _totalAmount.toInt().toString(), s),
          SizedBox(height: 32 * s),
          
          // Checkout Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopShippingAddressScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 60 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFEBC17B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(30 * s),
              ),
              alignment: Alignment.center,
              child: Text(
                'Proceed to checkout',
                style: GoogleFonts.outfit(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double s, {bool isTextValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16 * s, color: const Color(0xFFEBC17B)),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24 * s,
                fontWeight: FontWeight.w900,
                color: isTextValue ? Colors.white : const Color(0xFFEBC17B),
              ),
            ),
            if (!isTextValue) ...[
              SizedBox(width: 8 * s),
              Image.asset(
                'assets/profile/profile_digi_point.png',
                width: 32 * s,
                height: 32 * s,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final double s;
  final Map<String, dynamic> item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.s,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140 * s,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20 * s),
            child: Image.asset(
              item['image'],
              width: 100 * s,
              height: 140 * s,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        item['price'].toInt().toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEBC17B),
                        ),
                      ),
                      SizedBox(width: 6 * s),
                      Image.asset(
                        'assets/profile/profile_digi_point.png',
                        width: 20 * s,
                        height: 20 * s,
                      ),
                    ],
                  ),
                  Text(
                    'Size: ${item['size']}  |  Color: ${item['color']}',
                    style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16 * s),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onDecrement,
                    child: Icon(Icons.remove, color: Colors.white, size: 16 * s),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s),
                    child: Text(
                      '${item['quantity']}',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onIncrement,
                    child: Icon(Icons.add, color: Colors.white, size: 16 * s),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

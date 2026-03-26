import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_add_address_screen.dart';
import 'package:kivi_24/screens/shop/shop_shipping_address_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_order_success_screen.dart';

class ShopCartScreen extends StatefulWidget {
  const ShopCartScreen({super.key});

  @override
  State<ShopCartScreen> createState() => _ShopCartScreenState();
}

class _ShopCartScreenState extends State<ShopCartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Pullover',
      'color': 'Black',
      'size': 'L',
      'price': 51.0,
      'quantity': 1,
      'image': 'assets/shop/shop_main_1.png',
    },
    {
      'name': 'T-Shirt',
      'color': 'Gray',
      'size': 'L',
      'price': 30.0,
      'quantity': 1,
      'image': 'assets/shop/shop_main_2.png',
    },
    {
      'name': 'Sport Dress',
      'color': 'Black',
      'size': 'M',
      'price': 43.0,
      'quantity': 1,
      'image': 'assets/shop/shop_main_3.png',
    },
  ];

  double get _totalAmount {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
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
                    Text(
                      'My Bag',
                      style: GoogleFonts.outfit(
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Cart List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (_, __) => SizedBox(height: 24 * s),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _CartItemCard(
                            s: s,
                            item: item,
                            onIncrement: () =>
                                setState(() => item['quantity']++),
                            onDecrement: () => setState(() {
                              if (item['quantity'] > 1) item['quantity']--;
                            }),
                            onDelete: () =>
                                setState(() => _cartItems.removeAt(index)),
                          );
                        },
                      ),
                    ),

                    // Promo Code Section
                    SizedBox(height: 20 * s),
                    _buildPromoSection(s),

                    // Totals Section
                    SizedBox(height: 32 * s),
                    _buildTotalsRow(
                      'Subtotal:',
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      s,
                      isSubtotal: true,
                    ),
                    SizedBox(height: 8 * s),
                    _buildTotalsRow('Shipping:', '\$0.00', s),
                    SizedBox(height: 12 * s),
                    _buildTotalsRow(
                      'Total amount:',
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      s,
                      isTotal: true,
                    ),

                    SizedBox(height: 32 * s),

                    // Checkout Button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShopShippingAddressScreen(),
                        ),
                      ),
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
                          'CHECK OUT',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s),
              child: TextField(
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16 * s,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your promo code',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.white30,
                    fontSize: 14 * s,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 24 * s,
            ),
          ),
          SizedBox(width: 8 * s),
        ],
      ),
    );
  }

  Widget _buildTotalsRow(
    String label,
    String value,
    double s, {
    bool isTotal = false,
    bool isSubtotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 20 * s : 16 * s,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? Colors.white : Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 20 * s : 16 * s,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? const Color(0xFFEBC17B) : Colors.white,
          ),
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
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.s,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5), // Accurate light beige
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10 * s,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(16 * s),
            ),
            child: Image.asset(
              item['image'],
              width: 120 * s,
              height: 120 * s,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.black54,
                          size: 22 * s,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildAttr('Color:', item['color'], s),
                      SizedBox(width: 16 * s),
                      _buildAttr('Size:', item['size'], s),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _QtyBtn(icon: Icons.remove, onTap: onDecrement, s: s),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12 * s),
                            child: Text(
                              '${item['quantity']}',
                              style: GoogleFonts.outfit(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          _QtyBtn(icon: Icons.add, onTap: onIncrement, s: s),
                        ],
                      ),
                      Text(
                        '\$${item['price'].toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
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

  Widget _buildAttr(String label, String value, double s) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.black38),
        ),
        SizedBox(width: 4 * s),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12 * s,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double s;
  const _QtyBtn({required this.icon, required this.onTap, required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36 * s,
        height: 36 * s,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: Colors.black, size: 20 * s),
      ),
    );
  }
}

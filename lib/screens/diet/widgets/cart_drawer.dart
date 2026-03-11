import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_constants.dart';
import '../delivery_address_list_screen.dart';
import '../providers/cart_provider.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30 * s),
          bottomLeft: Radius.circular(30 * s),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20 * s),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42 * s,
                  height: 42 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6FFFE9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: context.watch<CartProvider>().items.isEmpty ? Colors.redAccent : Colors.black,
                    size: 20 * s,
                  ),
                ),
                SizedBox(height: 8 * s),
              ],
            ),
            SizedBox(height: 12 * s),
            Text(
              'CART',
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 20 * s),
            const Divider(color: Colors.white10, thickness: 1),
            SizedBox(height: 20 * s),

            Expanded(
              child: context.watch<CartProvider>().items.isEmpty ? _buildEmptyState(s) : _buildFullState(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullState(double s) {
    final cart = context.watch<CartProvider>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have ${cart.totalItems} items in the cart',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24 * s),

          // Items
          Expanded(
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => SizedBox(height: 16 * s),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItem(
                  s: s,
                  image: _getProductImage(index),
                  name: item.product.name,
                  price: '${item.product.price.toStringAsFixed(2)} AED',
                  date: 'Today',
                  time: 'Now',
                  qty: item.quantity,
                  onAdd: () => cart.updateQuantity(item.product.id, item.quantity + 1),
                  onRemove: () => cart.updateQuantity(item.product.id, item.quantity - 1),
                );
              },
            ),
          ),

          SizedBox(height: 20 * s),
          const Divider(color: Colors.white10, thickness: 1),
          SizedBox(height: 20 * s),

          // Pricing
          _PriceRow(s: s, label: 'Subtotal', value: '${cart.subtotal.toStringAsFixed(2)} AED'),
          SizedBox(height: 12 * s),
          _PriceRow(s: s, label: 'Tax and Fees', value: '0.00 AED'),
          SizedBox(height: 12 * s),
          _PriceRow(s: s, label: 'Delivery', value: '0.00 AED'),

          SizedBox(height: 12 * s),
          const Divider(
            color: Colors.white10,
            indent: 0,
            endIndent: 0,
            height: 24,
          ),

          _PriceRow(s: s, label: 'Total', value: '${cart.subtotal.toStringAsFixed(2)} AED', isTotal: true),

          SizedBox(height: 20 * s),

          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeliveryAddressListScreen()),
                );
              },
              child: Container(
                width: 180 * s,
                height: 50 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF6FFFE9),
                  borderRadius: BorderRadius.circular(25 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CHECKOUT',
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double s) {
    return Column(
      children: [
        Text(
          'Your cart is empty',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const Spacer(flex: 1),
        Container(
          width: 160 * s,
          height: 160 * s,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(32 * s),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80 * s,
                height: 80 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 48 * s),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * s),
        Text(
          'Want To Add\nSomething?',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  String _getProductImage(int index) {
    final images = [
      'assets/diet/diet_best_seller_1.png',
      'assets/diet/diet_best_seller_2.png',
      'assets/diet/diet_best_seller_3.png',
      'assets/diet/diet_best_seller_4.png',
      'assets/diet/diet_recommend_1.png',
      'assets/diet/diet_recommend_2.png',
    ];
    return images[index % images.length];
  }
}

class _CartItem extends StatelessWidget {
  final double s;
  final String image;
  final String name;
  final String price;
  final String date;
  final String time;
  final int qty;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const _CartItem({
    required this.s,
    required this.image,
    required this.name,
    required this.price,
    required this.date,
    required this.time,
    required this.qty,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12 * s),
          child: Image.asset(
            image,
            width: 60 * s,
            height: 60 * s,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '$date AT $time',
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
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
              price,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6FFFE9),
              ),
            ),
            SizedBox(height: 8 * s),
            Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove, color: Colors.white, size: 10 * s),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Text(
                    '$qty',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 10 * s),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.s,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 * s : 12 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? Colors.white : Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 * s : 12 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? const Color(0xFF6FFFE9) : Colors.white,
          ),
        ),
      ],
    );
  }
}

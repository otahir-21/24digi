import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_constants.dart';
import '../delivery_address_list_screen.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  bool _isEmpty = false;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40 * s)),
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
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: _isEmpty ? Colors.redAccent : Colors.black,
                    size: 20 * s,
                  ),
                ),
                SizedBox(width: 12 * s),
                Text(
                  'Cart',
                  style: GoogleFonts.inter(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15 * s),
            const Divider(
              color: Colors.white12,
              thickness: 1,
              indent: 32,
              endIndent: 32,
            ),
            SizedBox(height: 20 * s),

            Expanded(
              child: _isEmpty ? _buildEmptyState(s) : _buildFullState(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullState(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have 2 items in the cart',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24 * s),

          // Items
          _CartItem(
            s: s,
            image: 'assets/diet/diet_best_seller_1.png',
            name: 'Beef Noodles',
            price: '35.00',
            date: '29/11/24',
            time: '15:00',
            qty: 2,
          ),
          SizedBox(height: 16 * s),
          const Divider(color: Colors.white10),
          SizedBox(height: 16 * s),
          _CartItem(
            s: s,
            image: 'assets/diet/diet_best_seller_2.png',
            name: '24 Sushi',
            price: '25.00',
            date: '29/11/24',
            time: '12:00',
            qty: 1,
            onRemove: () => setState(() => _isEmpty = true), // Demo trigger
          ),

          SizedBox(height: 20 * s),
          const Divider(color: Colors.white10, thickness: 1),
          SizedBox(height: 30 * s),

          // Pricing
          _PriceRow(s: s, label: 'Subtotal', value: '85.00'),
          SizedBox(height: 12 * s),
          _PriceRow(s: s, label: 'Tax and Fees', value: '2.80'),
          SizedBox(height: 12 * s),
          _PriceRow(s: s, label: 'Delivery', value: '3.00'),

          SizedBox(height: 12 * s),
          const Divider(
            color: Colors.white10,
            indent: 0,
            endIndent: 0,
            height: 24,
          ),

          _PriceRow(s: s, label: 'Total', value: '95.90', isTotal: true),

          const Spacer(),

          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeliveryAddressListScreen(),
                  ),
                );
              },
              child: Container(
                width: 140 * s,
                height: 42 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A555E),
                  borderRadius: BorderRadius.circular(21 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Checkout',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30 * s),
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
        const Spacer(flex: 2),
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
        const Spacer(flex: 3),
      ],
    );
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
  final VoidCallback? onRemove;

  const _CartItem({
    required this.s,
    required this.image,
    required this.name,
    required this.price,
    required this.date,
    required this.time,
    required this.qty,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: Image.asset(
            image,
            width: 70 * s,
            height: 70 * s,
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
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$date\n$time',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54),
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
                    child: Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 10 * s,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Text(
                    '$qty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 10 * s),
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
            fontSize: isTotal ? 16 * s : 14 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 * s : 14 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

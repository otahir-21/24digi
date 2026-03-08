import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 10 * s,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Order Details',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order No. 0054752',
                        style: GoogleFonts.inter(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '29 Nov, 01:20 pm',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white54,
                        ),
                      ),

                      SizedBox(height: 24 * s),
                      const Divider(color: Colors.white10),
                      SizedBox(height: 16 * s),

                      _DetailItem(
                        s: s,
                        img: 'assets/diet/diet_best_seller_1.png',
                        name: 'Beef Burger',
                        price: '20.00',
                        qty: 3,
                        date: '29/11/24',
                        time: '15:00',
                      ),
                      _DetailItem(
                        s: s,
                        img: 'assets/diet/diet_best_seller_2.png',
                        name: 'Chicken Pasta',
                        price: '28.00',
                        qty: 3,
                        date: '29/11/24',
                        time: '12:00',
                      ),

                      SizedBox(height: 40 * s),

                      _PriceRow(s: s, label: 'Subtotal', value: '32.00'),
                      SizedBox(height: 16 * s),
                      _PriceRow(s: s, label: 'Tax and Fees', value: '5.00'),
                      SizedBox(height: 8 * s),
                      _PriceRow(s: s, label: 'Delivery', value: '3.00'),

                      SizedBox(height: 32 * s),
                      _PriceRow(
                        s: s,
                        label: 'Total',
                        value: '40.00',
                        isTotal: true,
                      ),

                      SizedBox(height: 60 * s),

                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * s,
                            vertical: 8 * s,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                          child: Text(
                            'Order Again',
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40 * s),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final double s;
  final String img;
  final String name;
  final String price;
  final int qty;
  final String date;
  final String time;

  const _DetailItem({
    required this.s,
    required this.img,
    required this.name,
    required this.price,
    required this.qty,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * s),
            child: Image.asset(
              img,
              width: 80 * s,
              height: 80 * s,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$date\n$time',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
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
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        color: Colors.white70,
                      ),
                    ),
                    Row(
                      children: [
                        _QtyBtn(s: s, icon: Icons.remove),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * s),
                          child: Text(
                            '$qty',
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _QtyBtn(s: s, icon: Icons.add, isAdd: true),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final double s;
  final IconData icon;
  final bool isAdd;

  const _QtyBtn({required this.s, required this.icon, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20 * s,
      height: 20 * s,
      decoration: BoxDecoration(
        color: isAdd ? const Color(0xFFFF6B6B) : Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isAdd ? Colors.white : Colors.black,
        size: 14 * s,
      ),
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
            fontSize: isTotal ? 22 * s : 18 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 22 * s : 18 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

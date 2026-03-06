import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';

class ConfirmOrderScreen extends StatelessWidget {
  const ConfirmOrderScreen({super.key});

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
                    'Confirm Order',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s), // Balance for back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20 * s),
                    // Shipping Address Header
                    Row(
                      children: [
                        Text(
                          'Shipping Address',
                          style: GoogleFonts.inter(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                          size: 18 * s,
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * s),
                    // Address Field
                    Container(
                      width: double.infinity,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26313A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '778 Al Madar, Umm Al Quwain',
                        style: GoogleFonts.inter(
                          fontSize: 13 * s,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Order Summary Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary',
                          style: GoogleFonts.inter(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16 * s),

                    // Order Items
                    _SummaryItem(
                      s: s,
                      image: 'assets/diet/diet_best_seller_1.png',
                      name: 'Beef Noodles',
                      price: '35.00',
                      dateTime: '29 Nov, 15:20 pm',
                      qty: 2,
                    ),
                    SizedBox(height: 16 * s),
                    _SummaryItem(
                      s: s,
                      image: 'assets/diet/diet_best_seller_2.png',
                      name: '24 Sushi',
                      price: '25.00',
                      dateTime: '29 Nov, 12:00 pm',
                      qty: 1,
                    ),

                    SizedBox(height: 32 * s),

                    // Pricing Details
                    _PriceRow(s: s, label: 'Subtotal', value: '85.00'),
                    SizedBox(height: 14 * s),
                    _PriceRow(s: s, label: 'Tax and Fees', value: '2.80'),
                    SizedBox(height: 14 * s),
                    _PriceRow(s: s, label: 'Delivery', value: '3.00'),

                    SizedBox(height: 12 * s),
                    const Divider(color: Colors.white12, height: 32),

                    _PriceRow(
                      s: s,
                      label: 'Total',
                      value: '95.80',
                      isTotal: true,
                    ),

                    SizedBox(height: 60 * s),
                  ],
                ),
              ),
            ),

            // Footer Button
            Padding(
              padding: EdgeInsets.only(bottom: 24 * s),
              child: Container(
                width: 220 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A),
                  borderRadius: BorderRadius.circular(24 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Place Order',
                  style: GoogleFonts.inter(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class _SummaryItem extends StatelessWidget {
  final double s;
  final String image;
  final String name;
  final String price;
  final String dateTime;
  final int qty;

  const _SummaryItem({
    required this.s,
    required this.image,
    required this.name,
    required this.price,
    required this.dateTime,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 20 * s),
      child: Container(
        height: 150 * s,
        padding: EdgeInsets.all(12 * s),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16 * s),
              child: Image.asset(
                image,
                width: 100 * s,
                height: 100 * s,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16 * s),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white70,
                        size: 18 * s,
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateTime,
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        price,
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$qty items',
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * s),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * s,
                          vertical: 6 * s,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2329),
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: Text(
                          'Cancel Order',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.white70,
                        size: 18 * s,
                      ),
                      SizedBox(width: 12 * s),
                      Row(
                        children: [
                          Icon(
                            Icons.remove,
                            color: Colors.white70,
                            size: 14 * s,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10 * s),
                            child: Text(
                              '$qty',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13 * s,
                              ),
                            ),
                          ),
                          Icon(Icons.add, color: Colors.white70, size: 14 * s),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            fontSize: isTotal ? 18 * s : 16 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 * s : 16 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

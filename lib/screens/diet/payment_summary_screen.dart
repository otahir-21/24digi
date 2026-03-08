import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'order_confirmed_screen.dart';

class PaymentSummaryScreen extends StatelessWidget {
  const PaymentSummaryScreen({super.key});

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
                    'Payment',
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * s),
                    // Shipping Address Box
                    _HeadingRow(s: s, title: 'Shipping Address', onEdit: () {}),
                    SizedBox(height: 12 * s),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * s,
                        vertical: 14 * s,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26313A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                      child: Text(
                        '778 Al Madar, Umm Al Quwain',
                        style: GoogleFonts.inter(
                          fontSize: 13 * s,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Order Summary
                    _HeadingRow(s: s, title: 'Order Summary', onEdit: () {}),
                    SizedBox(height: 16 * s),
                    _OrderSummaryRow(
                      s: s,
                      name: 'Strawberry Shake',
                      qty: 2,
                      price: '95.80',
                    ), // Price shown at end of summary in UI
                    _OrderSummaryRow(
                      s: s,
                      name: 'Broccoli Lasagna',
                      qty: 1,
                      price: '',
                    ),

                    const Divider(color: Colors.white10, height: 32),

                    // Payment Method
                    _HeadingRow(s: s, title: 'Payment Method', onEdit: () {}),
                    SizedBox(height: 16 * s),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white,
                          size: 28 * s,
                        ),
                        SizedBox(width: 12 * s),
                        Text(
                          'Credit Card',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * s,
                            vertical: 6 * s,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26313A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                          child: Text(
                            '*** *** *** 43 /00 /000',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white10, height: 48),

                    // Delivery Time
                    Text(
                      'Delivery Time',
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          '25 mins',
                          style: GoogleFonts.inter(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60 * s),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderConfirmedScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 180 * s,
                          height: 48 * s,
                          decoration: BoxDecoration(
                            color: const Color(0xFF35414B),
                            borderRadius: BorderRadius.circular(24 * s),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pay Now',
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
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
}

class _HeadingRow extends StatelessWidget {
  final double s;
  final String title;
  final VoidCallback onEdit;
  const _HeadingRow({
    required this.s,
    required this.title,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8 * s),
            Icon(Icons.edit_outlined, color: Colors.white, size: 16 * s),
          ],
        ),
        Text(
          'Edit',
          style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
        ),
      ],
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final double s;
  final String name;
  final int qty;
  final String price;

  const _OrderSummaryRow({
    required this.s,
    required this.name,
    required this.qty,
    this.price = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120 * s,
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    color: Colors.white70,
                  ),
                ),
              ),
              Text(
                '$qty items',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          if (price.isNotEmpty)
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

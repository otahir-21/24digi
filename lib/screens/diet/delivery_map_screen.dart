import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class DeliveryMapScreen extends StatelessWidget {
  const DeliveryMapScreen({super.key});

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
                    'Delivery time',
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
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D24),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30 * s),
                      Text(
                        'Shipping Address',
                        style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26313A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: Text(
                          '778 Al Madar, Umm Al Quwain',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      SizedBox(height: 24 * s),

                      // Map Container
                      Container(
                        width: double.infinity,
                        height: 180 * s,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 * s),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/diet/diet_best_seller_1.png',
                            ), // Should use specific map asset
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(color: Colors.black26),
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(4 * s),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20 * s,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24 * s),

                      Text(
                        'Delivery Time',
                        style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12 * s),
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
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 32),

                      // Status Timeline
                      _StatusStep(
                        s: s,
                        title: 'Your order has been accepted',
                        time: '2 min',
                        isFirst: true,
                      ),
                      _StatusStep(
                        s: s,
                        title: 'The restaurant is preparing your order',
                        time: '5 min',
                      ),
                      _StatusStep(
                        s: s,
                        title: 'The delivery is on his way',
                        time: '10 min',
                      ),
                      _StatusStep(
                        s: s,
                        title: 'Your order has been delivered',
                        time: '8 min',
                        isLast: true,
                      ),

                      SizedBox(height: 40 * s),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            s: s,
                            label: 'Return Home',
                            isOutline: true,
                          ),
                          SizedBox(width: 16 * s),
                          _ActionButton(s: s, label: 'Track Order'),
                        ],
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

class _StatusStep extends StatelessWidget {
  final double s;
  final String title;
  final String time;
  final bool isFirst;
  final bool isLast;

  const _StatusStep({
    required this.s,
    required this.title,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8 * s,
              height: 8 * s,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 30 * s, color: Colors.white12),
          ],
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4 * s),
            ],
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white38),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double s;
  final String label;
  final bool isOutline;
  const _ActionButton({
    required this.s,
    required this.label,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140 * s,
      height: 42 * s,
      decoration: BoxDecoration(
        color: isOutline ? const Color(0xFF35414B) : const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(21 * s),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14 * s,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

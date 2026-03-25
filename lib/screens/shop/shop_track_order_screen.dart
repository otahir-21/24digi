import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopTrackOrderScreen extends StatelessWidget {
  final String orderId;
  const ShopTrackOrderScreen({super.key, this.orderId = '1524'});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(), // Dark brown/charcoal
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
                    SizedBox(height: 12 * s),
                    Text(
                      'Track Order',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    Text(
                      'Delivered on 15.05.21',
                      style: GoogleFonts.outfit(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEBC17B),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Tracking Number : ', style: GoogleFonts.outfit(fontSize: 16 * s, color: Colors.white38)),
                        Text('IK287368838', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
                      ],
                    ),
                    
                    SizedBox(height: 48 * s),
                    
                    // Tracking Timeline
                    _Timeline(s: s),
                    
                    SizedBox(height: 48 * s),
                    
                    // "Don't forget to rate" Banner
                    _buildRateBanner(s),
                    
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

  Widget _buildRateBanner(double s) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFEBC17B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(color: const Color(0xFF26313A).withOpacity(0.5), borderRadius: BorderRadius.circular(12 * s)),
            child: Icon(Icons.star_outline_rounded, color: const Color(0xFFEBC17B), size: 32 * s),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't forget to rate",
                  style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: const Color(0xFFEBC17B)),
                ),
                SizedBox(height: 4 * s),
                Text(
                  "Rate product to get 5 points for collect.",
                  style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white60),
                ),
                SizedBox(height: 8 * s),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star_outline_rounded, color: Colors.white24, size: 14 * s)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final double s;
  const _Timeline({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _step('Parcel is successfully delivered', '15 May 10:20', true, true, s),
        _step('Parcel is out for delivery', '14 May 08:00', true, false, s, isActive: true),
        _step('Parcel is received at delivery Branch', '13 May 17:25', true, false, s, isActive: true),
        _step('Parcel is in transit', '13 May 07:00', true, false, s, isActive: true),
        _step('Sender has shipped your parcel', '12 May 14:25', true, false, s, isActive: true),
        _step('Sender is preparing to ship your order', '12 May 10:01', true, false, s, isActive: true, isLast: true),
      ],
    );
  }

  Widget _step(String label, String time, bool isDone, bool isNow, double s, {bool isActive = false, bool isLast = false}) {
    return SizedBox(
      height: 70 * s,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24 * s, height: 24 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? const Color(0xFFEBC17B) : Colors.white24, width: 2),
                  color: isNow ? const Color(0xFFEBC17B) : Colors.transparent,
                ),
                child: isNow ? Icon(Icons.check, size: 14 * s, color: Colors.black) : 
                       (isActive ? Icon(Icons.check, size: 14 * s, color: const Color(0xFFEBC17B)) : null),
              ),
              if (!isLast) Expanded(
                child: Container(
                   width: 2, 
                   color: isActive ? const Color(0xFFEBC17B).withOpacity(0.5) : Colors.white10,
                   margin: EdgeInsets.symmetric(vertical: 4 * s),
                ),
              ),
            ],
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 15 * s, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.white38),
                ),
                SizedBox(height: 4 * s),
                Text(
                  time,
                  style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

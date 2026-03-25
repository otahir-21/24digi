import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_track_order_screen.dart';

class ShopDeliveryTimeScreen extends StatelessWidget {
  const ShopDeliveryTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
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
                      'Delivery time',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Shipping Address View (Same pill style)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Shipping Address', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    SizedBox(height: 12 * s),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1813),
                        borderRadius: BorderRadius.circular(24 * s),
                      ),
                      child: Text(
                        '778 Al Madar, Umm Al Quwain',
                        style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70),
                      ),
                    ),

                    SizedBox(height: 24 * s),

                    // Small Map View
                    SizedBox(
                      height: 200 * s,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20 * s),
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(25.1972, 55.2744),
                            zoom: 12,
                          ),
                          markers: {
                             const Marker(markerId: MarkerId('p1'), position: LatLng(25.1972, 55.2744)),
                             const Marker(markerId: MarkerId('p2'), position: LatLng(25.18, 55.25)),
                          },
                          polylines: {
                             const Polyline(
                               polylineId: PolylineId('r1'), 
                               points: [LatLng(25.1972, 55.2744), LatLng(25.18, 55.25)],
                               color: Color(0xFFEBC17B), 
                               width: 3
                             ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),

                    SizedBox(height: 24 * s),

                    // Delivery Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Time', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('25 mins', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: const Color(0xFFEBC17B))),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Estimated Delivery', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white54)),
                    ),

                    SizedBox(height: 16 * s),

                    // Mini Timeline
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 5 * s, top: 4 * s, bottom: 4 * s,
                            child: Container(width: 1 * s, color: Colors.white24),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _miniStep('Your order has been accepted', '2 min', s),
                              _miniStep('The restaurant is preparing your order', '5 min', s),
                              _miniStep('The delivery is on his way', '10 min', s),
                              _miniStep('Your order has been delivered', '8 min', s),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * s),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            child: Container(
                              height: 50 * s,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1813),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Return Home',
                                style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopTrackOrderScreen())),
                            child: Container(
                              height: 50 * s,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFDFCF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Track Order',
                                style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 48 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStep(String label, String time, double s) {
    return Row(
      children: [
        Container(
          width: 10 * s, height: 10 * s,
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
        ),
        SizedBox(width: 16 * s),
        Expanded(child: Text(label, style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70))),
        Text(time, style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70)),
      ],
    );
  }
}

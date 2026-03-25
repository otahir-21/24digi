import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_delivered_summary_screen.dart';

class ShopLiveTrackingScreen extends StatefulWidget {
  const ShopLiveTrackingScreen({super.key});

  @override
  State<ShopLiveTrackingScreen> createState() => _ShopLiveTrackingScreenState();
}

class _ShopLiveTrackingScreenState extends State<ShopLiveTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Dummy locations in Dubai
  static const LatLng _startLocation = LatLng(25.1972, 55.2744); // Downtown Dubai
  static const LatLng _endLocation = LatLng(25.0657, 55.1713);   // JVC Dubai

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _addPolylines();
  }

  void _addMarkers() {
    _markers.add(
      const Marker(
        markerId: MarkerId('start'),
        position: _startLocation,
        infoWindow: InfoWindow(title: 'Pickup Point'),
      ),
    );
    _markers.add(
      const Marker(
        markerId: MarkerId('end'),
        position: _endLocation,
        infoWindow: InfoWindow(title: 'Delivery Point'),
      ),
    );
  }

  void _addPolylines() {
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route'),
        points: [_startLocation, _endLocation],
        color: Color(0xFFEBC17B),
        width: 5,
        geodesic: true,
      ),
    );
  }

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
                      'Live Tracking',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Map View
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20 * s),
                            child: GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: _startLocation,
                                zoom: 12,
                              ),
                              markers: _markers,
                              polylines: _polylines,
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ),
                          ),
                          
                          // Overlays
                          Positioned(
                            bottom: 20 * s,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                _buildActionPill(Icons.phone_outlined, 'Call the delivery boy', s),
                                SizedBox(height: 12 * s),
                                _buildActionPill(Icons.chat_bubble_outline_rounded, 'Message the delivery boy', s),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * s),

                    // Progress Bar (Tapping simulates delivery completion)
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopDeliveredSummaryScreen())),
                      child: _buildTrackingProgress(s),
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

  Widget _buildActionPill(IconData icon, String label, double s) {
    return Container(
      width: 250 * s,
      padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 20 * s),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30 * s),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Icon(icon, color: Colors.white, size: 20 * s),
        ],
      ),
    );
  }

  Widget _buildTrackingProgress(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 14 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFDFCF),
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4, // Mock progress
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBC17B),
                          borderRadius: BorderRadius.circular(10 * s),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.35,
                        child: Container(
                          padding: EdgeInsets.all(4 * s),
                          decoration: const BoxDecoration(color: Color(0xFF1E1C1A), shape: BoxShape.circle),
                          child: Icon(Icons.local_shipping_outlined, color: const Color(0xFFEBC17B), size: 16 * s),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery goes your way', style: GoogleFonts.outfit(fontSize: 10 * s, color: const Color(0xFF00F0FF))),
                  SizedBox(height: 4 * s),
                  Text('01 Sep 24', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('06:20 PM', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Pick up your delivery', style: GoogleFonts.outfit(fontSize: 10 * s, color: const Color(0xFFEBC17B))),
                  SizedBox(height: 4 * s),
                  Text('01 Sep 24', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('07:15 PM', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_constants.dart';
import 'order_delivered_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  static const LatLng _initialPosition = LatLng(25.2048, 55.2708); // Dubai

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
                    'Live Tracking',
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24 * s, 30 * s, 24 * s, 0),
                  child: Column(
                    children: [
                      // Map Container
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24 * s),
                          child: Stack(
                            children: [
                              const GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _initialPosition,
                                  zoom: 14,
                                ),
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                              // Overlay Overlay Buttons
                              Positioned(
                                bottom: 20 * s,
                                left: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    _MapButton(
                                      s: s,
                                      label: 'Call the delivery boy',
                                      icon: Icons.phone_in_talk_rounded,
                                    ),
                                    SizedBox(height: 10 * s),
                                    _MapButton(
                                      s: s,
                                      label: 'Message the delivery boy',
                                      icon: Icons.chat_bubble_outline_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24 * s),

                      // Progress Section
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 16 * s,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8 * s),
                            ),
                          ),
                          Positioned(
                            left:
                                MediaQuery.of(context).size.width *
                                0.45 *
                                s, // Approximate center
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const OrderDeliveredScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 50 * s,
                                height: 50 * s,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF161D24),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161D24),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF6B6B),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delivery_dining,
                                    color: const Color(0xFFFF6B6B),
                                    size: 28 * s,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16 * s),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery goes your way',
                                style: GoogleFonts.inter(
                                  fontSize: 12 * s,
                                  color: const Color(0xFF00F0FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8 * s),
                              Text(
                                '01 Sep 24',
                                style: GoogleFonts.inter(
                                  fontSize: 13 * s,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '06:20 PM',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pick up your delivery',
                                style: GoogleFonts.inter(
                                  fontSize: 12 * s,
                                  color: const Color(0xFF00F0FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8 * s),
                              Text(
                                '01 Sep 24',
                                style: GoogleFonts.inter(
                                  fontSize: 13 * s,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '07:15 PM',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
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

class _MapButton extends StatelessWidget {
  final double s;
  final String label;
  final IconData icon;

  const _MapButton({required this.s, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200 * s,
      height: 32 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      padding: EdgeInsets.only(left: 16 * s, right: 4 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            width: 24 * s,
            height: 24 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF161D24),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B6B), size: 14 * s),
          ),
        ],
      ),
    );
  }
}

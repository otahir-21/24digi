import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_map_picker_screen.dart';
import 'providers/c_by_ai_provider.dart';

class CByAiAddressSelectionScreen extends StatelessWidget {
  const CByAiAddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            SizedBox(height: 16 * s),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final rawName = auth.profile?.name?.trim();
                final greetingName = (rawName == null || rawName.isEmpty)
                    ? 'USER'
                    : rawName.toUpperCase();
                return Text(
                  'HI, $greetingName',
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
            SizedBox(height: 32 * s),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOption(
                      s,
                      Icons.gps_fixed_rounded,
                      'Choose Current Location',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CByAiMapPickerScreen())),
                    ),
                    SizedBox(height: 20 * s),
                    _buildOption(
                      s,
                      Icons.add_circle_outline_rounded,
                      'Choose a new location',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CByAiMapPickerScreen())),
                    ),
                    
                    SizedBox(height: 32 * s),
                    const Divider(color: Colors.white10),
                    SizedBox(height: 32 * s),
                    
                    Consumer<CByAiProvider>(
                      builder: (context, provider, _) {
                        if (provider.deliveryAddress == null) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40 * s),
                              child: Text(
                                'No saved locations yet',
                                style: GoogleFonts.outfit(color: Colors.white24),
                              ),
                            ),
                          );
                        }
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            _buildLocationItem(
                              s, 
                              provider.deliveryBuilding ?? 'Building', 
                              provider.deliveryAddress!, 
                              'Current'
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(double s, IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 20 * s),
          SizedBox(width: 16 * s),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00F0FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(double s, String building, String address, String distance) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32 * s),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white24, size: 24 * s),
              SizedBox(height: 4 * s),
              Text(
                distance,
                style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white24),
              ),
            ],
          ),
          SizedBox(width: 20 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building,
                  style: GoogleFonts.outfit(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  address,
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

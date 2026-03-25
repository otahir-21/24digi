import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_help_center_screen.dart';
import 'shop_chat_screen.dart';

class ShopHelpScreen extends StatelessWidget {
  const ShopHelpScreen({super.key});

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
                    SizedBox(height: 24 * s),
                    Text(
                      'Help',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor.',
                      style: GoogleFonts.outfit(
                        fontSize: 13 * s,
                        color: Colors.white38,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    _HelpLink(
                      title: 'Help with the order',
                      subtitle: 'Support',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopChatScreen())),
                      s: s,
                    ),
                    SizedBox(height: 12 * s),
                    _HelpLink(
                      title: 'Help center',
                      subtitle: 'General Information',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopHelpCenterScreen())),
                      s: s,
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
}

class _HelpLink extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double s;

  const _HelpLink({required this.title, required this.subtitle, required this.onTap, required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24 * s),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4 * s),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20 * s),
          ],
        ),
      ),
    );
  }
}

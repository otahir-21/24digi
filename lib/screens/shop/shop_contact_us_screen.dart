import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_help_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_help_center_screen.dart';

class ShopContactUsScreen extends StatelessWidget {
  const ShopContactUsScreen({super.key});

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
                    SizedBox(height: 24 * s),
                    Text(
                      'Contact Us',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'How Can We Help\nYou?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white38,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Navigation Tabs
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShopHelpCenterScreen(),
                              ),
                            ),
                            child: _TabButton(
                              label: 'FAQ',
                              isActive: false,
                              s: s,
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: _TabButton(
                            label: 'Contact Us',
                            isActive: true,
                            s: s,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32 * s),

                    // Contact List
                    _ContactItem(
                      icon: Icons.headset_mic_outlined,
                      label: 'Customer service',
                      s: s,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShopHelpScreen(),
                          ),
                        );
                      },
                    ),
                    _ContactItem(
                      icon: Icons.public_rounded,
                      label: 'Website',
                      s: s,
                    ),
                    _ContactItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Whatsapp',
                      s: s,
                    ),
                    _ContactItem(
                      icon: Icons.facebook_outlined,
                      label: 'Facebook',
                      s: s,
                    ),
                    _ContactItem(
                      icon: Icons.camera_alt_outlined,
                      label: 'Instagram',
                      s: s,
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
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final double s;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44 * s,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFDFCF) : const Color(0xFF1B1813),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.white12,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 14 * s,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.black : Colors.white60,
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double s;

  final VoidCallback? onTap;
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.s,
    this.onTap,
  });

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
            Icon(icon, color: const Color(0xFFEBC17B), size: 32 * s),
            SizedBox(width: 20 * s),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
              size: 20 * s,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'help_center_screen.dart';

class HelpNavigationScreen extends StatelessWidget {
  const HelpNavigationScreen({super.key});

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
                    'Help',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
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
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * s,
                  vertical: 40 * s,
                ),
                child: Column(
                  children: [
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor.',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    const Divider(color: Colors.white10),
                    _HelpNavLink(
                      s: s,
                      title: 'Help with the order',
                      subtitle: 'Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(
                              initialIsContactUs: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10),
                    _HelpNavLink(
                      s: s,
                      title: 'Help center',
                      subtitle: 'General Information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(
                              initialIsContactUs: false,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10),
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

class _HelpNavLink extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpNavLink({
    required this.s,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFFFF6B6B),
              size: 24 * s,
            ),
          ],
        ),
      ),
    );
  }
}

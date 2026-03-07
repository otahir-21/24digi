import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_constants.dart';
import '../my_orders_screen.dart';
import '../delivery_address_list_screen.dart';
import '../payment_methods_screen.dart';
import '../../profile/profile_screen.dart';
import '../help_center_screen.dart';
import '../help_navigation_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40 * s),
          bottomRight: Radius.circular(40 * s),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40 * s),

            // Profile Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: Row(
                children: [
                  Container(
                    width: 70 * s,
                    height: 70 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/fonts/male.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name',
                          style: GoogleFonts.inter(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'User@email.com',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40 * s),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.shopping_bag_outlined,
                      label: 'My Orders',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.person_outline,
                      label: 'My Profile',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryAddressListScreen(),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.location_on_outlined,
                      label: 'Delivery Address',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.credit_card_outlined,
                      label: 'Payment Methods',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HelpCenterScreen(initialIsContactUs: true),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.phone_outlined,
                      label: 'Contact Us',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpNavigationScreen(),
                        ),
                      );
                    },
                    child: _MenuItem(
                      s: s,
                      icon: Icons.help_outline,
                      label: 'Help & FAQs',
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _MenuItem(
                    s: s,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  SizedBox(height: 20 * s),
                  _MenuItem(
                    s: s,
                    icon: Icons.logout,
                    label: 'Go to 24 DIGI',
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;
  final bool isLogout;

  const _MenuItem({
    required this.s,
    required this.icon,
    required this.label,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: const Color(0xFFFF6B6B), size: 20 * s),
            ),
          ),
          SizedBox(width: 20 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

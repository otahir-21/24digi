import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_constants.dart';
import '../shop_orders_screen.dart';
import '../shop_shipping_address_screen.dart';
import '../shop_help_screen.dart';

class ShopDrawer extends StatelessWidget {
  const ShopDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40 * s),
            bottomLeft: Radius.circular(40 * s),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30 * s),
              // Profile Header
              Padding(
                padding: EdgeInsets.only(left: 30 * s),
                child: Container(
                  width: 70 * s,
                  height: 70 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/shop/male_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50 * s),

              // Drawer Items
              _DrawerItem(
                s: s,
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopOrdersScreen()),
                  );
                },
              ),
              _DrawerItem(
                s: s,
                imageAsset: 'assets/profile/profile_digi_point.png',
                label: 'Payment Methods',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                s: s,
                icon: Icons.location_on_outlined,
                label: 'Delivery Address',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ShopShippingAddressScreen(fromDrawer: true),
                    ),
                  );
                },
              ),
              _DrawerItem(
                s: s,
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQs',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopHelpScreen()),
                  );
                },
              ),
              _DrawerItem(
                s: s,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final double s;
  final IconData? icon;
  final String? imageAsset;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.s,
    this.icon,
    this.imageAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 15 * s),
            child: Row(
              children: [
                Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAE0D5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: imageAsset != null
                      ? Image.asset(imageAsset!, width: 24 * s, height: 24 * s)
                      : Icon(icon, color: Colors.black, size: 24 * s),
                ),
                SizedBox(width: 20 * s),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30 * s),
          child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
        ),
      ],
    );
  }
}

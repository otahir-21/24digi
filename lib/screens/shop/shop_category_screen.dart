import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_sub_category_screen.dart';
import 'shop_cart_screen.dart';

class ShopCategoryScreen extends StatelessWidget {
  final String gender;
  const ShopCategoryScreen({super.key, this.gender = 'Female'});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final isMale = gender == 'Male';

    String getAsset(String type) {
      if (isMale) {
        switch (type) {
          case 'Headwear':
            return 'assets/shop/shop_men_headwear.png';
          case 'Clothes':
            return 'assets/shop/sho_men_cloth.png'; // Using filename from ls
          case 'Footwear':
            return 'assets/shop/shop_men_footwear.png';
          case 'Accessories':
            return 'assets/shop/shop_men_accessories.png';
          case 'Devices':
            return 'assets/shop/shop_men_devices.png';
        }
      }
      switch (type) {
        case 'Headwear':
          return 'assets/shop/shop_headwear.png';
        case 'Clothes':
          return 'assets/shop/shop_cloth.png';
        case 'Footwear':
          return 'assets/shop/shop_footwear.png';
        case 'Accessories':
          return 'assets/shop/shop_accessories.png';
        case 'Devices':
          return 'assets/shop/shop_devices.png';
      }
      return '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
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
                    SizedBox(height: 16 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),

                    // Icon Row
                    Row(
                      children: [
                        _IconButton(
                          s: s,
                          icon: Icons.favorite_rounded,
                          iconColor: const Color(0xFFFF2E93), // Stylized pink/red
                        ),
                        SizedBox(width: 16 * s),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShopCartScreen(),
                            ),
                          ),
                          child: _IconButton(
                            s: s,
                            icon: Icons.shopping_bag_rounded,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.search, color: Colors.white70, size: 30 * s),
                      ],
                    ),

                    SizedBox(height: 28 * s),

                    // Sales Banner
                    _buildBanner(s),

                    SizedBox(height: 28 * s),

                    // Category List
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        children: [
                          _CategoryCard(
                            s: s,
                            title: 'Headwear',
                            imagePath: getAsset('Headwear'),
                          ),
                          _CategoryCard(
                            s: s,
                            title: 'Clothes',
                            imagePath: getAsset('Clothes'),
                          ),
                          _CategoryCard(
                            s: s,
                            title: 'Footwear',
                            imagePath: getAsset('Footwear'),
                          ),
                          _CategoryCard(
                            s: s,
                            title: 'Accessories',
                            imagePath: getAsset('Accessories'),
                          ),
                          _CategoryCard(
                            s: s,
                            title: 'Devices',
                            imagePath: getAsset('Devices'),
                          ),
                          SizedBox(height: 20 * s),
                        ],
                      ),
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

  Widget _buildBanner(double s) {
    return Container(
      width: double.infinity,
      height: 110 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813),
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10 * s,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SUMMER SALES',
            style: GoogleFonts.outfit(
              fontSize: 24 * s,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFEBC17B),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Up to 50% off',
            style: GoogleFonts.outfit(
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

class _IconButton extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;

  const _IconButton({
    required this.s,
    required this.icon,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48 * s,
      height: 48 * s,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Icon(icon, color: iconColor, size: 24 * s),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final double s;
  final String title;
  final String imagePath;

  const _CategoryCard({
    required this.s,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopSubCategoryScreen(categoryTitle: title),
          ),
        );
      },
      child: Container(
        height: 120 * s,
        margin: EdgeInsets.only(bottom: 20 * s),
        decoration: BoxDecoration(
          color: const Color(0xFFEAE0D5), // Accurate light beige
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Row(
          children: [
            SizedBox(width: 24 * s),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 24 * s,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(16 * s),
              ),
              child: Image.asset(
                imagePath,
                width: 180 * s,
                height: 120 * s,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

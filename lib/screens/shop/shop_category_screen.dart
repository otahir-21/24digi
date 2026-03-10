import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'shop_sub_category_screen.dart';
import 'shop_cart_screen.dart';
import 'shop_orders_screen.dart';

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
          case 'Headwear': return 'assets/shop/shop_men_headwear.png';
          case 'Clothes': return 'assets/shop/sho_men_cloth.png'; // Using filename from ls
          case 'Footwear': return 'assets/shop/shop_men_footwear.png';
          case 'Accessories': return 'assets/shop/shop_men_accessories.png';
          case 'Devices': return 'assets/shop/shop_men_devices.png';
        }
      }
      switch (type) {
        case 'Headwear': return 'assets/shop/shop_headwear.png';
        case 'Clothes': return 'assets/shop/shop_cloth.png';
        case 'Footwear': return 'assets/shop/shop_footwear.png';
        case 'Accessories': return 'assets/shop/shop_accessories.png';
        case 'Devices': return 'assets/shop/shop_devices.png';
      }
      return '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3D352F), // Dark brown/charcoal
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
                    
                    // Search Bar and Heart/Bag icons row
                    Row(
                      children: [
                        _IconButton(
                          s: s, 
                          icon: Icons.favorite_rounded, 
                          iconColor: Colors.redAccent,
                        ),
                        SizedBox(width: 12 * s),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopCartScreen())),
                          child: _IconButton(
                            s: s, 
                            icon: Icons.shopping_bag_rounded,
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopOrdersScreen())),
                          child: _IconButton(
                            s: s, 
                            icon: Icons.list_alt_rounded,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.search, color: Colors.white, size: 32 * s),
                      ],
                    ),
                    
                    SizedBox(height: 24 * s),
                    
                    // Sales Banner
                    _buildBanner(s),
                    
                    SizedBox(height: 24 * s),
                    
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
      height: 100 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SUMMER SALES',
            style: GoogleFonts.outfit(
              fontSize: 22 * s,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFEBC17B),
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
      width: 44 * s,
      height: 44 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor == Colors.white ? Colors.white12 : iconColor.withOpacity(0.3), 
          width: 1,
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
        height: 110 * s,
        margin: EdgeInsets.only(bottom: 16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFFEAE0D5), // Light beige
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Row(
          children: [
            SizedBox(width: 20 * s),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20 * s,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(12 * s),
              ),
              child: Image.asset(
                imagePath,
                width: 160 * s,
                height: 110 * s,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

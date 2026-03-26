import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_product_list_screen.dart';

class ShopSubCategoryScreen extends StatelessWidget {
  final String categoryTitle;
  const ShopSubCategoryScreen({super.key, this.categoryTitle = 'Clothes'});

  static const List<String> _subCategories = [
    'Tops',
    'Shirts & Blouses',
    'Cardigans & Sweaters',
    'Knitwear',
    'Blazers',
    'Outerwear',
    'Pants',
    'Jeans',
    'Shorts',
    'Skirts',
    'Dresses'
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

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
                    SizedBox(height: 32 * s),
                    
                    // VIEW ALL ITEMS Button
                    _buildViewAllButton(context, s),
                    
                    SizedBox(height: 40 * s),
                    
                    // "Choose category" Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose category',
                        style: GoogleFonts.outfit(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEBC17B),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16 * s),
                    
                    // Sub-category List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _subCategories.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          return _subCategoryItem(
                            context, 
                            s, 
                            _subCategories[index]
                          );
                        },
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

  Widget _buildViewAllButton(BuildContext context, double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ShopProductListScreen(title: 'All Items'),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1813),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10 * s,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'VIEW ALL ITEMS',
          style: GoogleFonts.outfit(
            fontSize: 20 * s,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFEBC17B),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _subCategoryItem(BuildContext context, double s, String label) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopProductListScreen(title: label),
          ),
        );
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 4 * s),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 18 * s,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white30,
        size: 16 * s,
      ),
    );
  }
}

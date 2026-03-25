import "dart:ui";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_product_detail_screen.dart';

/// Accurate, pixel-perfect rewrite of the Shop Product List Screen based
/// on the latest design screenshot.
class ShopProductListScreen extends StatelessWidget {
  final String title;
  const ShopProductListScreen({super.key, this.title = 'Street clothes'});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    // Determine if we show the hero view or grid view based on screen title (defaulting to hero for main segments)
    final isHeroView = title.toLowerCase() != 'all items';

    return Scaffold(
      backgroundColor: const Color(
        0xFF1E1C1A,
      ), // Even darker brown/charcoal backdrop
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top bar is transparently overlaid in the hero view, but here we place it in a Stack for correct overlay
            Expanded(
              child: Stack(
                children: [
                  // Main Content
                  isHeroView
                      ? _buildHeroView(context, s)
                      : _buildGridView(context, s),

                  // Top Overlay Bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    child: const ShopTopBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Design matching the screenshot with Hero Image and Horizontal Lists
  Widget _buildHeroView(BuildContext context, double s) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _HeaderHero(s: s, title: title),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24 * s),
                _SectionHeader(
                  title: 'Sale',
                  subtitle: 'Super summer sale',
                  s: s,
                ),
                SizedBox(height: 16 * s),
                _ProductHorizontalList(
                  s: s,
                  items: _mockProducts(s, isSale: true),
                ),
                SizedBox(height: 32 * s),
                _SectionHeader(
                  title: 'New',
                  subtitle: 'You\'ve never seen it before!',
                  s: s,
                ),
                SizedBox(height: 16 * s),
                _ProductHorizontalList(
                  s: s,
                  items: _mockProducts(s, isNew: true),
                ),
                SizedBox(height: 48 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Standard Grid View (kept for category-level screen)
  Widget _buildGridView(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 100 * s), // Spacing for top bar overlay
        Center(
          child: Text(
            'HI, USER',
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(height: 20 * s),

        // Category Title & Result Count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 24 * s,
                  color: const Color(0xFFEBC17B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Found\n152 Results',
                style: GoogleFonts.outfit(
                  fontSize: 28 * s,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20 * s),

        // Filters & Sort row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: Colors.white70,
                size: 20 * s,
              ),
              SizedBox(width: 8 * s),
              Text(
                'Filters',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.swap_vert_rounded,
                color: Colors.white70,
                size: 20 * s,
              ),
              SizedBox(width: 4 * s),
              Text(
                'Price: lowest to high',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.apps_rounded, color: Colors.white70, size: 20 * s),
            ],
          ),
        ),

        SizedBox(height: 10 * s),

        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16 * s),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 16 * s,
              mainAxisSpacing: 16 * s,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return _ProductGridCard(
                s: s,
                image: 'assets/shop/shop_main_${(index % 6) + 1}.png',
                name: 'Filted Waist Dress',
                brand: 'Mango Boy',
                price: '200',
                oldPrice: index % 2 == 1 ? '350' : null,
                rating: 4,
                reviewCount: 10,
                isFavorite: index % 3 == 1,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _mockProducts(
    double s, {
    bool isSale = false,
    bool isNew = false,
  }) {
    if (isSale) {
      return [
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_1.png',
          badge: '-20%',
          rating: 5,
          reviewCount: 10,
          brand: 'Dorothy Perkins',
          name: 'Evening Dress',
          oldPrice: '350',
          price: '200',
        ),
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_2.png',
          badge: '-15%',
          rating: 4,
          reviewCount: 10,
          brand: 'Sitlly',
          name: 'Sport Dress',
          oldPrice: '350',
          price: '200',
        ),
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_3.png',
          badge: '-20%',
          rating: 5,
          reviewCount: 10,
          brand: 'Dorothy Perkins',
          name: 'Sport Dress',
          oldPrice: '350',
          price: '200',
        ),
      ];
    } else {
      return [
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_4.png',
          badge: 'NEW',
          isNew: true,
          rating: 0,
          reviewCount: 0,
          brand: 'OVS',
          name: 'Blouse',
          price: '200',
        ),
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_5.png',
          badge: 'NEW',
          isNew: true,
          rating: 0,
          reviewCount: 0,
          brand: 'Mango Boy',
          name: 'T-Shirt Sailing',
          price: '200',
        ),
        _ProductHorizontalCard(
          s: s,
          image: 'assets/shop/shop_main_6.png',
          badge: 'NEW',
          isNew: true,
          rating: 0,
          reviewCount: 0,
          brand: 'Cool',
          name: 'Jeans',
          price: '200',
        ),
      ];
    }
  }
}

class _HeaderHero extends StatelessWidget {
  final double s;
  final String title;
  const _HeaderHero({required this.s, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480 * s,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/shop/shop_street_cloth.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                  const Color(0xFF1E1C1A),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 100 * s,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'HI, USER',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40 * s,
            left: 0 * s,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20 * s),
                bottomRight: Radius.circular(20 * s),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * s,
                    vertical: 8 * s,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1C1A).withOpacity(0.5),
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 28 * s,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double s;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 34 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEBC17B),
              ),
            ),
            Text(
              'View all',
              style: GoogleFonts.outfit(
                fontSize: 12 * s,
                color: const Color(0xFFEBC17B),
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white54),
        ),
      ],
    );
  }
}

class _ProductHorizontalList extends StatelessWidget {
  final double s;
  final List<Widget> items;
  const _ProductHorizontalList({required this.s, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330 * s,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 16 * s),
        itemBuilder: (_, index) => items[index],
      ),
    );
  }
}

class _ProductHorizontalCard extends StatelessWidget {
  final double s;
  final String image;
  final String badge;
  final int rating;
  final int reviewCount;
  final String brand;
  final String name;
  final String? oldPrice;
  final String price;
  final bool isNew;

  const _ProductHorizontalCard({
    required this.s,
    required this.image,
    required this.badge,
    required this.rating,
    required this.reviewCount,
    required this.brand,
    required this.name,
    this.oldPrice,
    required this.price,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopProductDetailScreen()),
      ),
      child: Container(
        width: 160 * s,
        padding: EdgeInsets.all(8 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A26).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12 * s),
                  child: Image.asset(
                    image,
                    width: 144 * s,
                    height: 180 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8 * s,
                  left: 8 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * s,
                      vertical: 4 * s,
                    ),
                    decoration: BoxDecoration(
                      color: isNew
                          ? const Color(0xFF1E1C1A)
                          : const Color(0xFFDB3022),
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.outfit(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32 * s,
                    height: 32 * s,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1C1A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_outline_rounded,
                      color: Colors.white,
                      size: 16 * s,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6 * s),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < rating ? Colors.amber : Colors.white12,
                    size: 14 * s,
                  ),
                ),
                if (reviewCount > 0) ...[
                  SizedBox(width: 4 * s),
                  Text(
                    '($reviewCount)',
                    style: GoogleFonts.outfit(
                      fontSize: 10 * s,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              brand,
              style: GoogleFonts.outfit(
                fontSize: 11 * s,
                color: Colors.white54,
              ),
            ),
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2 * s),
            Row(
              children: [
                if (oldPrice != null) ...[
                  Text(
                    oldPrice!,
                    style: GoogleFonts.outfit(
                      fontSize: 13 * s,
                      color: const Color(0xFFDB3022),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: const Color(0xFFDB3022),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                ],
                Text(
                  price,
                  style: GoogleFonts.outfit(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEBC17B),
                  ),
                ),
                SizedBox(width: 6 * s),
                Image.asset(
                  'assets/profile/profile_digi_point.png',
                  width: 20 * s,
                  height: 20 * s,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final double s;
  final String image;
  final String name;
  final String brand;
  final String price;
  final String? oldPrice;
  final int rating;
  final int reviewCount;
  final bool isFavorite;

  const _ProductGridCard({
    required this.s,
    required this.image,
    required this.name,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopProductDetailScreen()),
      ),
      child: Container(
        padding: EdgeInsets.all(8 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A26).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12 * s),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32 * s,
                      height: 32 * s,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1C1A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 16 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * s),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < rating ? Colors.amber : Colors.white12,
                    size: 12 * s,
                  ),
                ),
                SizedBox(width: 4 * s),
                Text(
                  '($reviewCount)',
                  style: GoogleFonts.outfit(
                    fontSize: 10 * s,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            Text(
              brand,
              style: GoogleFonts.outfit(
                fontSize: 11 * s,
                color: Colors.white54,
              ),
            ),
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                if (oldPrice != null) ...[
                  Text(
                    oldPrice!,
                    style: GoogleFonts.outfit(
                      fontSize: 13 * s,
                      color: const Color(0xFFDB3022),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: const Color(0xFFDB3022),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                ],
                Text(
                  price,
                  style: GoogleFonts.outfit(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEBC17B),
                  ),
                ),
                SizedBox(width: 6 * s),
                Image.asset(
                  'assets/profile/profile_digi_point.png',
                  width: 20 * s,
                  height: 20 * s,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
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
    final isHeroView =
        title.toLowerCase() != 'all items' &&
        title.toLowerCase() != 'dresses' &&
        title.toLowerCase() != 'favorite';

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main Content
                  isHeroView
                      ? _buildHeroView(context, s)
                      : _buildGridView(context, s),

                  // Top Overlay Bar (Cyan back arrow, centered logo, profile right)
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

  // Design matching the screenshot with Hero Image and Horizontal Lists (e.g. Street clothes)
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

  // Matching the 'Dresses' or 'Favorite' screenshot
  Widget _buildGridView(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 100 * s),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24 * s),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 34 * s,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Found 152 Results',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * s,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1813).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: const Color(0xFFEBC17B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Filter',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20 * s,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 32 * s),

        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16 * s,
              mainAxisSpacing: 24 * s,
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
                rating: 5,
                reviewCount: 53,
                isFavorite: true,
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
                  const Color(0xFF332F2B),
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
            left: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24 * s,
                    vertical: 12 * s,
                  ),
                  color: Colors.black38,
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 32 * s,
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
                fontWeight: FontWeight.w900,
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
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            color: Colors.white.withOpacity(0.6),
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.asset(
                    image,
                    width: 160 * s,
                    height: 200 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8 * s,
                  left: 8 * s,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isNew ? Colors.black : const Color(0xFFDB3022),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.outfit(
                        fontSize: 10 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 36 * s,
                    height: 36 * s,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1C1A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 18 * s,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * s),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
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
                fontSize: 16 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                if (oldPrice != null) ...[
                  Text(
                    oldPrice!,
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: 8 * s),
                ],
                Text(
                  price,
                  style: GoogleFonts.outfit(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEBC17B),
                  ),
                ),
                SizedBox(width: 6 * s),
                Image.asset(
                  'assets/profile/profile_digi_point.png',
                  width: 22 * s,
                  height: 22 * s,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.asset(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 38 * s,
                    height: 38 * s,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1C1A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 20 * s,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
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
            style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white54),
          ),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              if (oldPrice != null) ...[
                Text(
                  oldPrice!,
                  style: GoogleFonts.outfit(
                    fontSize: 14 * s,
                    color: Colors.redAccent,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8 * s),
              ],
              Text(
                price,
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFEBC17B),
                ),
              ),
              SizedBox(width: 6 * s),
              Image.asset(
                'assets/profile/profile_digi_point.png',
                width: 22 * s,
                height: 22 * s,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

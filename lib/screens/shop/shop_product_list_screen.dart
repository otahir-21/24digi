import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'shop_product_detail_screen.dart';
import 'shop_cart_screen.dart';
import 'shop_orders_screen.dart';

class ShopProductListScreen extends StatelessWidget {
  final String title;
  const ShopProductListScreen({super.key, this.title = 'Street clothes'});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final isDresses = title.toLowerCase() == 'dresses' || title.toLowerCase() == 'clothes' || title.toLowerCase() == 'all items';

    return Scaffold(
      backgroundColor: const Color(0xFF3D352F), // Dark brown/charcoal
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: isDresses 
                ? _buildGridView(context, s) 
                : _buildHeroView(context, s),
            ),
          ],
        ),
      ),
    );
  }

  // Design with hero image (previous design kept for "Street clothes" etc)
  Widget _buildHeroView(BuildContext context, double s) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _HeaderHero(s: s, title: title),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            child: Column(
              children: [
                SizedBox(height: 16 * s),
                _SectionHeader(title: 'Sale', subtitle: 'Super summer sale', s: s),
                SizedBox(height: 16 * s),
                _ProductHorizontalList(
                  s: s,
                  items: _mockProducts(s, isSale: true),
                ),
                SizedBox(height: 32 * s),
                _SectionHeader(title: 'New', subtitle: 'You\'ve never seen it before!', s: s),
                SizedBox(height: 16 * s),
                _ProductHorizontalList(
                  s: s,
                  items: _mockProducts(s, isNew: true),
                ),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Design matching the first screenshot (Grid with Filters)
  Widget _buildGridView(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8 * s),
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
        
        // Favorite/Bag/Search row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              _IconButton(s: s, icon: Icons.favorite_rounded, iconColor: Colors.redAccent),
              SizedBox(width: 12 * s),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopCartScreen())),
                child: _IconButton(s: s, icon: Icons.shopping_bag_rounded),
              ),
              SizedBox(width: 12 * s),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopOrdersScreen())),
                child: _IconButton(s: s, icon: Icons.list_alt_rounded),
              ),
              const Spacer(),
              Icon(Icons.search, color: Colors.white, size: 32 * s),
            ],
          ),
        ),
        
        SizedBox(height: 20 * s),
        
        // Filters & Sort row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              Icon(Icons.filter_list_rounded, color: Colors.white70, size: 20 * s),
              SizedBox(width: 8 * s),
              Text(
                'Filters',
                style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Icons.swap_vert_rounded, color: Colors.white70, size: 20 * s),
              SizedBox(width: 4 * s),
              Text(
                'Price: lowest to high',
                style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Icons.apps_rounded, color: Colors.white70, size: 20 * s),
            ],
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
                style: GoogleFonts.outfit(fontSize: 24 * s, color: const Color(0xFFEBC17B), fontWeight: FontWeight.w800),
              ),
              Text(
                'Found\n152 Results',
                style: GoogleFonts.outfit(fontSize: 28 * s, color: Colors.white, fontWeight: FontWeight.w800, height: 1.1),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20 * s),
        
        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16 * s),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16 * s,
              mainAxisSpacing: 16 * s,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return _ProductGridItem(
                s: s,
                image: 'assets/shop/shop_main_${(index % 6) + 1}.png',
                name: 'Filted Waist Dress',
                price: '200',
                oldPrice: index % 2 == 1 ? '350' : null,
                rating: 5,
                reviewCount: index % 2 == 1 ? (53) : null,
                isFavorite: index % 3 == 1,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _mockProducts(double s, {bool isSale = false, bool isNew = false}) {
    return List.generate(3, (index) {
       return _ProductItem(
        s: s,
        image: 'assets/shop/shop_main_${index + 1 + (isNew ? 3 : 0)}.png',
        badge: isSale ? '-${20 - index * 5}%' : 'NEW',
        rating: 5 - index,
        brand: isSale ? 'Dorothy Perkins' : 'OVS',
        name: isSale ? 'Evening Dress' : 'Blouse',
        oldPrice: isSale ? '350' : null,
        price: '200',
        isNew: isNew,
      );
    });
  }
}

class _HeaderHero extends StatelessWidget {
  final double s;
  final String title;
  const _HeaderHero({required this.s, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350 * s,
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
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                  const Color(0xFF3D352F),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40 * s,
            left: 16 * s,
            child: Text(
              title,
              style: GoogleFonts.outfit(fontSize: 32 * s, fontWeight: FontWeight.w800, color: Colors.white),
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
  const _SectionHeader({required this.title, required this.subtitle, required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 30 * s, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white54)),
          ],
        ),
        Text('View all', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white60)),
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
      height: 320 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 16 * s),
        itemBuilder: (_, index) => items[index],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final double s;
  final String image;
  final String badge;
  final int rating;
  final String brand;
  final String name;
  final String? oldPrice;
  final String price;
  final bool isNew;

  const _ProductItem({
    required this.s, required this.image, required this.badge, 
    required this.rating, required this.brand, required this.name, 
    this.oldPrice, required this.price, this.isNew = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopProductDetailScreen())),
      child: SizedBox(
        width: 150 * s,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12 * s),
                  child: Image.asset(image, width: 150 * s, height: 200 * s, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8 * s,
                  left: 8 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                    decoration: BoxDecoration(color: isNew ? Colors.black : const Color(0xFFDB3022), borderRadius: BorderRadius.circular(10 * s)),
                    child: Text(badge, style: GoogleFonts.outfit(fontSize: 10 * s, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * s),
            Row(
              children: List.generate(5, (index) => Icon(index < rating ? Icons.star : Icons.star_border, color: index < rating ? Colors.orange : Colors.grey, size: 12 * s)),
            ),
            Text(brand, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white54)),
            Text(name, style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
            Row(
              children: [
                if (oldPrice != null) ...[
                  Text(oldPrice!, style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                  SizedBox(width: 8 * s),
                ],
                Text(price, style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: const Color(0xFFEBC17B))),
                SizedBox(width: 4 * s),
                _dpIcon(s),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dpIcon(double s) {
    return Container(
      width: 14 * s, height: 14 * s,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEBC17B), width: 1)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: 6 * s, fontWeight: FontWeight.w900, color: const Color(0xFFEBC17B))),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final double s;
  final String image;
  final String name;
  final String price;
  final String? oldPrice;
  final int rating;
  final int? reviewCount;
  final bool isFavorite;

  const _ProductGridItem({
    required this.s, required this.image, required this.name, 
    required this.price, this.oldPrice, required this.rating, 
    this.reviewCount, this.isFavorite = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopProductDetailScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12 * s,
                  right: 12 * s,
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : Colors.white60,
                    size: 20 * s,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * s),
          Text(name, style: GoogleFonts.outfit(fontSize: 13 * s, fontWeight: FontWeight.w600, color: const Color(0xFFEBC17B))),
          Row(
            children: [
              Text(price, style: GoogleFonts.outfit(fontSize: 15 * s, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(width: 4 * s),
              _dpIcon(s, color: Colors.white, size: 20),
              if (oldPrice != null) ...[
                const Spacer(),
                Text(oldPrice!, style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                SizedBox(width: 4 * s),
                _dpIcon(s, color: Colors.white38, size: 18),
              ],
            ],
          ),
          Row(
            children: [
              ...List.generate(5, (index) => Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.orange, size: 10 * s)),
              if (reviewCount != null) ...[
                SizedBox(width: 4 * s),
                Text('($reviewCount)', style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _dpIcon(double s, {Color color = const Color(0xFFEBC17B), double size = 14}) {
    return Container(
      width: size * s * 0.7, height: size * s * 0.7,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: size * s * 0.3, fontWeight: FontWeight.w900, color: color)),
    );
  }
}

class _IconButton extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  const _IconButton({required this.s, required this.icon, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44 * s, height: 44 * s,
      decoration: BoxDecoration(color: const Color(0xFF1B2329).withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: iconColor == Colors.white ? Colors.white12 : iconColor.withOpacity(0.3), width: 1)),
      child: Icon(icon, color: iconColor, size: 24 * s),
    );
  }
}

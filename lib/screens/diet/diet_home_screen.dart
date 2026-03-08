import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'diet_list_screen.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/profile_drawer.dart';

class DietHomeScreen extends StatefulWidget {
  const DietHomeScreen({super.key});

  @override
  State<DietHomeScreen> createState() => _DietHomeScreenState();
}

class _DietHomeScreenState extends State<DietHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1217),
      drawer: const ProfileDrawer(),
      endDrawer: const CartDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20 * s),
                // Top Search & Actions
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24 * s),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16 * s),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20 * s,
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: Text(
                                'Search',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 14 * s,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(4 * s),
                              decoration: const BoxDecoration(
                                color: Color(0xFF26313A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 16 * s,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    _HeaderIcon(
                      s: s,
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                    SizedBox(width: 8 * s),
                    _HeaderIcon(s: s, icon: Icons.notifications_none_rounded),
                    SizedBox(width: 8 * s),
                    _HeaderIcon(
                      s: s,
                      icon: Icons.person_outline_rounded,
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
                SizedBox(height: 30 * s),
                // Greeting
                Text(
                  'Good Morning',
                  style: GoogleFonts.inter(
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Rise And Shine! It\'s Breakfast Time',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30 * s),
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryItem(
                        s: s,
                        image: 'assets/diet/diet_main_dish.png',
                        label: 'Main Course',
                        onTap: () => _navToList(context, 'Main Course'),
                      ),
                      _CategoryItem(
                        s: s,
                        image: 'assets/diet/diet_special.png',
                        label: '24 Special',
                        onTap: () => _navToList(context, '24 Special'),
                      ),
                      _CategoryItem(
                        s: s,
                        image: 'assets/diet/diet_asia.png',
                        label: 'East of Asia corner',
                        onTap: () => _navToList(context, 'East Asia'),
                      ),
                      _CategoryItem(
                        s: s,
                        image: 'assets/diet/diet_sandwich.png',
                        label: 'Sandwich\'s',
                        onTap: () => _navToList(context, 'Sandwich'),
                      ),
                      _CategoryItem(
                        s: s,
                        image: 'assets/diet/diet_salad.png',
                        label: 'Salads',
                        onTap: () => _navToList(context, 'Salads'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4 * s),
                const Divider(color: Color(0xFF26313A), thickness: 1),
                SizedBox(height: 20 * s),
                // Best Seller Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Best Seller',
                      style: GoogleFonts.inter(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            color: Colors.white70,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF6FFFE9),
                          size: 18 * s,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),
                // Best Seller List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _BestSellerCard(
                        s: s,
                        image: 'assets/diet/diet_best_seller_1.png',
                        price: '35 AED',
                      ),
                      _BestSellerCard(
                        s: s,
                        image: 'assets/diet/diet_best_seller_2.png',
                        price: '30 AED',
                      ),
                      _BestSellerCard(
                        s: s,
                        image: 'assets/diet/diet_best_seller_3.png',
                        price: '28 AED',
                      ),
                      _BestSellerCard(
                        s: s,
                        image: 'assets/diet/diet_best_seller_4.png',
                        price: '12 AED',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30 * s),
                // Promo Banner
                Container(
                  width: double.infinity,
                  height: 140 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * s),
                    image: const DecorationImage(
                      image: AssetImage('assets/diet/diet_discount.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 12 * s),
                // Page Indicator
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Container(
                        width: i == 2 ? 24 * s : 12 * s,
                        height: 4 * s,
                        margin: EdgeInsets.symmetric(horizontal: 2 * s),
                        decoration: BoxDecoration(
                          color: i == 2
                              ? const Color(0xFF6FFFE9)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(2 * s),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30 * s),
                // Recommend Section
                Text(
                  'Recommend',
                  style: GoogleFonts.inter(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16 * s),
                Row(
                  children: [
                    Expanded(
                      child: _RecommendCard(
                        s: s,
                        image: 'assets/diet/diet_recommend_1.png',
                        price: '25 AED',
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    Expanded(
                      child: _RecommendCard(
                        s: s,
                        image: 'assets/diet/diet_recommend_2.png',
                        price: '18 AED',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navToList(BuildContext context, String cat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DietListScreen(categoryName: cat)),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final double s;
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIcon({required this.s, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42 * s,
        height: 42 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20 * s),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final double s;
  final String image;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.s,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80 * s,
      margin: EdgeInsets.only(right: 12 * s),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CustomPaint(
              painter: SmoothGradientBorder(radius: 40 * s),
              child: Container(
                width: 76 * s,
                height: 76 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 9 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BestSellerCard extends StatelessWidget {
  final double s;
  final String image;
  final String price;
  const _BestSellerCard({
    required this.s,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110 * s,
      height: 150 * s,
      margin: EdgeInsets.only(right: 12 * s),
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 20 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 8 * s,
                right: 8 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 4 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final double s;
  final String image;
  final String price;
  const _RecommendCard({
    required this.s,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 24 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24 * s),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10 * s,
                left: 10 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * s,
                    vertical: 3 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '5.0',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2 * s),
                      Icon(Icons.star, color: Colors.amber, size: 10 * s),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10 * s,
                right: 10 * s,
                child: Icon(Icons.favorite, color: Colors.red, size: 18 * s),
              ),
              Positioned(
                bottom: 12 * s,
                right: 12 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 4 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

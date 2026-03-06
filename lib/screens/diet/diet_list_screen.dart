import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'diet_detail_screen.dart';
import 'widgets/cart_drawer.dart';

class DietListScreen extends StatefulWidget {
  final String categoryName;

  const DietListScreen({super.key, required this.categoryName});

  @override
  State<DietListScreen> createState() => _DietListScreenState();
}

class _DietListScreenState extends State<DietListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1217),
      endDrawer: const CartDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10 * s),
            // Header: Back, Search, Cart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8 * s),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20 * s,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Container(
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 18 * s),
                          SizedBox(width: 8 * s),
                          Expanded(
                            child: Text(
                              'Search',
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 13 * s,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.tune_rounded,
                            color: Colors.black,
                            size: 18 * s,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    child: Container(
                      width: 44 * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2329),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 20 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24 * s),

            // Horizontal Category List (Small Icons)
            SizedBox(
              height: 100 * s,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                children: [
                  _SmallCategoryItem(
                    s: s,
                    image: 'assets/diet/diet_sandwich.png',
                    label: 'Sandwich',
                  ),
                  _SmallCategoryItem(
                    s: s,
                    image: 'assets/diet/diet_special.png',
                    label: '24 Special',
                    isSelected: true,
                  ),
                  _SmallCategoryItem(
                    s: s,
                    image: 'assets/diet/diet_asia.png',
                    label: 'East Asia',
                  ),
                  _SmallCategoryItem(
                    s: s,
                    image: 'assets/diet/diet_main_dish.png',
                    label: 'Main Course',
                  ),
                  _SmallCategoryItem(
                    s: s,
                    image: 'assets/diet/diet_salad.png',
                    label: 'Salads',
                  ),
                ],
              ),
            ),

            // Main Listing Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF161D24),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: Column(
                  children: [
                    // Sort By Bar
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24 * s,
                        24 * s,
                        24 * s,
                        12 * s,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort By',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.tune_rounded,
                            color: Colors.white70,
                            size: 20 * s,
                          ),
                        ],
                      ),
                    ),

                    // Food List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16 * s),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DietDetailScreen(
                                    itemName: 'BEEF NOODLES',
                                  ),
                                ),
                              );
                            },
                            child: const _FoodListItem(),
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
}

class _SmallCategoryItem extends StatelessWidget {
  final double s;
  final String image;
  final String label;
  final bool isSelected;

  const _SmallCategoryItem({
    required this.s,
    required this.image,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70 * s,
      margin: EdgeInsets.only(right: 12 * s),
      child: Column(
        children: [
          CustomPaint(
            painter: SmoothGradientBorder(radius: 30 * s, selected: isSelected),
            child: Container(
              width: 60 * s,
              height: 60 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 8 * s,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF6FFFE9) : Colors.white60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  const _FoodListItem();

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16 * s),
      height: 150 * s,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 20 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Container(
            color: const Color(0xFF1B2329).withOpacity(0.4),
            padding: EdgeInsets.all(12 * s),
            child: Row(
              children: [
                // Dish Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.asset(
                    'assets/diet/diet_best_seller_2.png',
                    width: 100 * s,
                    height: 100 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16 * s),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BEEF PASTA',
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '30 AED',
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Description about the food ingredients calories and any info about the food',
                        style: GoogleFonts.inter(
                          fontSize: 8 * s,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6 * s),
                      // Rating
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14 * s,
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      // Macro stats
                      Row(
                        children: [
                          _MacroStat(
                            s: s,
                            icon: Icons.local_fire_department,
                            value: '695 kcal',
                            color: Colors.orange,
                          ),
                          SizedBox(width: 14 * s),
                          _MacroStat(
                            s: s,
                            label: 'P',
                            value: '29 g',
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Row(
                        children: [
                          _MacroStat(
                            s: s,
                            label: 'C',
                            value: '46 g',
                            color: Colors.greenAccent,
                          ),
                          SizedBox(width: 14 * s),
                          _MacroStat(
                            s: s,
                            label: 'F',
                            value: '12 g',
                            color: Colors.yellowAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final double s;
  final IconData? icon;
  final String? label;
  final String value;
  final Color color;

  const _MacroStat({
    required this.s,
    this.icon,
    this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, color: color, size: 12 * s)
        else
          Container(
            width: 12 * s,
            height: 12 * s,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 8 * s,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        SizedBox(width: 4 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

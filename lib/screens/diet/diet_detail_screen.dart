import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'widgets/cart_drawer.dart';

class DietDetailScreen extends StatefulWidget {
  final String itemName;

  const DietDetailScreen({super.key, required this.itemName});

  @override
  State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  int _quantity = 1;
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
            _buildHeader(s),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [_buildHeroSection(s), _buildContentSection(s)],
                ),
              ),
            ),
            _buildBottomButton(s),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.chevron_left, color: Colors.white, size: 28 * s),
          ),
          const Spacer(),
          Text(
            widget.itemName, // "Beef Noodles"
            style: GoogleFonts.inter(
              fontSize: 24 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white70,
                  size: 26 * s,
                ),
                Positioned(
                  top: -4 * s,
                  right: -4 * s,
                  child: Text(
                    '2',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(double s) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 480 * s,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── The Hourglass Background (covering full hero area) ──
          Positioned.fill(child: CustomPaint(painter: _HourglassPainter())),

          // ── Circular Image ──
          Positioned(
            top: 10 * s,
            child: Container(
              width: 320 * s,
              height: 320 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00B2FF),
                  width: 3.5 * s,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B2FF).withOpacity(0.4),
                    blurRadius: 25 * s,
                    spreadRadius: 2 * s,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/diet/diet_best_seller_1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ── Quantity Display (Centered in the waist) ──
          Positioned(
            bottom: 60 * s,
            child: Text(
              '$_quantity',
              style: GoogleFonts.inter(
                fontSize: 42 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          // ── Minus/Plus Buttons in the side pockets ──
          Positioned(
            bottom: 75 * s,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SideControlButton(
                    s: s / 2,
                    icon: Icons.remove,
                    onTap: () => setState(
                      () => _quantity = (_quantity > 1) ? _quantity - 1 : 1,
                    ),
                  ),
                  _SideControlButton(
                    s: s / 2,
                    icon: Icons.add,
                    onTap: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(double s) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2329),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12 * s, bottom: 20 * s),
            width: 80 * s,
            height: 4 * s,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2 * s),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nutritional facts',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '4.7',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white70,
                          ),
                        ),
                        Icon(Icons.star, color: Colors.amber, size: 14 * s),
                        SizedBox(width: 12 * s),
                        Icon(
                          Icons.favorite,
                          color: Colors.white.withOpacity(0.8),
                          size: 20 * s,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),
                Row(
                  children: [
                    _BadgeContainer(
                      s: s,
                      label: 'Calories',
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.red,
                            size: 24 * s,
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            '695 kcal',
                            style: GoogleFonts.inter(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _BadgeContainer(
                      s: s,
                      label: 'Price',
                      child: Row(
                        children: [
                          Text(
                            '35.00',
                            style: GoogleFonts.inter(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4 * s),
                          Text(
                            'AED',
                            style: TextStyle(
                              fontSize: 10 * s,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MacroBadge(
                      s: s,
                      label: 'P',
                      value: '87 g',
                      sub: 'Portion',
                      color: const Color(0xFFB161FF),
                    ),
                    _MacroBadge(
                      s: s,
                      label: 'C',
                      value: '82 g',
                      sub: 'Carbs',
                      color: const Color(0xFF6DE8FF),
                    ),
                    _MacroBadge(
                      s: s,
                      label: 'F',
                      value: '19 g',
                      sub: 'Fat',
                      color: const Color(0xFFFFB061),
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                CustomPaint(
                  painter: SmoothGradientBorder(radius: 14 * s),
                  child: Container(
                    padding: EdgeInsets.all(14 * s),
                    child: Text(
                      'description about the food ingredients calories and any info about THE FOOD',
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 * s),
                _AdjustPortionSection(s: s),
                SizedBox(height: 32 * s),
                Text(
                  'Sauce',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'Choose One Sauce *',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: Colors.white54,
                  ),
                ),
                SizedBox(height: 16 * s),
                _HorizontalFoodList(s: s, type: 'sauce'),
                SizedBox(height: 32 * s),
                Text(
                  'Side options',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16 * s),
                _HorizontalFoodList(s: s, type: 'side'),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(double s) {
    return Container(
      color: const Color(0xFF1B2329),
      padding: EdgeInsets.only(bottom: 24 * s),
      child: Center(
        child: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          child: Container(
            width: 160 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF535D66),
              borderRadius: BorderRadius.circular(21 * s),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white70,
                  size: 18 * s,
                ),
                SizedBox(width: 8 * s),
                Text(
                  'Add to Cart',
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _SideControlButton extends StatelessWidget {
  final double s;
  final IconData icon;
  final VoidCallback onTap;

  const _SideControlButton({
    required this.s,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70 * s,
        height: 70 * s,
        padding: EdgeInsets.all(12 * s),
        alignment: Alignment.center,
        child: icon == Icons.remove
            ? Container(width: 40 * s, height: 4.5 * s, color: Colors.white)
            : Icon(icon, color: Colors.white, size: 54 * s),
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF439E92), Color(0xFF287970)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    double waistY = size.height * 0.5;
    double waistWidth = size.width * 0.3; // Very narrow waist

    // Start top left
    path.moveTo(0, 0);
    // Across top
    path.lineTo(size.width, 0);

    // Right side CURVE IN to waist
    path.cubicTo(
      size.width * 0.85,
      size.height * 0.1,
      size.width * 0.65,
      size.height * 0.3,
      size.width * 0.65,
      waistY,
    );

    // Right side CURVE OUT to bottom
    path.cubicTo(
      size.width * 0.65,
      size.height * 0.7,
      size.width * 0.85,
      size.height * 0.9,
      size.width,
      size.height,
    );

    // Across bottom
    path.lineTo(0, size.height);

    // Left side CURVE IN to waist
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.9,
      size.width * 0.35,
      size.height * 0.7,
      size.width * 0.35,
      waistY,
    );

    // Left side CURVE OUT to top
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.3,
      size.width * 0.15,
      size.height * 0.1,
      0,
      0,
    );

    path.close();

    canvas.drawPath(path, paint);

    // Glowing Gradient Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = const LinearGradient(
        colors: [Color(0xFF00B2FF), Color(0xFFB161FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BadgeContainer extends StatelessWidget {
  final double s;
  final String label;
  final Widget child;
  const _BadgeContainer({
    required this.s,
    required this.label,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: label == 'Price'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
        SizedBox(height: 6 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * s),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _MacroBadge({
    required this.s,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(6 * s, 6 * s, 18 * s, 6 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18 * s,
                height: 18 * s,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _AdjustPortionSection extends StatelessWidget {
  final double s;
  const _AdjustPortionSection({required this.s});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 20 * s,
          child: Column(
            children: [
              Container(
                width: 6 * s,
                height: 6 * s,
                decoration: const BoxDecoration(
                  color: Color(0xFF00F0FF),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 1,
                  color: const Color(0xFF00F0FF).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust portion size',
                style: GoogleFonts.inter(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 28 * s),
              _AdjustRow(s: s, label: 'Source of Protein'),
              SizedBox(height: 32 * s),
              _AdjustRow(s: s, label: 'Source of Carbs'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdjustRow extends StatelessWidget {
  final double s;
  final String label;
  const _AdjustRow({required this.s, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6 * s),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 24 * s),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.remove, color: Colors.white, size: 20 * s),
              SizedBox(width: 14 * s),
              Text(
                '100 g',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14 * s),
              Icon(Icons.add, color: Colors.white, size: 20 * s),
            ],
          ),
        ),
      ],
    );
  }
}

class _HorizontalFoodList extends StatelessWidget {
  final double s;
  final String type;
  const _HorizontalFoodList({required this.s, required this.type});
  @override
  Widget build(BuildContext context) {
    final images = type == 'sauce'
        ? [
            'assets/diet/diet_best_seller_1.png',
            'assets/diet/diet_best_seller_2.png',
            'assets/diet/diet_best_seller_3.png',
          ]
        : [
            'assets/diet/diet_best_seller_4.png',
            'assets/diet/diet_recommend_1.png',
            'assets/diet/diet_recommend_2.png',
          ];
    final names = type == 'sauce'
        ? ['24 Sauce', 'BBQ Sauce', 'Red Sauce']
        : ['Fries', 'Coleslaw', 'Salad'];
    return SizedBox(
      height: 120 * s,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100 * s,
            margin: EdgeInsets.only(right: 14 * s),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100 * s,
                      height: 85 * s,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      padding: EdgeInsets.all(4 * s),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 * s),
                        child: Image.asset(images[index], fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 4 * s,
                      right: 4 * s,
                      child: Container(
                        padding: EdgeInsets.all(2 * s),
                        decoration: const BoxDecoration(
                          color: Color(0xFF535D66),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14 * s,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Text(
                  names[index],
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

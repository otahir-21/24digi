import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/diet/widgets/cart_drawer.dart';

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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1217),
      endDrawer: const CartDrawer(),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(context),
                    _buildContentSection(context),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Spacer(),
          Text(
            widget.itemName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white70,
                  size: 26,
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: Text(
                    '2',
                    style: GoogleFonts.inter(
                      fontSize: 11,
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

  // ── HERO ─────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Hero total height: upper bulge + waist area
    const double heroH = 460;
    const double circleSize = 300;
    const double circleTop = 10;

    return SizedBox(
      width: w,
      height: heroH,
      child: Stack(
        children: [
          // ── Hourglass background (full width, full height) ──
          Positioned.fill(child: CustomPaint(painter: _HourglassPainter())),

          // ── Circular food image ──
          Positioned(
            top: circleTop,
            left: (w - circleSize) / 2,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00B2FF), width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B2FF).withOpacity(0.45),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00B2FF).withOpacity(0.15),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/diet/diet_salad.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1a2a2a),
                    child: const Icon(
                      Icons.ramen_dining,
                      color: Colors.white38,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Quantity number — centered in waist ──
          Positioned(
            bottom: 68,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '$_quantity',
                style: GoogleFonts.inter(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),

          // ── MINUS button — left pocket ──
          Positioned(
            bottom: 72,
            left: 0,
            child: GestureDetector(
              onTap: () =>
                  setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
              child: SizedBox(
                width: 90,
                height: 70,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── PLUS button — right pocket ──
          Positioned(
            bottom: 72,
            right: 0,
            child: GestureDetector(
              onTap: () => setState(() => _quantity++),
              child: SizedBox(
                width: 90,
                height: 70,
                child: Center(
                  child: Text(
                    '+',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1,
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

  // ── CONTENT ──────────────────────────────────────────────────
  Widget _buildContentSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2329),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 72,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nutritional facts row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nutritional facts',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '4.7',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.favorite,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Calories + Price badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BadgeContainer(
                      label: 'Calories',
                      alignRight: false,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '695 kcal',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _BadgeContainer(
                      label: 'Price',
                      alignRight: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '35.00',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Macro row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _MacroBadge(
                      label: 'P',
                      value: '87 g',
                      sub: 'Portion',
                      color: Color(0xFFB161FF),
                    ),
                    _MacroBadge(
                      label: 'C',
                      value: '82 g',
                      sub: 'Carbs',
                      color: Color(0xFF6DE8FF),
                    ),
                    _MacroBadge(
                      label: 'F',
                      value: '19 g',
                      sub: 'Fat',
                      color: Color(0xFFFFB061),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Description box with gradient border
                _GradientBorderBox(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'description about the food ingredients calories and any info about THE FOOD',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Adjust portion
                _AdjustPortionSection(),
                const SizedBox(height: 28),

                // Sauce
                Text(
                  'Sauce',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose One Sauce *',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
                ),
                const SizedBox(height: 14),
                _HorizontalFoodList(
                  items: const [
                    _FoodItem('24 Sauce', '🥫'),
                    _FoodItem('BBQ Sauce', '🍖'),
                    _FoodItem('Red Sauce', '🌶️'),
                  ],
                ),
                const SizedBox(height: 28),

                // Side options
                Text(
                  'Side options',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                _HorizontalFoodList(
                  items: const [
                    _FoodItem('Fries', '🍟'),
                    _FoodItem('Coleslaw', '🥗'),
                    _FoodItem('Salad', '🥙'),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BUTTON ────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: const Color(0xFF1B2329),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
      child: Center(
        child: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          child: Container(
            width: 155,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF535D66),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add to Cart',
                  style: GoogleFonts.inter(
                    fontSize: 13,
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

// ─────────────────────────────────────────────────────────────
//  Hourglass Painter  — pixel-perfect match to screenshot
// ─────────────────────────────────────────────────────────────
class _HourglassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Waist is at 58% of height (just below center of image)
    final double waistY = h * 0.58;

    // How much the sides curve IN toward center at the waist
    // The waist is NOT a hard pinch — it's a smooth gentle inward curve
    // Left waist X ≈ 30% of width, Right waist X ≈ 70% of width
    const double waistInsetL = 0.30; // left side at waist
    const double waistInsetR = 0.70; // right side at waist

    final path = Path();

    // ── Start: top-left corner ──
    path.moveTo(0, 0);

    // ── Top edge (straight across) ──
    path.lineTo(w, 0);

    // ── Right side: straight down then curve IN to waist ──
    // Control points make the inward curve smooth and gradual
    path.cubicTo(
      w * 0.92,
      h * 0.18, // ctrl1: right side starts curving in
      w * waistInsetR,
      waistY - h * 0.08, // ctrl2: approaching waist
      w * waistInsetR,
      waistY, // end: waist right
    );

    // ── Right side: curve OUT from waist down to bottom-right ──
    path.cubicTo(
      w * waistInsetR,
      waistY + h * 0.08, // ctrl1: leaving waist
      w * 0.92,
      h * 0.82, // ctrl2: expanding outward
      w,
      h, // end: bottom-right corner
    );

    // ── Bottom edge (straight across) ──
    path.lineTo(0, h);

    // ── Left side: curve IN from bottom-left to waist ──
    path.cubicTo(
      w * 0.08,
      h * 0.82, // ctrl1
      w * waistInsetL,
      waistY + h * 0.08, // ctrl2
      w * waistInsetL,
      waistY, // end: waist left
    );

    // ── Left side: curve OUT from waist up to top-left ──
    path.cubicTo(
      w * waistInsetL,
      waistY - h * 0.08, // ctrl1
      w * 0.08,
      h * 0.18, // ctrl2
      0,
      0, // end: top-left
    );

    path.close();

    // ── Fill with teal gradient ──
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF3D9E92), Color(0xFF1E7268)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, fillPaint);

    // ── Glowing border: blue → purple gradient ──
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFF00B2FF), Color(0xFFB161FF), Color(0xFF00B2FF)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, borderPaint);

    // ── Extra glow effect on border (blur) ──
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF00B2FF).withOpacity(0.5),
          const Color(0xFFB161FF).withOpacity(0.5),
          const Color(0xFF00B2FF).withOpacity(0.5),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
//  Gradient border description box
// ─────────────────────────────────────────────────────────────
class _GradientBorderBox extends StatelessWidget {
  final Widget child;
  const _GradientBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF00B2FF), Color(0xFFB161FF)],
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329),
          borderRadius: BorderRadius.circular(13),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Badge Container (Calories / Price)
// ─────────────────────────────────────────────────────────────
class _BadgeContainer extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignRight;

  const _BadgeContainer({
    required this.label,
    required this.child,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Macro Badge  (P / C / F)
// ─────────────────────────────────────────────────────────────
class _MacroBadge extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _MacroBadge({
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
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          sub.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Adjust Portion Section
// ─────────────────────────────────────────────────────────────
class _AdjustPortionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cyan vertical timeline line
        Positioned(
          left: 2.5,
          top: 10,
          bottom: 22,
          child: Container(
            width: 1,
            color: const Color(0xFF00F0FF).withOpacity(0.45),
          ),
        ),
        // Cyan dot at top
        Positioned(
          left: 0,
          top: 6,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF00F0FF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust portion size',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _AdjustRow(label: 'Source of Protein'),
              const SizedBox(height: 24),
              _AdjustRow(label: 'Source of Carbs'),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdjustRow extends StatelessWidget {
  final String label;
  const _AdjustRow({required this.label});

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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.remove, color: Colors.white, size: 18),
              const SizedBox(width: 12),
              Text(
                '100 g',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.add, color: Colors.white, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Food Item model
// ─────────────────────────────────────────────────────────────
class _FoodItem {
  final String name;
  final String emoji;
  const _FoodItem(this.name, this.emoji);
}

// ─────────────────────────────────────────────────────────────
//  Horizontal scrollable food list
// ─────────────────────────────────────────────────────────────
class _HorizontalFoodList extends StatelessWidget {
  final List<_FoodItem> items;
  const _HorizontalFoodList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final item = items[i];
          return Container(
            width: 92,
            margin: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: const Color(0xFFF5F5F5),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF535D66),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'widgets/cart_drawer.dart';
import 'models/diet_models.dart';
import 'providers/cart_provider.dart';

class DietDetailScreen extends StatefulWidget {
  final DietProduct product;
  const DietDetailScreen({super.key, required this.product});

  @override
  State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  int _quantity = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getProductImage(String name) {
    final images = [
      'assets/diet/diet_best_seller_1.png',
      'assets/diet/diet_best_seller_2.png',
      'assets/diet/diet_best_seller_3.png',
      'assets/diet/diet_best_seller_4.png',
      'assets/diet/diet_recommend_1.png',
      'assets/diet/diet_recommend_2.png',
    ];
    final index = name.length % images.length;
    return images[index];
  }

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
          Expanded(
            child: Text(
              widget.product.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
                if (context.watch<CartProvider>().totalItems > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6FFFE9),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${context.watch<CartProvider>().totalItems}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildHeroSection(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const double heroH = 400;
    const double circleSize = 260;
    const double circleTop = 20;

    return SizedBox(
      width: w,
      height: heroH,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HourglassPainter())),
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
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _getProductImage(widget.product.name),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      width: 20,
                      height: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Text(
                  '$_quantity',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => setState(() => _quantity++),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w300),
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

  Widget _buildContentSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2329),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Information',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '5.0',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 10),
                        const Icon(Icons.favorite, color: Colors.red, size: 20),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BadgeContainer(
                      label: 'Category',
                      alignRight: false,
                      child: Text(
                        widget.product.productCategory.isNotEmpty ? widget.product.productCategory : 'Food',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _BadgeContainer(
                      label: 'Price',
                      alignRight: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.product.price.toStringAsFixed(2),
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
                const SizedBox(height: 22),
                _GradientBorderBox(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      widget.product.description,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Options',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                _HorizontalFoodList(
                  items: const [
                    _FoodItem('Medium', '🍽️'),
                    _FoodItem('Large', '🍱'),
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

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: const Color(0xFF1B2329),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: GestureDetector(
        onTap: () {
          context.read<CartProvider>().addToCart(widget.product, _quantity);
          _scaffoldKey.currentState?.openEndDrawer();
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Add to Cart',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final double waistY = h * 0.6;
    const double waistInsetL = 0.25;
    const double waistInsetR = 0.75;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.cubicTo(w * 0.95, h * 0.2, w * waistInsetR, waistY - 40, w * waistInsetR, waistY);
    path.cubicTo(w * waistInsetR, waistY + 40, w * 0.95, h * 0.8, w, h);
    path.lineTo(0, h);
    path.cubicTo(w * 0.05, h * 0.8, w * waistInsetL, waistY + 40, w * waistInsetL, waistY);
    path.cubicTo(w * waistInsetL, waistY - 40, w * 0.05, h * 0.2, 0, 0);
    path.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3D9E92), Color(0xFF1E7268)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = const LinearGradient(
        colors: [Color(0xFF00B2FF), Color(0xFFB161FF), Color(0xFF00B2FF)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
      padding: const EdgeInsets.all(1),
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
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF26313A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _HorizontalFoodList extends StatelessWidget {
  final List<_FoodItem> items;
  const _HorizontalFoodList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  final String name;
  final String emoji;
  const _FoodItem(this.name, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF26313A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 8, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

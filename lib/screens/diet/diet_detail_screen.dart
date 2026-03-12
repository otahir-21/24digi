import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_constants.dart';
import 'models/diet_models.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_drawer.dart';

class DietDetailScreen extends StatefulWidget {
  final DietProduct product;
  const DietDetailScreen({super.key, required this.product});

  @override
  State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _quantity = 1;
  String _selectedSize = 'Medium';
  int _selectedGrams = 200;

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
            _buildHeader(context, s),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(context, s),
                    _buildContentSection(context, s),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context, s),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 12 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 30 * s,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              widget.product.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 18 * s,
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
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white70,
                  size: 26 * s,
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
                      constraints: BoxConstraints(minWidth: 14 * s, minHeight: 14 * s),
                      child: Text(
                        '${context.watch<CartProvider>().totalItems}',
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
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

  Widget _buildHeroSection(BuildContext context, double s) {
    final w = MediaQuery.of(context).size.width;
    const double heroH = 400; // Total height of the hero area
    final double circleSize = 260 * s;
    final double circleTop = 20 * s;

    return SizedBox(
      width: w,
      height: heroH * s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── The Hourglass Background ──
          Positioned.fill(child: CustomPaint(painter: _HourglassPainter())),

          // ── Circular Image ──
          Positioned(
            top: circleTop,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6FFFE9),
                  width: 3.5 * s,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6FFFE9).withOpacity(0.4),
                    blurRadius: 25 * s,
                    spreadRadius: 2 * s,
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.product.image.trim(),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Color(0xFF6FFFE9))),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24, size: 50),
                ),
              ),
            ),
          ),

          // ── Quantity Centered in the waist ──
          Positioned(
            bottom: 60 * s,
            child: Text(
              '$_quantity',
              style: GoogleFonts.inter(
                fontSize: 48 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          // ── Plus/Minus Buttons in the 'pockets' of the hourglass ──
          Positioned(
            bottom: 70 * s,
            left: 50 * s,
            child: _SideControlButton(
              s: s,
              icon: Icons.remove,
              onTap: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
            ),
          ),
          Positioned(
            bottom: 70 * s,
            right: 50 * s,
            child: _SideControlButton(
              s: s,
              icon: Icons.add,
              onTap: () => setState(() => _quantity++),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, double s) {
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
                      'Information',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text('5.0', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),
                // Portion selection
                Text(
                  'Select Portion (Grams)',
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [100, 200, 300, 400, 500].map((g) {
                    final isSelected = _selectedGrams == g;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGrams = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6FFFE9) : const Color(0xFF26313A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${g}g',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 28 * s),
                Text(
                  'Select Size',
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                _HorizontalSizeList(
                  items: [
                    _SizeItem('Medium', '🍽️', isSelected: _selectedSize == 'Medium', onTap: () => setState(() => _selectedSize = 'Medium')),
                    _SizeItem('Large', '🍱', isSelected: _selectedSize == 'Large', onTap: () => setState(() => _selectedSize = 'Large')),
                  ],
                  s: s,
                ),
                SizedBox(height: 30 * s),
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12 * s),
                Text(
                  widget.product.description,
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, double s) {
    return Container(
      color: const Color(0xFF1B2329),
      padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 24 * s),
      child: GestureDetector(
        onTap: () {
          context.read<CartProvider>().addToCart(
            widget.product, 
            _quantity,
            size: _selectedSize,
            grams: _selectedGrams,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0D1217),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Added to Cart!',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            _scaffoldKey.currentState?.openEndDrawer();
          });
        },
        child: Container(
          height: 54 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF6FFFE9),
            borderRadius: BorderRadius.circular(27 * s),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6FFFE9).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Text(
                'Add to Cart - ${(widget.product.price * _quantity).toInt()} AED',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
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
  const _SideControlButton({required this.s, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48 * s,
        height: 48 * s,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24 * s),
      ),
    );
  }
}

class _SizeItem {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  _SizeItem(this.label, this.icon, {this.isSelected = false, required this.onTap});
}

class _HorizontalSizeList extends StatelessWidget {
  final List<_SizeItem> items;
  final double s;
  const _HorizontalSizeList({required this.items, required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: item.isSelected ? const Color(0xFF6FFFE9) : const Color(0xFF26313A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(item.icon, style: TextStyle(fontSize: 16 * s)),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: item.isSelected ? Colors.black : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
    double waistY = size.height * 0.55;

    path.moveTo(0, 0);
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
      size.height * 0.8,
      size.width * 0.95,
      size.height * 0.95,
      size.width,
      size.height,
    );

    path.lineTo(0, size.height);

    // Left side CURVE IN to bottom-waist
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.95,
      size.width * 0.35,
      size.height * 0.8,
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

    // Add a glowing border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [Color(0xFF6FFFE9), Colors.transparent, Color(0xFF6FFFE9)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

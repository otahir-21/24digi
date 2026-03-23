import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_constants.dart';
import 'models/diet_models.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_drawer.dart';
import 'diet_repository.dart';

class DietDetailScreen extends StatefulWidget {
  final DietProduct product;
  const DietDetailScreen({super.key, required this.product});

  @override
  State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DietRepository _repository = DietRepository();
  int _quantity = 1;
  int _proteinGrams = 100;
  int _carbsGrams = 100;
  
  bool _isLoadingRecommendations = true;
  List<DietProduct> _recommendProducts = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final randoms = await _repository.getRandomProducts(limit: 4);
      if (mounted) {
        setState(() {
          _recommendProducts = randoms;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecommendations = false);
      }
    }
  }

  double get currentCalories => widget.product.calories + (_proteinGrams > 100 ? (_proteinGrams - 100) * 1.5 : 0) + (_carbsGrams > 100 ? (_carbsGrams - 100) * 1.2 : 0);
  double get currentProtein => widget.product.protein + (_proteinGrams > 100 ? (_proteinGrams - 100) * 0.3 : 0);
  double get currentCarbs => widget.product.carbs + (_carbsGrams > 100 ? (_carbsGrams - 100) * 0.3 : 0);
  double get currentFat => widget.product.fat;
  double get currentPrice => widget.product.price + (_proteinGrams > 100 ? (_proteinGrams - 100) * 0.1 : 0) + (_carbsGrams > 100 ? (_carbsGrams - 100) * 0.05 : 0);

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
        color: Color(0xFF1B2329), // Updated to match previous file content
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12 * s, bottom: 20 * s),
              width: 80 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nutritional facts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nutritional facts',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Text('4.7', style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white70)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 12),
                        const Icon(Icons.favorite, color: Colors.white54, size: 16),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),
                
                // Macros Info Grid Row 1
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _MacroBox(
                        s: s,
                        iconWidget: const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 18),
                        valueText: '${currentCalories.toInt()} kcal',
                        labelText: 'Calories',
                        borderColor: Colors.purple.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    Expanded(
                      flex: 5,
                      child: _MacroBox(
                        s: s,
                        iconWidget: null,
                        valueText: '${currentPrice.toStringAsFixed(2)} AED',
                        labelText: 'Price',
                        borderColor: Colors.teal.withOpacity(0.4),
                        isPrice: true,
                        valueFontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                // Macros Info Grid Row 2
                Row(
                  children: [
                    Expanded(
                      child: _MacroBox(
                        s: s,
                        iconWidget: _CircleIcon(color: Colors.purple, letter: 'P', size: s),
                        valueText: '${currentProtein.toInt()} g',
                        labelText: 'Portion',
                        borderColor: Colors.purple.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: _MacroBox(
                        s: s,
                        iconWidget: _CircleIcon(color: Colors.green, letter: 'C', size: s),
                        valueText: '${currentCarbs.toInt()} g',
                        labelText: 'Carbs',
                        borderColor: Colors.teal.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: _MacroBox(
                        s: s,
                        iconWidget: _CircleIcon(color: Colors.orange, letter: 'F', size: s),
                        valueText: '${currentFat.toInt()} g',
                        labelText: 'Fat',
                        borderColor: Colors.orange.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),

                // Description Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16 * s),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12 * s),
                    border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1.5),
                  ),
                  child: Text(
                    widget.product.description.isEmpty ? 'description about the food ingredients calories and any info about the food' : widget.product.description,
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 32 * s),

                // Adjust portion size title
                Row(
                  children: [
                    Container(width: 3 * s, height: 16 * s, decoration: BoxDecoration(color: const Color(0xFF6FFFE9), borderRadius: BorderRadius.circular(2))),
                    SizedBox(width: 8 * s),
                    Text(
                      'Adjust portion size',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),

                // Source of Protein
                _AdjustRow(
                  s: s,
                  title: 'Source of Protein',
                  grams: _proteinGrams,
                  onIncrement: () => setState(() => _proteinGrams += 50),
                  onDecrement: () { if(_proteinGrams > 50) setState(() => _proteinGrams -= 50); },
                ),
                SizedBox(height: 24 * s),
                // Source of Carbs
                _AdjustRow(
                  s: s,
                  title: 'Source of Carbs',
                  grams: _carbsGrams,
                  onIncrement: () => setState(() => _carbsGrams += 50),
                  onDecrement: () { if(_carbsGrams > 50) setState(() => _carbsGrams -= 50); },
                ),
                
                SizedBox(height: 32 * s),

                // Recommendations
                Text(
                  'Recommendations',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16 * s),
                if (_isLoadingRecommendations)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF6FFFE9)))
                else if (_recommendProducts.isEmpty)
                  Text('No recommendations', style: TextStyle(color: Colors.white54))
                else
                  SizedBox(
                    height: 130 * s,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendProducts.length,
                      itemBuilder: (context, index) {
                        final rp = _recommendProducts[index];
                        return _RecommendationItem(s: s, product: rp, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DietDetailScreen(product: rp)));
                        });
                      },
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
      child: Center(
        child: GestureDetector(
          onTap: () {
            context.read<CartProvider>().addToCart(
              widget.product, 
              _quantity,
              size: 'Medium',
              proteinGrams: _proteinGrams,
              carbsGrams: _carbsGrams,
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
            width: 200 * s,
            height: 50 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF5A5F65),
              borderRadius: BorderRadius.circular(25 * s),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                SizedBox(width: 12 * s),
                Text(
                  'Add to Cart',
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
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

class _CircleIcon extends StatelessWidget {
  final Color color;
  final String letter;
  final double size;
  const _CircleIcon({required this.color, required this.letter, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20 * size,
      height: 20 * size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  final double s;
  final Widget? iconWidget;
  final String valueText;
  final String labelText;
  final Color borderColor;
  final bool isPrice;
  final double valueFontSize;

  const _MacroBox({
    required this.s,
    this.iconWidget,
    required this.valueText,
    required this.labelText,
    required this.borderColor,
    this.isPrice = false,
    this.valueFontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidget != null) ...[
                iconWidget!,
                SizedBox(width: 8 * s),
              ],
              Text(
                valueText,
                style: GoogleFonts.inter(
                  fontSize: valueFontSize * s,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Padding(
          padding: EdgeInsets.only(left: 8 * s),
          child: Text(
            labelText,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdjustRow extends StatelessWidget {
  final double s;
  final String title;
  final int grams;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _AdjustRow({
    required this.s,
    required this.title,
    required this.grams,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4 * s),
            Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * s),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: const Color(0xFF6FFFE9), width: 1.5),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Icon(Icons.remove, color: Colors.white, size: 18 * s),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 50 * s,
                child: Text(
                  '$grams g',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Icon(Icons.add, color: Colors.white, size: 18 * s),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final double s;
  final DietProduct product;
  final VoidCallback onTap;

  const _RecommendationItem({required this.s, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100 * s,
        margin: EdgeInsets.only(right: 12 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF26313A),
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16 * s)),
                child: CachedNetworkImage(
                  imageUrl: product.image.trim(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white12),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    '${product.price.toInt()} AED',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    double waistY = size.height * 0.55;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    path.cubicTo(
      size.width * 0.85,
      size.height * 0.1,
      size.width * 0.65,
      size.height * 0.3,
      size.width * 0.65,
      waistY,
    );

    path.cubicTo(
      size.width * 0.65,
      size.height * 0.8,
      size.width * 0.95,
      size.height * 0.95,
      size.width,
      size.height,
    );

    path.lineTo(0, size.height);

    path.cubicTo(
      size.width * 0.05,
      size.height * 0.95,
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.35,
      waistY,
    );

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

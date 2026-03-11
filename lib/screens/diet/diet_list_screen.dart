import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'widgets/cart_drawer.dart';
import 'diet_detail_screen.dart';
import 'diet_repository.dart';
import 'models/diet_models.dart';

class DietListScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final bool showAll;

  const DietListScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    this.showAll = false,
  });

  @override
  State<DietListScreen> createState() => _DietListScreenState();
}

class _DietListScreenState extends State<DietListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DietRepository _repository = DietRepository();
  List<DietCategory> _categories = [];
  List<DietProduct> _products = [];
  List<DietProduct> _filteredProducts = [];
  bool _isLoading = true;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await _repository.getCategories();
      
      List<DietProduct> products;
      if (widget.showAll) {
        products = await _repository.getProducts();
      } else {
        // Look for the current category to get its product IDs
        final currentCat = cats.firstWhere(
          (c) => c.productCategoryId == _selectedCategoryId,
          orElse: () => cats.first,
        );

        // Fetch products either by category field or by ID list
        products = await _repository.getProductsByCategory(_selectedCategoryId);
        
        if (products.isEmpty && currentCat.products.isNotEmpty) {
          products = await _repository.getProductsByIds(currentCat.products);
        }
      }

      setState(() {
        _categories = cats;
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
        if (widget.showAll && _selectedCategoryId != 'all') {
          _selectedCategoryId = 'all';
        }
      });
    } catch (e) {
      debugPrint('Error loading diet data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCategorySelected(String id) {
    if (_selectedCategoryId == id) return;
    setState(() {
      _selectedCategoryId = id;
      _isLoading = true;
    });
    _loadData();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _getCategoryImage(String label) {
    final l = label.toLowerCase();
    if (l.contains('main')) return 'assets/diet/diet_main_dish.png';
    if (l.contains('special')) return 'assets/diet/diet_special.png';
    if (l.contains('asia')) return 'assets/diet/diet_asia.png';
    if (l.contains('sandwich')) return 'assets/diet/diet_sandwich.png';
    if (l.contains('salad')) return 'assets/diet/diet_salad.png';
    return 'assets/diet/diet_salad.png';
  }

  String _getProductImage(int index) {
    final images = [
      'assets/diet/diet_best_seller_1.png',
      'assets/diet/diet_best_seller_2.png',
      'assets/diet/diet_best_seller_3.png',
      'assets/diet/diet_best_seller_4.png',
      'assets/diet/diet_recommend_1.png',
      'assets/diet/diet_recommend_2.png',
    ];
    return images[index % images.length];
  }

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
                            child: TextField(
                              onChanged: _onSearch,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13 * s,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                isDense: true,
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
                    image: 'assets/diet/diet_best_seller_1.png', 
                    label: 'All',
                    isSelected: _selectedCategoryId == 'all',
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = 'all';
                        _isLoading = true;
                      });
                      _loadData();
                    },
                  ),
                  ..._categories.map((cat) => _SmallCategoryItem(
                    s: s,
                    image: _getCategoryImage(cat.name),
                    label: cat.name,
                    isSelected: _selectedCategoryId == cat.productCategoryId,
                    onTap: () => _onCategorySelected(cat.productCategoryId),
                  )),
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
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF6FFFE9)))
                          : _filteredProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No products found',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16 * s),
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _filteredProducts[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DietDetailScreen(
                                              product: product,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _FoodListItem(
                                        product: product, 
                                        image: _getProductImage(index),
                                      ),
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
  final VoidCallback onTap;

  const _SmallCategoryItem({
    required this.s,
    required this.image,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70 * s,
        margin: EdgeInsets.only(right: 12 * s),
        child: Column(
          children: [
            CustomPaint(
              painter:
                  SmoothGradientBorder(radius: 30 * s, selected: isSelected),
              child: SizedBox(
                width: 60 * s,
                height: 60 * s,
                child: ClipOval(
                  child: Image.asset(image, fit: BoxFit.cover),
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
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final DietProduct product;
  final String image;
  const _FoodListItem({required this.product, required this.image});

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
                    image,
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
                          Expanded(
                            child: Text(
                              product.name.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${product.price.toInt()} AED',
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
                        product.description,
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

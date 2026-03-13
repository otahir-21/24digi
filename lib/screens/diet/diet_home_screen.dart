import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'diet_list_screen.dart';
import 'diet_detail_screen.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/profile_drawer.dart';
import 'diet_repository.dart';
import 'models/diet_models.dart';
import 'providers/cart_provider.dart';

class DietHomeScreen extends StatefulWidget {
  const DietHomeScreen({super.key});

  @override
  State<DietHomeScreen> createState() => _DietHomeScreenState();
}

class _DietHomeScreenState extends State<DietHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DietRepository _repository = DietRepository();
  List<DietCategory> _categories = [];
  List<DietProduct> _bestSellers = [];
  List<DietProduct> _recommendProducts = [];
  List<DietProduct> _filteredProducts = [];
  bool _isLoading = true;
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await _repository.getCategories();
      final products = await _repository.getProducts();
      final randoms = await _repository.getRandomProducts(limit: 4);
      setState(() {
        _categories = cats;
        _bestSellers = products;
        _recommendProducts = randoms;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading diet data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _bestSellers;
      } else {
        _filteredProducts = _bestSellers
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
                        height: 52 * s,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26 * s),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10 * s,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16 * s),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 22 * s,
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: TextField(
                                onChanged: _onSearch,
                                cursorColor: const Color(0xFF6FFFE9),
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search for meals...',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
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
                      badgeCount: context.watch<CartProvider>().totalItems,
                      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                    SizedBox(width: 8 * s),
                    _HeaderIcon(
                      s: s,
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                    ),
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
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6FFFE9)),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final cat = entry.value;
                        return _CategoryItem(
                          s: s,
                          image: cat.image,
                          label: cat.name,
                          onTap: () => _navToList(context, cat),
                        );
                      }).toList(),
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
                    GestureDetector(
                      onTap: () => _navToAll(context),
                      child: Row(
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
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),
                // Best Seller List
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6FFFE9)),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filteredProducts.map((product) {
                        return _BestSellerCard(
                          s: s,
                          image: product.image,
                          price: '${product.price.toInt()} AED',
                          onTap: () => _navToDetail(context, product),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 30 * s),
                // Promo Banner
                SizedBox(
                  height: 140 * s,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) =>
                        setState(() => _currentBannerPage = i),
                    itemCount: 5,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _navToAll(context),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4 * s),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 * s),
                          image: const DecorationImage(
                            image: AssetImage('assets/diet/diet_discount.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                        width: i == _currentBannerPage ? 24 * s : 12 * s,
                        height: 4 * s,
                        margin: EdgeInsets.symmetric(horizontal: 2 * s),
                        decoration: BoxDecoration(
                          color: i == _currentBannerPage
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
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6FFFE9)),
                  )
                else if (_recommendProducts.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _RecommendCard(
                          s: s,
                          image: _recommendProducts[0].image,
                          price: '${_recommendProducts[0].price.toInt()} AED',
                          onTap: () =>
                              _navToDetail(context, _recommendProducts[0]),
                        ),
                      ),
                      if (_recommendProducts.length > 1) ...[
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: _RecommendCard(
                            s: s,
                            image: _recommendProducts[1].image,
                            price: '${_recommendProducts[1].price.toInt()} AED',
                            onTap: () =>
                                _navToDetail(context, _recommendProducts[1]),
                          ),
                        ),
                      ],
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

  void _navToList(BuildContext context, DietCategory cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DietListScreen(
          categoryName: cat.name,
          categoryId: cat.productCategoryId,
        ),
      ),
    );
  }

  void _navToDetail(BuildContext context, DietProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DietDetailScreen(product: product)),
    );
  }

  void _navToAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DietListScreen(
          categoryName: 'All Products',
          categoryId: '',
          showAll: true,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final double s;
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  const _HeaderIcon({
    required this.s,
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2329),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 20 * s),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6FFFE9),
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16 * s,
                  minHeight: 16 * s,
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 8 * s,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
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
              child: SizedBox(
                width: 76 * s,
                height: 76 * s,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.white12),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.fastfood, color: Colors.white24),
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
  final VoidCallback onTap;
  const _BestSellerCard({
    required this.s,
    required this.image,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110 * s,
        height: 150 * s,
        margin: EdgeInsets.only(right: 12 * s),
        child: CustomPaint(
          painter: SmoothGradientBorder(radius: 20 * s),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20 * s),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: image.trim(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white12),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white24),
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
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final double s;
  final String image;
  final String price;
  final VoidCallback onTap;
  const _RecommendCard({
    required this.s,
    required this.image,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 24 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24 * s),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: image.trim(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white12),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white24),
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
      ),
    );
  }
}

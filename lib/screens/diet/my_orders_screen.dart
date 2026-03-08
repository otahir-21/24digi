import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'order_details_screen.dart';
import 'live_tracking_screen.dart';
import 'leave_review_screen.dart';
import 'cancel_order_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _activeTab = 'Active';

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 10 * s,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'My Orders',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24 * s),
                    // Custom Tab Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      child: Container(
                        padding: EdgeInsets.all(4 * s),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20 * s),
                        ),
                        child: Row(
                          children: [
                            _Tab(
                              s: s,
                              label: 'Active',
                              isActive: _activeTab == 'Active',
                              onTap: () =>
                                  setState(() => _activeTab = 'Active'),
                            ),
                            _Tab(
                              s: s,
                              label: 'Completed',
                              isActive: _activeTab == 'Completed',
                              onTap: () =>
                                  setState(() => _activeTab = 'Completed'),
                            ),
                            _Tab(
                              s: s,
                              label: 'Cancelled',
                              isActive: _activeTab == 'Cancelled',
                              onTap: () =>
                                  setState(() => _activeTab = 'Cancelled'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(child: _buildContent(s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double s) {
    if (_activeTab == 'Active') {
      return _buildActiveList(s);
    } else if (_activeTab == 'Completed') {
      return _buildCompletedList(s);
    } else {
      return _buildCancelledList(s);
    }
  }

  Widget _buildActiveList(double s) {
    // Check if we want to show empty state or list
    // const bool showEmpty = false; // Toggle for testing

    // if (showEmpty) {
    //   return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(
    //           Icons.description_outlined,
    //           color: Colors.white24,
    //           size: 120 * s,
    //         ),
    //         SizedBox(height: 24 * s),
    //         Text(
    //           "You don't have any\nactive orders at this\ntime ⟳",
    //           textAlign: TextAlign.center,
    //           style: GoogleFonts.inter(
    //             fontSize: 22 * s,
    //             fontWeight: FontWeight.w800,
    //             color: const Color(0xFFFF6B6B),
    //             height: 1.2,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return ListView(
      padding: EdgeInsets.all(24 * s),
      children: [
        _OrderCard(
          s: s,
          name: 'Strawberry Shake',
          price: '20.00',
          dateTime: '29 Nov, 01:20 pm',
          items: 2,
          image: 'assets/diet/diet_best_seller_1.png',
          status: 'Active',
          onTap: () => _openDetails(context),
        ),
        _OrderCard(
          s: s,
          name: 'Chicken Burger',
          price: '20.00',
          dateTime: '17 Oct, 01:20 pm',
          items: 1,
          image: 'assets/diet/diet_best_seller_2.png',
          status: 'Active',
          onTap: () => _openDetails(context),
        ),
        _OrderCard(
          s: s,
          name: '24 Sushi',
          price: '25.00',
          dateTime: '22 Apr, 01:20 pm',
          items: 2,
          image: 'assets/diet/diet_best_seller_1.png',
          status: 'Active',
          onTap: () => _openDetails(context),
        ),
      ],
    );
  }

  Widget _buildCompletedList(double s) {
    return ListView(
      padding: EdgeInsets.all(24 * s),
      children: [
        _OrderCard(
          s: s,
          name: '24 Chicken',
          price: '50.00',
          dateTime: '29 Nov, 01:20 pm',
          items: 2,
          image: 'assets/diet/diet_best_seller_1.png',
          status: 'Completed',
          onTap: () => _openDetails(context),
        ),
        _OrderCard(
          s: s,
          name: 'Beef Burger',
          price: '50.00',
          dateTime: '10 Nov, 06:05 pm',
          items: 2,
          image: 'assets/diet/diet_best_seller_2.png',
          status: 'Completed',
          onTap: () => _openDetails(context),
        ),
      ],
    );
  }

  Widget _buildCancelledList(double s) {
    return ListView(
      padding: EdgeInsets.all(24 * s),
      children: [
        _OrderCard(
          s: s,
          name: '24 Sushi',
          price: '25.00',
          dateTime: '02 Nov, 04:00 pm',
          items: 3,
          image: 'assets/diet/diet_best_seller_1.png',
          status: 'Cancelled',
          onTap: () => _openDetails(context),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
    );
  }
}

class _Tab extends StatelessWidget {
  final double s;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.s,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32 * s,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF6B6B) : Colors.transparent,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final double s;
  final String name;
  final String price;
  final String dateTime;
  final int items;
  final String image;
  final String status;
  final VoidCallback onTap;

  const _OrderCard({
    required this.s,
    required this.name,
    required this.price,
    required this.dateTime,
    required this.items,
    required this.image,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24 * s),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.asset(
                    image,
                    width: 80 * s,
                    height: 80 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateTime,
                            style: GoogleFonts.inter(
                              fontSize: 11 * s,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            '$items items',
                            style: GoogleFonts.inter(
                              fontSize: 11 * s,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      if (status == 'Completed') ...[
                        SizedBox(height: 8 * s),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFFFF6B6B),
                              size: 14,
                            ),
                            SizedBox(width: 4 * s),
                            Text(
                              'Order delivered',
                              style: GoogleFonts.inter(
                                fontSize: 11 * s,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ] else if (status == 'Cancelled') ...[
                        SizedBox(height: 8 * s),
                        Row(
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              color: Color(0xFFFF6B6B),
                              size: 14,
                            ),
                            SizedBox(width: 4 * s),
                            Text(
                              'Order cancelled',
                              style: GoogleFonts.inter(
                                fontSize: 11 * s,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 12 * s),
                      if (status == 'Active')
                        Row(
                          children: [
                            _ActionButton(
                              s: s,
                              label: 'Cancel Order',
                              color: const Color(0xFFFF6B6B),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CancelOrderScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 12 * s),
                            _ActionButton(
                              s: s,
                              label: 'Track Driver',
                              color: const Color(0xFF0D1217),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LiveTrackingScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      else if (status == 'Completed')
                        Row(
                          children: [
                            _ActionButton(
                              s: s,
                              label: 'Leave a review',
                              color: const Color(0xFF0D1217),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LeaveReviewScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 12 * s),
                            _ActionButton(
                              s: s,
                              label: 'Order Again',
                              color: const Color(0xFF0D1217),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            const Divider(color: Colors.white10),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double s;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.s,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

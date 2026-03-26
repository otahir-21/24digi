import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_order_detail_screen.dart';

enum OrderStatus { pending, delivered, cancelled }

class ShopOrdersScreen extends StatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  State<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends State<ShopOrdersScreen> {
  OrderStatus _selectedTab = OrderStatus.pending;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      'My Orders',
                      style: GoogleFonts.outfit(
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    
                    // Filter Tabs (Pending, Delivered, Cancelled)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FilterTab(
                          label: 'Processing',
                          isSelected: _selectedTab == OrderStatus.pending,
                          s: s,
                          onTap: () => setState(() => _selectedTab = OrderStatus.pending),
                        ),
                        _FilterTab(
                          label: 'Delivered',
                          isSelected: _selectedTab == OrderStatus.delivered,
                          s: s,
                          onTap: () => setState(() => _selectedTab = OrderStatus.delivered),
                        ),
                        _FilterTab(
                          label: 'Cancelled',
                          isSelected: _selectedTab == OrderStatus.cancelled,
                          s: s,
                          onTap: () => setState(() => _selectedTab = OrderStatus.cancelled),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32 * s),
                    
                    // Orders List
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: _getOrdersForTab(_selectedTab, s),
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

  List<Widget> _getOrdersForTab(OrderStatus tab, double s) {
    if (tab == OrderStatus.pending) {
      return [
        _OrderCard(s: s, orderId: '2024101', date: '25/03/2026', trackingNum: 'DP87368838', quantity: '2', total: '200', status: 'Processing', statusColor: const Color(0xFFEBC17B), orderStatus: OrderStatus.pending),
        _OrderCard(s: s, orderId: '2024098', date: '22/03/2026', trackingNum: 'DP873218897', quantity: '3', total: '200', status: 'Processing', statusColor: const Color(0xFFEBC17B), orderStatus: OrderStatus.pending),
      ];
    } else if (tab == OrderStatus.delivered) {
      return [
        _OrderCard(s: s, orderId: '1928374', date: '15/03/2026', trackingNum: 'DP987362341', quantity: '1', total: '51', status: 'Delivered', statusColor: const Color(0xFF2AA952), orderStatus: OrderStatus.delivered),
      ];
    } else {
      return [
        _OrderCard(s: s, orderId: '1829374', date: '10/03/2026', trackingNum: 'DP287368831', quantity: '2', total: '100', status: 'Cancelled', statusColor: const Color(0xFFFF3E3E), orderStatus: OrderStatus.cancelled),
      ];
    }
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final double s;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(99),
          border: isSelected ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final double s;
  final String orderId;
  final String date;
  final String trackingNum;
  final String quantity;
  final String total;
  final String status;
  final Color statusColor;
  final OrderStatus orderStatus;

  const _OrderCard({
    required this.s,
    required this.orderId,
    required this.date,
    required this.trackingNum,
    required this.quantity,
    required this.total,
    required this.status,
    required this.statusColor,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24 * s),
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5), // Accurate light beige
        borderRadius: BorderRadius.circular(24 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10 * s,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: GoogleFonts.outfit(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          _infoRow('Tracking number:', trackingNum, s),
          SizedBox(height: 8 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoRow('Quantity:', quantity, s),
              Row(
                children: [
                  Text(
                    'Total Amount: ',
                    style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black45, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$$total',
                    style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopOrderDetailScreen(orderId: orderId, status: orderStatus),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 12 * s),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Text(
                status,
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, double s) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.black38, fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 8 * s),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ],
    );
  }
}

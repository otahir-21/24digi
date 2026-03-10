import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
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
      backgroundColor: const Color(0xFF3D352F), // Dark brown/charcoal
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Text(
                      'My Orders',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    
                    // Filter Tabs (Pending, Delivered, Cancelled)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FilterTab(
                          label: 'Pending',
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
        _OrderCard(s: s, orderId: '1524', date: '13/05/2021', trackingNum: 'IK287368838', quantity: '2', subtotal: '200', status: 'PENDING', statusColor: const Color(0xFFEBC17B), orderStatus: OrderStatus.pending),
        _OrderCard(s: s, orderId: '1524', date: '12/05/2021', trackingNum: 'IK2873218897', quantity: '3', subtotal: '200', status: 'PENDING', statusColor: const Color(0xFFEBC17B), orderStatus: OrderStatus.pending),
        _OrderCard(s: s, orderId: '1524', date: '10/05/2021', trackingNum: 'IK237368820', quantity: '5', subtotal: '200', status: 'PENDING', statusColor: const Color(0xFFEBC17B), orderStatus: OrderStatus.pending),
      ];
    } else if (tab == OrderStatus.delivered) {
      return [
        _OrderCard(s: s, orderId: '1514', date: '13/05/2021', trackingNum: 'IK987362341', quantity: '2', subtotal: '200', status: 'DELIVERED', statusColor: const Color(0xFF2AA952), orderStatus: OrderStatus.delivered),
        _OrderCard(s: s, orderId: '1679', date: '12/05/2021', trackingNum: 'IK3873218890', quantity: '3', subtotal: '200', status: 'DELIVERED', statusColor: const Color(0xFF2AA952), orderStatus: OrderStatus.delivered),
        _OrderCard(s: s, orderId: '1671', date: '10/05/2021', trackingNum: 'IK237368881', quantity: '3', subtotal: '200', status: 'DELIVERED', statusColor: const Color(0xFF2AA952), orderStatus: OrderStatus.delivered),
      ];
    } else {
      return [
        _OrderCard(s: s, orderId: '1829', date: '10/05/2021', trackingNum: 'IK287368831', quantity: '2', subtotal: '200', status: 'CANCELED', statusColor: const Color(0xFFFF3E3E), orderStatus: OrderStatus.cancelled),
        _OrderCard(s: s, orderId: '1824', date: '10/05/2021', trackingNum: 'IK2882918812', quantity: '3', subtotal: '200', status: 'CANCELED', statusColor: const Color(0xFFFF3E3E), orderStatus: OrderStatus.cancelled),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF26313A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white,
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
  final String subtotal;
  final String status;
  final Color statusColor;
  final OrderStatus orderStatus;

  const _OrderCard({
    required this.s,
    required this.orderId,
    required this.date,
    required this.trackingNum,
    required this.quantity,
    required this.subtotal,
    required this.status,
    required this.statusColor,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24 * s),
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12),
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
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEBC17B),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          _infoRow('Tracking number:', trackingNum, s),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoRow('Quanlity:', quantity, s),
              Row(
                children: [
                  Text(
                    'Subtotal: ',
                    style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38),
                  ),
                  Text(
                    subtotal,
                    style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(width: 4 * s),
                  _dpIcon(s, size: 24),
                ],
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
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
                  padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 8 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(color: const Color(0xFFEBC17B).withOpacity(0.5)),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38),
        ),
        SizedBox(width: 8 * s),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _dpIcon(double s, {double size = 14}) {
    return Container(
      width: size * s * 0.7, height: size * s * 0.7,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F0FF), width: 1.5)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: size * s * 0.25, fontWeight: FontWeight.w900, color: const Color(0xFF00F0FF))),
    );
  }
}

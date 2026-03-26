import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/shop/shop_gender_screen.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_orders_screen.dart'; // To use OrderStatus
import 'shop_track_order_screen.dart';
import 'shop_rate_product_screen.dart';

class ShopOrderDetailScreen extends StatelessWidget {
  final String orderId;
  final OrderStatus status;

  const ShopOrderDetailScreen({
    super.key,
    this.orderId = '1524',
    this.status = OrderStatus.pending,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    Center(child: _buildUsername(s)),
                    SizedBox(height: 12 * s),
                    Text(
                      'Order #$orderId',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Status Banner
                    _buildStatusBanner(context, s),

                    SizedBox(height: 24 * s),

                    // Order Info (Address, Tracking etc)
                    _buildOrderInfoCard(s),

                    SizedBox(height: 32 * s),

                    // Items List
                    _buildItemsList(s),

                    SizedBox(height: 32 * s),

                    // Total Breakdown
                    _buildTotalBreakdown(s),

                    SizedBox(height: 48 * s),

                    // Bottom Buttons
                    _buildBottomButtons(context, s),

                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsername(double s) {
    return Text(
      'HI, USER',
      style: GoogleFonts.outfit(
        fontSize: 10 * s,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, double s) {
    String title = "";
    String subtitle = "";
    IconData icon = Icons.delivery_dining_rounded;
    Color bgColor = const Color(0xFF1B1813).withOpacity(0.5);

    if (status == OrderStatus.pending) {
      title = "Your order is on the way";
      subtitle = "Click here to track your order";
      icon = Icons.local_shipping_outlined;
    } else if (status == OrderStatus.delivered) {
      title = "Your order is delivered";
      subtitle = "Rate product to get 5 points for collect.";
      icon = Icons.inventory_2_outlined;
    } else {
      title = "Your order is cancelled";
      subtitle = "The item is out of stock or other reason.";
      icon = Icons.cancel_outlined;
    }

    return GestureDetector(
      onTap: () {
        if (status == OrderStatus.pending) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShopTrackOrderScreen(orderId: orderId),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(20 * s),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: const Color(0xFFEBC17B).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEBC17B),
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: const Color(0xFFEBC17B), size: 40 * s),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1813).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        children: [
          _infoRow('Order number', '#$orderId', s),
          SizedBox(height: 12 * s),
          _infoRow('Tracking Number', 'IK287368838', s),
          SizedBox(height: 12 * s),
          _infoRow('Delivery address', 'SBI Building, Software Park', s),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(double s) {
    return Column(
      children: [
        _itemRow('Sportwear Set', 'x1', '200', s),
        SizedBox(height: 16 * s),
        _itemRow('Cotton T-shirt', 'x1', '200', s),
      ],
    );
  }

  Widget _itemRow(String name, String qty, String price, double s) {
    return Row(
      children: [
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 16 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          qty,
          style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60),
        ),
        SizedBox(width: 24 * s),
        Text(
          price,
          style: GoogleFonts.outfit(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4 * s),
        Image.asset(
          'assets/profile/profile_digi_point.png',
          width: 24 * s,
          height: 24 * s,
        ),
      ],
    );
  }

  Widget _buildTotalBreakdown(double s) {
    return Column(
      children: [
        Divider(color: Colors.white10),
        SizedBox(height: 12 * s),
        _totalRow('Sub Total', '200', s),
        SizedBox(height: 8 * s),
        _totalRow(
          'Shipping',
          status == OrderStatus.cancelled ? '0.00' : '200',
          s,
        ),
        SizedBox(height: 16 * s),
        _totalRow(
          'Total',
          status == OrderStatus.cancelled ? '0' : '200',
          s,
          isMain: true,
        ),
      ],
    );
  }

  Widget _totalRow(
    String label,
    String value,
    double s, {
    bool isMain = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isMain ? 18 * s : 14 * s,
            fontWeight: isMain ? FontWeight.w800 : FontWeight.w500,
            color: isMain ? const Color(0xFFEBC17B) : Colors.white60,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: isMain ? 20 * s : 16 * s,
                fontWeight: FontWeight.w800,
                color: isMain ? const Color(0xFFEBC17B) : Colors.white,
              ),
            ),
            SizedBox(width: 4 * s),
            Image.asset(
              'assets/profile/profile_digi_point.png',
              width: (isMain ? 28 : 22) * s,
              height: (isMain ? 28 : 22) * s,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, double s) {
    if (status == OrderStatus.delivered) {
      return Row(
        children: [
          Expanded(
            child: _btn(
              'Return home',
              s,
              isOutline: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopGenderScreen()),
              ),
            ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: _btn(
              'Rate',
              s,
              color: const Color(0xFFEAE0D5),
              textColor: Colors.black,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShopRateProductScreen(),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _btn(
      status == OrderStatus.cancelled ? 'Re-order' : 'Continue shopping',
      s,
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _btn(
    String label,
    double s, {
    Color? color,
    Color textColor = const Color(0xFFEBC17B),
    bool isOutline = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60 * s,
        decoration: BoxDecoration(
          color: isOutline
              ? Colors.transparent
              : (color ?? const Color(0xFF1B1813)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOutline ? const Color(0xFFEBC17B) : Colors.white10,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: isOutline ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }
}

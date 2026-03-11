import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../auth/auth_provider.dart';
import 'order_confirmed_screen.dart';
import 'providers/cart_provider.dart';
import 'models/diet_models.dart';
import 'diet_repository.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final DietAddress selectedAddress;
  final String paymentMethod;

  const PaymentSummaryScreen({
    super.key,
    required this.selectedAddress,
    required this.paymentMethod,
  });

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  bool _isProcessing = false;
  final DietRepository _repository = DietRepository();

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return;

    setState(() => _isProcessing = true);

    try {
      final order = DietOrder(
        id: '',
        userId: uid,
        items: cart.items
            .map(
              (item) => {
                'productId': item.product.id,
                'name': item.product.name,
                'quantity': item.quantity,
                'price': item.product.price,
              },
            )
            .toList(),
        subtotal: cart.subtotal,
        tax: 0.0,
        deliveryFee: 10.0,
        total: cart.subtotal + 10.0,
        status: 'pending',
        address: widget.selectedAddress.address,
        paymentMethod: widget.paymentMethod,
        createdAt: DateTime.now(),
      );

      await _repository.createOrder(order);
      cart.clearCart();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OrderConfirmedScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cart = context.watch<CartProvider>();

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
                    'Order Summary',
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * s),
                    // Shipping Address Box
                    _HeadingRow(
                      s: s,
                      title: 'Shipping Address',
                      onEdit: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 12 * s),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * s,
                        vertical: 14 * s,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26313A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedAddress.label,
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.selectedAddress.address,
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // Order Summary
                    _HeadingRow(
                      s: s,
                      title: 'Cart Items',
                      onEdit: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 16 * s),
                    ...cart.items.map(
                      (item) => _OrderSummaryRow(
                        s: s,
                        name: item.product.name,
                        qty: item.quantity,
                        price:
                            '${(item.product.price * item.quantity).toStringAsFixed(2)} AED',
                      ),
                    ),

                    const Divider(color: Colors.white10, height: 32),

                    // Payment Method
                    _HeadingRow(
                      s: s,
                      title: 'Payment Method',
                      onEdit: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 16 * s),
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 28 * s,
                        ),
                        SizedBox(width: 12 * s),
                        Text(
                          widget.paymentMethod,
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white10, height: 48),

                    // Price Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                        Text(
                          '${cart.subtotal.toStringAsFixed(2)} AED',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                        Text(
                          '10.00 AED',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(cart.subtotal + 10).toStringAsFixed(2)} AED',
                          style: GoogleFonts.inter(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60 * s),

                    Center(
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              color: Color(0xFFFF6B6B),
                            )
                          : GestureDetector(
                              onTap: _placeOrder,
                              child: Container(
                                width: 180 * s,
                                height: 48 * s,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  borderRadius: BorderRadius.circular(24 * s),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Pay Now',
                                  style: GoogleFonts.inter(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
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
}

class _HeadingRow extends StatelessWidget {
  final double s;
  final String title;
  final VoidCallback onEdit;
  const _HeadingRow({
    required this.s,
    required this.title,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Text(
            'Edit',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final double s;
  final String name;
  final int qty;
  final String price;

  const _OrderSummaryRow({
    required this.s,
    required this.name,
    required this.qty,
    this.price = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'x$qty',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

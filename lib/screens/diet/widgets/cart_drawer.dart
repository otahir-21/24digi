import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_constants.dart';
import '../delivery_address_list_screen.dart';
import '../providers/cart_provider.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cart = context.watch<CartProvider>();
    final bool _isEmpty = cart.items.isEmpty;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30 * s),
          bottomLeft: Radius.circular(30 * s),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20 * s),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: _isEmpty ? Colors.redAccent : Colors.black,
                    size: 20 * s,
                  ),
                ),
                SizedBox(width: 12 * s),
                Text(
                  'Cart',
                  style: GoogleFonts.inter(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15 * s),
            const Divider(color: Colors.white10, thickness: 1),
            Expanded(
              child: _isEmpty ? _buildEmptyState(s) : _buildFullState(cart, s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          SizedBox(height: 10 * s),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            width: 160 * s,
            height: 160 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B),
              borderRadius: BorderRadius.circular(32 * s),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80 * s,
                  height: 80 * s,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 48 * s),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * s),
          Text(
            'Want To Add\nSomething?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildFullState(CartProvider cart, double s) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have ${cart.totalItems} items',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20 * s),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemTile(
                s: s,
                item: item,
                onUpdateGrams: (val) {
                  cart.updateItem(index, grams: val);
                },
                onAdd: () => cart.updateQuantity(
                  item.product.id,
                  item.selectedSize,
                  item.quantity + 1,
                ),
                onRemove: () => cart.updateQuantity(
                  item.product.id,
                  item.selectedSize,
                  item.quantity - 1,
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
          child: Column(
            children: [
              _PriceRow(
                s: s,
                label: 'Subtotal',
                value: '${cart.subtotal.toStringAsFixed(2)} AED',
              ),
              SizedBox(height: 8 * s),
              _PriceRow(s: s, label: 'Delivery', value: '15.00 AED'),
              SizedBox(height: 12 * s),
              _PriceRow(
                s: s,
                label: 'Total',
                value: '${(cart.subtotal + 15).toStringAsFixed(2)} AED',
                isTotal: true,
              ),
              SizedBox(height: 20 * s),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeliveryAddressListScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
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
                  alignment: Alignment.center,
                  child: Text(
                    'PROCEED TO CHECKOUT',
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final double s;
  final CartItem item;
  final Function(int) onUpdateGrams;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.s,
    required this.item,
    required this.onUpdateGrams,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController(
      text: widget.item.selectedGrams.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.selectedGrams != widget.item.selectedGrams) {
      _gramsController.text = widget.item.selectedGrams.toString();
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final item = widget.item;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12 * s),
          child: CachedNetworkImage(
            imageUrl: item.product.image.trim(),
            width: 70 * s,
            height: 70 * s,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.white24),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Size: ${item.selectedSize}',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Grams: ',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(
                    width: 50 * s,
                    height: 24 * s,
                    child: TextField(
                      controller: _gramsController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        color: const Color(0xFF6FFFE9),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        final g = int.tryParse(val) ?? 200;
                        widget.onUpdateGrams(g);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(item.product.price * item.quantity).toStringAsFixed(2)} AED',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6FFFE9),
              ),
            ),
            SizedBox(height: 12 * s),
            Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20 * s),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 14 * s,
                      color: Colors.white70,
                    ),
                    onPressed: widget.onRemove,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 28 * s,
                      minHeight: 28 * s,
                    ),
                  ),
                  Text(
                    '${item.quantity}',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 14 * s, color: Colors.white70),
                    onPressed: widget.onAdd,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 28 * s,
                      minHeight: 28 * s,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.s,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 * s : 14 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 * s : 14 * s,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

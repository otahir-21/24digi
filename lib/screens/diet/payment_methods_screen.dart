import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'add_card_screen.dart';
import 'payment_summary_screen.dart';
import 'models/diet_models.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final DietAddress selectedAddress;
  const PaymentMethodsScreen({super.key, required this.selectedAddress});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'Credit Card';

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
                    'Payment Methods',
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
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D24),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 30 * s),
                    _PaymentTile(
                      s: s,
                      icon: Icons.credit_card_rounded,
                      label: 'Credit Card',
                      isSelected: _selectedMethod == 'Credit Card',
                      onTap: () =>
                          setState(() => _selectedMethod = 'Credit Card'),
                    ),
                    const Divider(color: Colors.white10),
                    _PaymentTile(
                      s: s,
                      icon: Icons.apple,
                      label: 'Apple Pay',
                      isSelected: _selectedMethod == 'Apple Pay',
                      onTap: () =>
                          setState(() => _selectedMethod = 'Apple Pay'),
                    ),
                    const Divider(color: Colors.white10),
                    _PaymentTile(
                      s: s,
                      icon: Icons.play_arrow_rounded,
                      label: 'Google Pay',
                      isSelected: _selectedMethod == 'Google Pay',
                      onTap: () =>
                          setState(() => _selectedMethod = 'Google Pay'),
                    ),
                    const Divider(color: Colors.white10),
                    _PaymentTile(
                      s: s,
                      icon: Icons.wallet_rounded,
                      label: 'Points',
                      isSelected: _selectedMethod == 'Points',
                      onTap: () => setState(() => _selectedMethod = 'Points'),
                    ),
                    const Divider(color: Colors.white10),

                    const Spacer(),

                    GestureDetector(
                      onTap: () => _navigateToSummary(context),
                      child: Container(
                        width: double.infinity,
                        height: 48 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(24 * s),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCardScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 180 * s,
                        height: 44 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26313A),
                          borderRadius: BorderRadius.circular(22 * s),
                          border: Border.all(color: Colors.white12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Add New Card',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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

  void _navigateToSummary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSummaryScreen(
          selectedAddress: widget.selectedAddress,
          paymentMethod: _selectedMethod,
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final double s;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.s,
    required this.label,
    this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.payment,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.white70,
              size: 32 * s,
            ),
            SizedBox(width: 24 * s),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 20 * s,
              height: 20 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF6B6B) : Colors.white24,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

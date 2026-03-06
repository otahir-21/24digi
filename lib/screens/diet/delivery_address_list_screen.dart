import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'add_address_screen.dart';
import 'payment_methods_screen.dart';

class DeliveryAddressListScreen extends StatelessWidget {
  const DeliveryAddressListScreen({super.key});

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
                    'Delivery Address',
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
                    const Divider(color: Colors.white10),
                    _AddressTile(
                      s: s,
                      label: 'My home',
                      address: '778 Al Madar, Umm Al Quwain',
                      isSelected: true,
                      onTap: () => _navigateToPayment(context),
                    ),
                    const Divider(color: Colors.white10),
                    _AddressTile(
                      s: s,
                      label: 'My Office',
                      address: '221 Al Dana Building, Umm Al Quwain',
                      onTap: () => _navigateToPayment(context),
                    ),
                    const Divider(color: Colors.white10),
                    _AddressTile(
                      s: s,
                      label: "Parent's House",
                      address: 'Downtown Dubai, Dubai',
                      onTap: () => _navigateToPayment(context),
                    ),
                    const Divider(color: Colors.white10),

                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddNewAddressScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 180 * s,
                        height: 44 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(22 * s),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Add New Address',
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

  void _navigateToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final double s;
  final String label;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.s,
    required this.label,
    required this.address,
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
              Icons.home_outlined,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.white70,
              size: 32 * s,
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    address,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22 * s,
              height: 22 * s,
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

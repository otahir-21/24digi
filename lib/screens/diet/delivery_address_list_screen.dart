import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../auth/auth_provider.dart';
import 'add_address_screen.dart';
import 'payment_methods_screen.dart';
import 'diet_repository.dart';
import 'models/diet_models.dart';

class DeliveryAddressListScreen extends StatefulWidget {
  const DeliveryAddressListScreen({super.key});

  @override
  State<DeliveryAddressListScreen> createState() => _DeliveryAddressListScreenState();
}

class _DeliveryAddressListScreenState extends State<DeliveryAddressListScreen> {
  final DietRepository _repository = DietRepository();
  List<DietAddress> _addresses = [];
  bool _isLoading = true;
  DietAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      final ads = await _repository.getAddresses(uid);
      setState(() {
        _addresses = ads;
        if (_addresses.isNotEmpty && _selectedAddress == null) {
          _selectedAddress = _addresses.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                    
                    if (_isLoading)
                      const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B))))
                    else if (_addresses.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No addresses found.\nPlease add one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.white54),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _addresses.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            final ad = _addresses[index];
                            return _AddressTile(
                              s: s,
                              label: ad.label,
                              address: ad.address,
                              isSelected: _selectedAddress?.id == ad.id,
                              onTap: () {
                                setState(() => _selectedAddress = ad);
                              },
                            );
                          },
                        ),
                      ),

                    if (!_isLoading && _addresses.isNotEmpty) ...[
                      SizedBox(height: 20 * s),
                      GestureDetector(
                        onTap: () => _navigateToPayment(context),
                        child: Container(
                          width: double.infinity,
                          height: 48 * s,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(24 * s),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Select and Continue',
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20 * s),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddNewAddressScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadAddresses();
                        }
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
    if (_selectedAddress == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodsScreen(selectedAddress: _selectedAddress!),
      ),
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

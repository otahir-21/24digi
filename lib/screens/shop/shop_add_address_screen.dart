import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_payment_screen.dart';

class ShopAddAddressScreen extends StatefulWidget {
  final bool isEditing;
  const ShopAddAddressScreen({super.key, this.isEditing = false});

  @override
  State<ShopAddAddressScreen> createState() => _ShopAddAddressScreenState();
}

class _ShopAddAddressScreenState extends State<ShopAddAddressScreen> {
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController(text: '+971 ');
  final _altPhoneController = TextEditingController(text: '+971 ');
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _altPhoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

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
                    SizedBox(height: 32 * s),
                    Text(
                      'Adding Shipping Address',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Address Form Inputs
                    _buildInputField(label: 'Full name', controller: _fullNameController, s: s),
                    _buildInputField(label: 'Mobile Number', controller: _mobileController, s: s, keyboardType: TextInputType.phone),
                    _buildInputField(label: 'Alternative Phone Number (Optional)', controller: _altPhoneController, s: s, keyboardType: TextInputType.phone),
                    _buildSelectField(label: 'Emirate', value: 'Umm Al Qwuain', s: s),
                    _buildInputField(label: 'City / Area', controller: _cityController, s: s),
                    _buildInputField(label: 'Street Name', controller: _streetController, s: s),
                    _buildInputField(label: 'Building Name / Number', controller: _buildingController, s: s),
                    _buildInputField(label: 'Apartment / Villa Number', controller: _apartmentController, s: s),

                    SizedBox(height: 48 * s),

                    // Proceed Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShopPaymentScreen()),
                        );
                      },
                      child: Container(
                        width: 280 * s,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBC17B),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Proceed to checkout',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
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

  Widget _buildInputField({
    required String label, 
    required TextEditingController controller, 
    required double s,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2622),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEBC17B),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            cursorColor: const Color(0xFFEBC17B),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8 * s),
              hintText: '----------------------------------------',
              hintStyle: GoogleFonts.outfit(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField({required String label, required String value, required double s}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2622),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEBC17B),
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white60, size: 24 * s),
        ],
      ),
    );
  }
}

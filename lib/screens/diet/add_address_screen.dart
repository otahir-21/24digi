import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../auth/auth_provider.dart';
import 'diet_repository.dart';
import 'models/diet_models.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  final DietRepository _repository = DietRepository();

  Future<void> _saveAddress() async {
    final name = _nameController.text.trim();
    final addressText = _addressController.text.trim();

    if (name.isEmpty || addressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final address = DietAddress(
        id: '',
        userId: uid,
        label: name,
        address: addressText,
      );
      await _repository.saveAddress(address);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    'Add New Address',
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40 * s),
                      Icon(
                        Icons.home_outlined,
                        color: const Color(0xFFFF6B6B),
                        size: 100 * s,
                      ),
                      SizedBox(height: 40 * s),

                      _InputField(
                        s: s,
                        label: 'Label',
                        hint: 'e.g. Home, Office',
                        controller: _nameController,
                      ),
                      SizedBox(height: 24 * s),
                      _InputField(
                        s: s,
                        label: 'Full Address',
                        hint: 'Street, Building, Apartment',
                        controller: _addressController,
                      ),

                      SizedBox(height: 60 * s),

                      if (_isLoading)
                        const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                      else
                        GestureDetector(
                          onTap: _saveAddress,
                          child: Container(
                            width: 120 * s,
                            height: 36 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(18 * s),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Save',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final double s;
  final String label;
  final String hint;
  final TextEditingController controller;

  const _InputField({
    required this.s,
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        SizedBox(height: 12 * s),
        Container(
          height: 50 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF35414B),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14 * s),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14 * s,
                color: Colors.white.withOpacity(0.4),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

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
                child: Column(
                  children: [
                    SizedBox(height: 40 * s),
                    // Home Icon
                    Icon(
                      Icons.home_outlined,
                      color: const Color(0xFFFF6B6B),
                      size: 100 * s,
                    ),
                    SizedBox(height: 40 * s),

                    _InputField(s: s, label: 'Name', hint: 'User House'),
                    SizedBox(height: 24 * s),
                    _InputField(
                      s: s,
                      label: 'Address',
                      hint: '778 Al Madar, Umm Al Quwain',
                    ),

                    const Spacer(),

                    // Apply Button (Next)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to the list
                      },
                      child: Container(
                        width: 120 * s,
                        height: 36 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(18 * s),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Next',
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
}

class _InputField extends StatelessWidget {
  final double s;
  final String label;
  final String hint;

  const _InputField({required this.s, required this.label, required this.hint});

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
          alignment: Alignment.centerLeft,
          child: Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

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
                    'Add Card',
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    children: [
                      SizedBox(height: 30 * s),
                      // Card Image (Placeholder or Asset)
                      Container(
                        width: double.infinity,
                        height: 200 * s,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12 * s),
                          border: Border.all(
                            color: const Color(0xFF00F0FF),
                            width: 1.5,
                          ),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/diet/diet_credit_card.png',
                            ), // Should use specific card asset if available
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Actual asset use as requested
                            Image.asset(
                              'assets/diet/diet_credit_card.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.black45,
                            ), // Tint for readability if needed
                            // Padding(
                            //   padding: EdgeInsets.all(24 * s),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       const Spacer(),
                            //       Text(
                            //         '000 000 000 00',
                            //         style: GoogleFonts.inter(
                            //           fontSize: 22 * s,
                            //           fontWeight: FontWeight.w800,
                            //           color: Colors.white,
                            //           letterSpacing: 2,
                            //         ),
                            //       ),
                            //       SizedBox(height: 12 * s),
                            //       Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Text(
                            //                 'Card Holder Name',
                            //                 style: GoogleFonts.inter(
                            //                   fontSize: 10 * s,
                            //                   color: Colors.white70,
                            //                 ),
                            //               ),
                            //               Text(
                            //                 'Halfan',
                            //                 style: GoogleFonts.inter(
                            //                   fontSize: 14 * s,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Colors.white,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //           Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Text(
                            //                 'Expiry Date',
                            //                 style: GoogleFonts.inter(
                            //                   fontSize: 10 * s,
                            //                   color: Colors.white70,
                            //                 ),
                            //               ),
                            //               Text(
                            //                 '04/28',
                            //                 style: GoogleFonts.inter(
                            //                   fontSize: 14 * s,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Colors.white,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30 * s),

                      _InputField(
                        s: s,
                        label: 'Card holder name',
                        hint: 'First Name, Last Name',
                      ),
                      SizedBox(height: 24 * s),
                      _InputField(
                        s: s,
                        label: 'Card Number',
                        hint: '000 000 000 00',
                      ),
                      SizedBox(height: 24 * s),

                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              s: s,
                              label: 'Expiry Date',
                              hint: '04/28',
                            ),
                          ),
                          SizedBox(width: 20 * s),
                          Expanded(
                            child: _InputField(
                              s: s,
                              label: 'CVV',
                              hint: '0000',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40 * s),

                      // Next Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          ); // Go back to payment methods list
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48 * s,
                          margin: EdgeInsets.symmetric(horizontal: 40 * s),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(24 * s),
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

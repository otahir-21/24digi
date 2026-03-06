import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'order_cancelled_success_screen.dart';

class CancelOrderScreen extends StatefulWidget {
  const CancelOrderScreen({super.key});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  String? _selectedReason;

  final List<String> _reasons = [
    'Change of mind / Ordered by mistake',
    'Address/Delivery details are incorrect',
    'Expected delivery time is too long',
    'Restaurant/Store is taking too long',
  ];

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
                    'Cancel Order',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
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
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor.',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24 * s),
                      const Divider(color: Colors.white10),

                      // Reasons List
                      ..._reasons.map((reason) => _buildReasonItem(s, reason)),

                      SizedBox(height: 32 * s),
                      Text(
                        'Others',
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      // Others Reason Box
                      Container(
                        width: double.infinity,
                        height: 100 * s,
                        decoration: BoxDecoration(
                          color: const Color(0xFF35414B),
                          borderRadius: BorderRadius.circular(20 * s),
                        ),
                        padding: EdgeInsets.all(16 * s),
                        child: Text(
                          'Others reason...',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white38,
                          ),
                        ),
                      ),

                      SizedBox(height: 60 * s),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OrderCancelledSuccessScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 180 * s,
                            height: 48 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(24 * s),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Submit',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(double s, String reason) {
    bool isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20 * s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reason,
                    style: GoogleFonts.inter(
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 22 * s,
                  height: 22 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
                          : Colors.white24,
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
          const Divider(color: Colors.white10, height: 1),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class AdventureRulesDetailScreen extends StatelessWidget {
  final String ruleTitle;
  final String ruleDescription;

  const AdventureRulesDetailScreen({
    super.key,
    required this.ruleTitle,
    required this.ruleDescription,
  });

  static const Color _background = Color(0xFF1E1813);
  static const Color _gold = Color(0xFFE0A10A);

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, s),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48 * s,
                      height: 48 * s,
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Icon(Icons.gavel_rounded, color: Colors.black, size: 28 * s),
                    ),
                    SizedBox(height: 24 * s),
                    Text(
                      ruleTitle.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      ruleDescription,
                      style: GoogleFonts.inter(
                        fontSize: 15 * s,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    _buildWarningBox(s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.chevron_left, color: Colors.white, size: 30 * s),
          ),
          const Spacer(),
          Text(
            'RULE DETAILS',
            style: GoogleFonts.outfit(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          SizedBox(width: 30 * s),
        ],
      ),
    );
  }

  Widget _buildWarningBox(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              'Violation of this rule may lead to immediate removal from the group without refund of entry fees.',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

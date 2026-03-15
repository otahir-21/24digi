import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

/// Private Zone card detail: Admin Rules & Conditions, Room Entry Fee,
/// Your Balance, Agree & Join / Cancel. (Screen 3 — Invite Only, Level +15.)
class PrivateZoneRulesScreen extends StatelessWidget {
  final String roomName;
  final String bannerImage;
  final int entryFeeOp;
  final String adminName;

  const PrivateZoneRulesScreen({
    super.key,
    this.roomName = 'Kayaking Champions',
    this.bannerImage = 'assets/challenge/challenge_24_main_7.png',
    this.entryFeeOp = 500,
    this.adminName = 'Admin. Name',
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen = const Color(0xFF00FF88);
    final bgDark = const Color(0xFF0D1217);
    final cardDark = const Color(0xFF1E2A31);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8 * s),
                    _buildHiUser(s),
                    SizedBox(height: 16 * s),
                    _buildHeroImage(s),
                    SizedBox(height: 12 * s),
                    _buildPills(s),
                    SizedBox(height: 20 * s),
                    _buildAdminRulesSection(s, cardDark),
                    SizedBox(height: 20 * s),
                    _buildRoomEntryFeeSection(s, cardDark, themeGreen),
                    SizedBox(height: 24 * s),
                    _buildAgreeAndJoinButton(context, s, themeGreen),
                    SizedBox(height: 12 * s),
                    _buildCancelLink(context, s),
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

  Widget _buildHiUser(double s) {
    return Center(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final name = auth.profile?.name?.trim();
          final greeting = (name != null && name.isNotEmpty)
              ? 'HI, ${name.toUpperCase()}'
              : 'HI';
          return Text(
            greeting,
            style: GoogleFonts.outfit(
              fontSize: 11 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
              letterSpacing: 1.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroImage(double s) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: Image.asset(
            bannerImage,
            width: double.infinity,
            height: 180 * s,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * s),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12 * s,
          right: 12 * s,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: Colors.orangeAccent, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 14 * s,
                  color: Colors.orangeAccent,
                ),
                SizedBox(width: 4 * s),
                Text(
                  'Locked',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPills(double s) {
    return Row(
      children: [
        _pill(s, 'Invite Only'),
        SizedBox(width: 10 * s),
        _pill(s, 'Level +15'),
      ],
    );
  }

  Widget _pill(double s, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2E353C),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildAdminRulesSection(double s, Color cardDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Rules & Conditions',
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 14 * s),
        _buildRuleCard(
          s,
          cardDark,
          'Weekly Mileage Minimum',
          'Admin requires all members to log at least 25km per week to maintain room access.',
        ),
        SizedBox(height: 12 * s),
        _buildRuleCard(
          s,
          cardDark,
          'Strict Chat Policy',
          'This is a supportive space. Admin will ban users for toxicity or spam immediately.',
        ),
      ],
    );
  }

  Widget _buildRuleCard(
    double s,
    Color cardDark,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomEntryFeeSection(double s, Color cardDark, Color themeGreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room entry fees',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 10 * s),
          Row(
            children: [
              Text(
                '$entryFeeOp',
                style: GoogleFonts.outfit(
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8 * s),
              Container(
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeGreen, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DP',
                  style: GoogleFonts.outfit(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w800,
                    color: themeGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            '*Fees set by the room admin @$adminName',
            style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white54),
          ),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Text(
                'Your Current Balance',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 6 * s),
              Text(
                '1,200',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w800,
                  color: themeGreen,
                ),
              ),
              SizedBox(width: 4 * s),
              Container(
                width: 20 * s,
                height: 20 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeGreen, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DP',
                  style: GoogleFonts.outfit(
                    fontSize: 7 * s,
                    fontWeight: FontWeight.w800,
                    color: themeGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgreeAndJoinButton(
    BuildContext context,
    double s,
    Color themeGreen,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52 * s,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * s),
          ),
        ),
        child: Text(
          'Agree & Join',
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelLink(BuildContext context, double s) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

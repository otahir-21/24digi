import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'adventure_join_success_screen.dart';
import 'adventure_rules_detail_screen.dart';

class AdventureRulesScreen extends StatelessWidget {
  final String roomName;
  final String bannerImage;
  final double entryFee;
  final String adminName;

  const AdventureRulesScreen({
    super.key,
    required this.roomName,
    required this.bannerImage,
    required this.entryFee,
    required this.adminName,
  });

  static const Color _background = Color(0xFF1E1813);
  static const Color _panel = Color(0xFF13181D);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _cyan = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    _buildGreeting(s),
                    SizedBox(height: 20 * s),
                    _buildHeroSection(s),
                    SizedBox(height: 24 * s),
                    _buildRulesSection(context, s),
                    SizedBox(height: 24 * s),
                    _buildBalanceSection(s),
                    SizedBox(height: 24 * s),
                    _buildActionButtons(context, s),
                    SizedBox(height: 32 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(double s) {
    return Center(
      child: Text(
        'HI, USER',
        style: GoogleFonts.outfit(
          fontSize: 12 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white60,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildHeroSection(double s) {
    return Column(
      children: [
        Container(
          height: 160 * s,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * s),
            image: DecorationImage(image: AssetImage(bannerImage), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * s),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              ),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badgePill(s, 'Invite Only'),
            SizedBox(width: 8 * s),
            _badgePill(s, 'Level +15'),
          ],
        ),
      ],
    );
  }

  Widget _badgePill(double s, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 11 * s, fontWeight: FontWeight.w600, color: Colors.white70),
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Rules & Conditions',
          style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        SizedBox(height: 16 * s),
        _ruleCard(context, s, 'Weekly Mileage Minimum', 'Admin requires all members to log at least 25km per week to maintain room access.'),
        SizedBox(height: 12 * s),
        _ruleCard(context, s, 'Strict Chat Policy', 'This is a supportive space. Admin will ban users for toxicity or spam immediately.'),
      ],
    );
  }

  Widget _ruleCard(BuildContext context, double s, String title, String desc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdventureRulesDetailScreen(ruleTitle: title, ruleDescription: desc),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 6 * s),
            Text(desc, style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Room entry fees', style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white38)),
              const Spacer(),
              Text('${entryFee.toInt()}', style: GoogleFonts.outfit(fontSize: 20 * s, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(width: 8 * s),
              _dpIcon(s),
            ],
          ),
          SizedBox(height: 12 * s),
          const Divider(color: Colors.white10),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Text('Your Current Balance', style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white38)),
              const Spacer(),
              Text('1,200', style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: _gold)),
              SizedBox(width: 6 * s),
              _dpIcon(s, color: _gold, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dpIcon(double s, {Color color = Colors.white, double size = 22}) {
    return Container(
      width: size * s,
      height: size * s,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.5), width: 1)),
      alignment: Alignment.center,
      child: Text('DP', style: GoogleFonts.outfit(fontSize: (size / 3) * s, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Widget _buildActionButtons(BuildContext context, double s) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52 * s,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdventureJoinSuccessScreen(roomName: roomName),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * s)),
            ),
            child: Text('Agree & Join', style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w800)),
          ),
        ),
        SizedBox(height: 16 * s),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w600, color: Colors.white38, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'adventure_rules_screen.dart';

class AdventureJoinRoomScreen extends StatefulWidget {
  final String roomName;
  final bool isLocked;
  final String imagePath;
  final double entryFee;
  final String adminName;

  const AdventureJoinRoomScreen({
    super.key,
    required this.roomName,
    required this.isLocked,
    required this.imagePath,
    this.entryFee = 500,
    this.adminName = 'Khalfan',
  });

  @override
  State<AdventureJoinRoomScreen> createState() => _AdventureJoinRoomScreenState();
}

class _AdventureJoinRoomScreenState extends State<AdventureJoinRoomScreen> {
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  child: Column(
                    children: [
                      SizedBox(height: 12 * s),
                      _buildGreeting(s),
                      SizedBox(height: 4 * s),
                      _buildTitle(s),
                      SizedBox(height: 20 * s),
                      _buildRoomCard(s),
                      SizedBox(height: 20 * s),
                      _buildAboutSection(s),
                      SizedBox(height: 20 * s),
                      if (widget.isLocked) _buildApprovalRequired(s),
                      SizedBox(height: 20 * s),
                      _buildEntryFeeFooter(s),
                      SizedBox(height: 12 * s),
                      _buildActionButton(s),
                      SizedBox(height: 32 * s),
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

  Widget _buildGreeting(double s) {
    return Text(
      'HI, USER',
      style: GoogleFonts.outfit(
        fontSize: 12 * s,
        fontWeight: FontWeight.w600,
        color: Colors.white60,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTitle(double s) {
    return Text(
      widget.roomName.toUpperCase(),
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 28 * s,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRoomCard(double s) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
            child: Image.asset(
              widget.imagePath,
              width: double.infinity,
              height: 180 * s,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAdminInfo(s),
                    const Spacer(),
                    _buildStatusBadge(s),
                  ],
                ),
                SizedBox(height: 20 * s),
                _buildMembersProgress(s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfo(double s) {
    return Row(
      children: [
        Container(
          width: 40 * s,
          height: 40 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/fonts/male.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Admin',
              style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white38),
            ),
            Text(
              widget.adminName,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: _gold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(double s) {
    final color = widget.isLocked ? _gold : _cyan;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.isLocked ? Icons.lock : Icons.lock_open, size: 12 * s, color: color),
          SizedBox(width: 4 * s),
          Text(
            widget.isLocked ? 'Locked' : 'Open',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersProgress(double s) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '48/',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w800,
                      color: _gold,
                    ),
                  ),
                  TextSpan(
                    text: '50',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(4 * s),
          child: LinearProgressIndicator(
            value: 48 / 50,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(_gold),
            minHeight: 5 * s,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this room',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: _cyan,
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join our desert expedition! We are exploring the uncharted dunes. Only for advanced riders with recovery gear.',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16 * s),
              Text(
                'Key Rules',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * s),
              _buildBullet(s, 'Recovery gear is mandatory for all members.'),
              _buildBullet(s, 'Stay within 500m of the lead vehicle.'),
              _buildBullet(s, 'No night driving without prior approval.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.inter(fontSize: 13 * s, color: _gold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRequired(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: _gold, size: 24 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              'Approval Required. The admin will review your profile before you can join this room.',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryFeeFooter(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          Text(
            'ENTRY FEE',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.entryFee.toInt()}',
            style: GoogleFonts.outfit(
              fontSize: 22 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4 * s),
              border: Border.all(color: _cyan, width: 1),
            ),
            child: Text(
              'DP',
              style: GoogleFonts.outfit(
                fontSize: 9 * s,
                fontWeight: FontWeight.w800,
                color: _cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(double s) {
    return SizedBox(
      width: double.infinity,
      height: 54 * s,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdventureRulesScreen(
                roomName: widget.roomName,
                bannerImage: widget.imagePath,
                entryFee: widget.entryFee,
                adminName: widget.adminName,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * s),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.isLocked ? 'Send Request' : 'Join Now',
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/adventure_service.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'adventure_join_success_screen.dart';
import 'adventure_rules_detail_screen.dart';

class AdventureRulesScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String bannerImage;
  final double entryFee;
  final String adminName;
  final bool isLocked;

  const AdventureRulesScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.bannerImage,
    required this.entryFee,
    required this.adminName,
    required this.isLocked,
  });

  @override
  State<AdventureRulesScreen> createState() => _AdventureRulesScreenState();
}

class _AdventureRulesScreenState extends State<AdventureRulesScreen> {
  static const Color _background = Color(0xFF1E1813);
  static const Color _panel = Color(0xFF13181D);
  static const Color _gold = Color(0xFFE0A10A);

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
            if (_isLoading)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: _gold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(double s) {
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
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
              letterSpacing: 1.0,
            ),
          );
        },
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
            image: DecorationImage(
              image: widget.bannerImage.startsWith('http')
                  ? NetworkImage(widget.bannerImage) as ImageProvider
                  : AssetImage(widget.bannerImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * s),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
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
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Rules & Conditions',
          style: GoogleFonts.outfit(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16 * s),
        _ruleCard(
          context,
          s,
          'Weekly Mileage Minimum',
          'Admin requires all members to log at least 25km per week to maintain room access.',
        ),
        SizedBox(height: 12 * s),
        _ruleCard(
          context,
          s,
          'Strict Chat Policy',
          'This is a supportive space. Admin will ban users for toxicity or spam immediately.',
        ),
      ],
    );
  }

  Widget _ruleCard(BuildContext context, double s, String title, String desc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdventureRulesDetailScreen(
              ruleTitle: title,
              ruleDescription: desc,
            ),
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
              desc,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
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
              Text(
                'Room entry fees',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white38,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.entryFee.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8 * s),
              _dpIcon(s),
            ],
          ),
          SizedBox(height: 12 * s),
          const Divider(color: Colors.white10),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Text(
                'Your Current Balance',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white38,
                ),
              ),
              const Spacer(),
              Text(
                '1,200',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w800,
                  color: _gold,
                ),
              ),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        'DP',
        style: GoogleFonts.outfit(
          fontSize: (size / 3) * s,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double s) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52 * s,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * s),
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
        ),
        SizedBox(height: 16 * s),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleJoin() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.firebaseUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isLocked) {
        await AdventureService().requestJoinLockedRoom(
          roomId: widget.roomId,
          userId: userId,
          displayName: auth.profile?.name ?? 'Unknown User',
          avatarUrl: auth.profile?.profileImage ?? '',
        );
        if (mounted) {
          CustomSnackBar.show(context, message: 'Join request sent to admin.', isAdventure: true);
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        await AdventureService().joinAdventureRoom(
          roomId: widget.roomId,
          userId: userId,
          userName: auth.profile?.name ?? 'Unknown User',
          userAvatar: auth.profile?.profileImage ?? '',
          entryFee: widget.entryFee.toInt(),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdventureJoinSuccessScreen(
                roomId: widget.roomId,
                roomName: widget.roomName,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('room_full')) {
          msg = 'Room is full.';
        }
        CustomSnackBar.show(context, message: msg, isError: true, isAdventure: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

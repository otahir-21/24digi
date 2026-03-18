import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

class ShareActivityCardScreen extends StatelessWidget {
  final String roomName;
  final String distance;
  final String time;
  final String? imageUrl;
  final String? date;
  final String userName;

  const ShareActivityCardScreen({
    super.key,
    this.roomName = 'Competition Name',
    this.distance = '52 km',
    this.time = '45 m',
    this.imageUrl,
    this.date,
    this.userName = 'USER',
  });

  static const Color _bg = Color(0xFF13181D);
  static const Color _panel = Color(0xFF1E252C);

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _bg,
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
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'HI, ${userName.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    _buildHandle(s),
                    SizedBox(height: 16 * s),
                    Text(
                      'Share Activity',
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 20 * s),
                    _buildActivityCard(s),
                    SizedBox(height: 24 * s),
                    Text(
                      'Send to Friends',
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    _buildFriendsRow(s),
                    SizedBox(height: 24 * s),
                    _buildShareVia(s),
                    SizedBox(height: 24 * s),
                    _buildSocialRow(s),
                    SizedBox(height: 32 * s),
                    _buildActionButton(
                      s,
                      'Copy Link',
                      Icons.content_paste,
                      isIconRight: true,
                      onTap: () => _copyLink(context),
                    ),
                    SizedBox(height: 12 * s),
                    _buildActionButton(
                      s,
                      'Save to Gallery',
                      Icons.download_rounded,
                      isIconRight: false,
                      onTap: () => _saveToGallery(context),
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

  Widget _buildHandle(double s) {
    return Center(
      child: Container(
        width: 48 * s,
        height: 4 * s,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2 * s),
        ),
      ),
    );
  }

  Widget _buildActivityCard(double s) {
    final String displayDate = date ?? DateFormat('MMM dd, h:mm a').format(DateTime.now());
    
    ImageProvider imageProvider;
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      imageProvider = NetworkImage(imageUrl!);
    } else {
      imageProvider = AssetImage(imageUrl ?? 'assets/challenge/challenge_24_main_4.png');
    }

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
            child: Container(
              height: 180 * s,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20 * s,
                    bottom: 20 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          style: GoogleFonts.outfit(
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4 * s),
                        Text(
                          displayDate,
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20 * s,
                    bottom: 20 * s,
                    child: Row(
                      children: [
                        _activityMetric(s, distance, 'Distance'),
                        SizedBox(width: 16 * s),
                        _activityMetric(s, time, 'Time'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityMetric(double s, String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildFriendsRow(double s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(right: 16 * s),
            child: Column(
              children: [
                Container(
                  width: 56 * s,
                  height: 56 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/fonts/male.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Name #${i + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShareVia(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Via',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00E5FF),
          ),
        ),
        Container(
          height: 1.5 * s,
          width: 60 * s,
          color: const Color(0xFF00E5FF),
        ),
      ],
    );
  }

  Widget _buildSocialRow(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _socialIcon(s, 'Stories', const [
          Color(0xFF833AB4),
          Color(0xFFFD1D1D),
          Color(0xFFFCB045),
        ], Icons.camera_alt),
        _socialIcon(s, 'Facebook', [
          const Color(0xFF1877F2),
          const Color(0xFF1877F2),
        ], Icons.facebook),
        _socialIcon(s, 'WhatsApp', [
          const Color(0xFF25D366),
          const Color(0xFF25D366),
        ], Icons.chat),
        _socialIcon(
          s,
          'More',
          [const Color(0xFF3DC47E), const Color(0xFF3DC47E)],
          Icons.share,
          isOutline: true,
        ),
      ],
    );
  }

  Widget _socialIcon(
    double s,
    String label,
    List<Color> colors,
    IconData icon, {
    bool isOutline = false,
  }) {
    return Column(
      children: [
        Container(
          width: 50 * s,
          height: 50 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isOutline
                ? null
                : LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: isOutline
                ? Border.all(color: colors.first, width: 2)
                : null,
          ),
          child: Icon(icon, color: Colors.white, size: 24 * s),
        ),
        SizedBox(height: 8 * s),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    double s,
    String text,
    IconData icon, {
    required bool isIconRight,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50 * s,
        decoration: BoxDecoration(
          color: _panel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25 * s),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isIconRight) Icon(icon, color: Colors.white70, size: 20 * s),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (isIconRight)
              Icon(icon, color: Colors.white70, size: 20 * s)
            else
              SizedBox(width: 20 * s),
          ],
        ),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    final link = 'https://24digi.app/room/${roomName.replaceAll(' ', '-')}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Link copied to clipboard!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E252C),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveToGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Activity card saved to gallery!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E252C),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

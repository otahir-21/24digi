import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

/// Share Activity (challenge): activity card (map, Room Name, time, Distance/Time),
/// Send to Friends, Share Via (Stories, Facebook, WhatsApp, More), Copy Link, Save to Gallery.
class ShareActivityCardScreen extends StatelessWidget {
  final String roomName;
  final String distance;
  final String time;

  const ShareActivityCardScreen({
    super.key,
    this.roomName = 'Room Name',
    this.distance = '52 km',
    this.time = '45 m',
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen = const Color(0xFF00FF88);
    final bgDark = const Color(0xFF0D1217);

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
                    SizedBox(height: 16 * s),
                    Center(
                      child: Text(
                        'Share Activity',
                        style: GoogleFonts.outfit(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    _buildActivityCard(s),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle(s, 'Send to Friends'),
                    SizedBox(height: 12 * s),
                    _buildFriendsRow(s),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle(s, 'Share Via'),
                    SizedBox(height: 12 * s),
                    _buildShareViaRow(s, themeGreen),
                    SizedBox(height: 24 * s),
                    _buildCopyLinkButton(s),
                    SizedBox(height: 12 * s),
                    _buildSaveToGalleryButton(s),
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

  Widget _buildActivityCard(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A31),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16 * s)),
            child: Container(
              height: 160 * s,
              color: const Color(0xFF0F1923),
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 48 * s,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomName,
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'today, 8:30 AM',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distance,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Distance',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Time',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(double s, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14 * s,
        fontWeight: FontWeight.w700,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildFriendsRow(double s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(right: 16 * s),
            child: Column(
              children: [
                Container(
                  width: 52 * s,
                  height: 52 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E2A31),
                    border: Border.all(color: Colors.white24, width: 1),
                    image: const DecorationImage(
                      image: AssetImage('assets/fonts/male.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  'Name #${i + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShareViaRow(double s, Color themeGreen) {
    final items = [
      ('Stories', Icons.auto_awesome),
      ('Facebook', Icons.facebook),
      ('WhatsApp', Icons.chat),
      ('More', Icons.more_horiz),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((e) {
        return Column(
          children: [
            Container(
              width: 56 * s,
              height: 56 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeGreen.withValues(alpha: 0.15),
                border: Border.all(color: themeGreen, width: 1.5),
              ),
              child: Icon(e.$2, color: themeGreen, size: 26 * s),
            ),
            SizedBox(height: 8 * s),
            Text(
              e.$1,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCopyLinkButton(double s) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 50 * s,
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A31),
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Copy Link',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Icon(Icons.content_paste_outlined, size: 20 * s, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveToGalleryButton(double s) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 50 * s,
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A31),
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.download_outlined, size: 20 * s, color: Colors.white),
            Text(
              'Save to Gallery',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'group_chat_screen.dart';

/// Messages list for a room: when roomId/roomName are provided, shows this room's
/// group chat as a single conversation. Tapping opens GroupChatScreen for that room.
class MessagesListScreen extends StatelessWidget {
  final String? roomId;
  final String? roomName;

  const MessagesListScreen({
    super.key,
    this.roomId,
    this.roomName,
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
                        'Messages',
                        style: GoogleFonts.outfit(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * s),
                    _buildSearchBar(s),
                    SizedBox(height: 24 * s),
                    if (roomId != null && roomName != null)
                      _buildRoomChatTile(
                        context,
                        s,
                        themeGreen,
                        name: roomName!,
                        snippet: 'Group chat for this competition',
                        time: 'Open',
                        roomId: roomId!,
                      )
                    else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40 * s),
                          child: Text(
                            'Open a competition and use Group Chat to see messages here.',
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
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

  Widget _buildSearchBar(double s) {
    return Container(
      height: 44 * s,
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A31),
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20 * s, color: Colors.white38),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              'Search conversations...',
              style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomChatTile(
    BuildContext context,
    double s,
    Color themeGreen, {
    required String name,
    required String snippet,
    required String time,
    required String roomId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatScreen(roomId: roomId, roomName: name),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2 * s),
        padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 4 * s),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: themeGreen.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E2A31),
                border: Border.all(color: themeGreen, width: 1),
              ),
              child: Icon(Icons.chat_bubble_outline, color: themeGreen, size: 24 * s),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    snippet,
                    style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

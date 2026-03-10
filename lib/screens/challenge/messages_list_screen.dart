import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'group_chat_screen.dart';

class _Conversation {
  final String name;
  final String snippet;
  final String time;
  final bool hasUnread;

  const _Conversation(this.name, this.snippet, this.time, this.hasUnread);
}

/// Messages list: search, conversation threads (avatar, User Name, snippet, timestamp, green dot for unread).
class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  static const _conversations = [
    _Conversation('User Name', "Hey, are we still on for the run tomorrow?", '2m', true),
    _Conversation('User Name', 'Thanks for the invite!', '1h', true),
    _Conversation('User Name', "I'm excited for the weekend! Any plans for it?", 'Yesterday', false),
    _Conversation('User Name', 'See you at the track', 'Fri', false),
    _Conversation('User Name', 'Great session today', 'Wed', false),
    _Conversation('User Name', 'Let me know the time', 'Nov 2', false),
    _Conversation('User Name', 'Room is full now', 'Nov 15', false),
    _Conversation('User Name', 'New challenge started', 'Oct 20', false),
  ];

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
                    ..._conversations.asMap().entries.map((e) {
                      final c = e.value;
                      return _buildConversationTile(
                        context,
                        s,
                        themeGreen,
                        name: c.name,
                        snippet: c.snippet,
                        time: c.time,
                        hasUnread: c.hasUnread,
                        isSelected: e.key == 2,
                      );
                    }),
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
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    double s,
    Color themeGreen, {
    required String name,
    required String snippet,
    required String time,
    required bool hasUnread,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const GroupChatScreen(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2 * s),
        padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 4 * s),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * s),
          border: isSelected ? Border.all(color: Colors.blueAccent, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/fonts/male.png'),
                  fit: BoxFit.cover,
                ),
              ),
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
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasUnread)
                      Container(
                        width: 8 * s,
                        height: 8 * s,
                        margin: EdgeInsets.only(right: 4 * s),
                        decoration: BoxDecoration(
                          color: themeGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

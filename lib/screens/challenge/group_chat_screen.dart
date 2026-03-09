import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

enum _MessageType { received, sent }

class _ChatMessage {
  final _MessageType type;
  final String senderName;
  final String text;
  final bool showAvatar;
  final bool showTimestamp;
  final String? timestamp;

  const _ChatMessage({
    required this.type,
    required this.senderName,
    required this.text,
    this.showAvatar = false,
    this.showTimestamp = false,
    this.timestamp,
  });
}

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      type: _MessageType.received,
      senderName: 'Name #1',
      text: 'Hello, Join the new room now ok?',
      showAvatar: true,
      showTimestamp: true,
      timestamp: 'Today, 9:41 AM',
    ),
    _ChatMessage(
      type: _MessageType.sent,
      senderName: 'Me',
      text: 'Ok,\nNo, Problem',
    ),
    _ChatMessage(
      type: _MessageType.received,
      senderName: 'Name #3',
      text: 'Nice, that you will Join the new room',
      showAvatar: true,
    ),
    _ChatMessage(type: _MessageType.sent, senderName: 'Me', text: 'Done'),
    _ChatMessage(
      type: _MessageType.received,
      senderName: 'Name #1',
      text: 'ok',
      showAvatar: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            _buildChatRoomLabel(s),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 8 * s,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageItem(s, msg);
                },
              ),
            ),
            _buildInputBar(s),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomLabel(double s) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * s),
      child: Text(
        'Chat Room',
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          color: Colors.white38,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMessageItem(double s, _ChatMessage msg) {
    final isSent = msg.type == _MessageType.sent;

    return Column(
      crossAxisAlignment: isSent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Timestamp separator
        if (msg.showTimestamp && msg.timestamp != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16 * s),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 5 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E252C),
                  borderRadius: BorderRadius.circular(20 * s),
                ),
                child: Text(
                  msg.timestamp!,
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

        Padding(
          padding: EdgeInsets.only(bottom: 12 * s),
          child: isSent
              ? _buildSentBubble(s, msg)
              : _buildReceivedBubble(s, msg),
        ),
      ],
    );
  }

  Widget _buildReceivedBubble(double s, _ChatMessage msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Avatar + name column
        SizedBox(
          width: 52 * s,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (msg.showAvatar) ...[
                Container(
                  width: 38 * s,
                  height: 38 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF262C31),
                    border: Border.all(color: Colors.white12, width: 1),
                    image: const DecorationImage(
                      image: AssetImage('assets/fonts/male.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  msg.senderName,
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else
                SizedBox(width: 38 * s),
            ],
          ),
        ),
        SizedBox(width: 8 * s),
        // Bubble
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1E252C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * s),
                topRight: Radius.circular(16 * s),
                bottomRight: Radius.circular(16 * s),
                bottomLeft: Radius.circular(4 * s),
              ),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ),
        SizedBox(width: 48 * s),
      ],
    );
  }

  Widget _buildSentBubble(double s, _ChatMessage msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 60 * s),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: themeGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * s),
                topRight: Radius.circular(16 * s),
                bottomLeft: Radius.circular(16 * s),
                bottomRight: Radius.circular(4 * s),
              ),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217),
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          // Plus button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E252C),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Icon(Icons.add, color: Colors.white70, size: 20 * s),
            ),
          ),
          SizedBox(width: 8 * s),

          // Text field
          Expanded(
            child: Container(
              height: 40 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF1E252C),
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a massage ....',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white38,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14 * s,
                          vertical: 0,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  // Emoji button
                  Padding(
                    padding: EdgeInsets.only(right: 8 * s),
                    child: Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Colors.white38,
                      size: 18 * s,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8 * s),

          // Send button
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                _controller.clear();
              }
            },
            child: Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(
                color: themeGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 18 * s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

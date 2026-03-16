import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../services/challenge_service.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'messages_list_screen.dart';

enum _MessageType { received, sent }

class _ChatMessage {
  final _MessageType type;
  final String senderName;
  final String text;
  final bool showAvatar;
  final bool showTimestamp;
  final String? timestamp;
  final String? avatarUrl;

  const _ChatMessage({
    required this.type,
    required this.senderName,
    required this.text,
    this.showAvatar = false,
    this.showTimestamp = false,
    this.timestamp,
    this.avatarUrl,
  });
}

class GroupChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const GroupChatScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Chat Room',
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.firebaseUser?.uid;
    if (userId == null) return;

    _controller.clear();
    try {
      await ChallengeService().sendMessage(widget.roomId, {
        'user_id': userId,
        'display_name': auth.profile?.name ?? 'User',
        'avatar_url': auth.profile?.profileImage ?? '',
        'text': text,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final userId = context.watch<AuthProvider>().firebaseUser?.uid;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            _buildChatRoomLabel(s),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ChallengeService().getMessagesStream(widget.roomId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: themeGreen),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  final messages = <_ChatMessage>[];
                  String? lastDate;
                  for (var i = 0; i < docs.length; i++) {
                    final d = docs[i].data() as Map<String, dynamic>? ?? {};
                    final msgUserId = d['user_id']?.toString();
                    final displayName = d['display_name']?.toString() ?? 'User';
                    final text = d['text']?.toString() ?? '';
                    final sentAt = d['sent_at'] as Timestamp?;
                    final avatarUrl = d['avatar_url']?.toString();
                    final isSent = msgUserId == userId;

                    String? timestampStr;
                    if (sentAt != null) {
                      final dt = sentAt.toDate();
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final msgDay = DateTime(dt.year, dt.month, dt.day);
                      if (msgDay == today) {
                        timestampStr = 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                      } else {
                        timestampStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                      }
                    }
                    final showTs = timestampStr != null && timestampStr != lastDate;
                    if (showTs) lastDate = timestampStr;

                    messages.add(_ChatMessage(
                      type: isSent ? _MessageType.sent : _MessageType.received,
                      senderName: displayName,
                      text: text,
                      showAvatar: !isSent,
                      showTimestamp: showTs,
                      timestamp: timestampStr,
                      avatarUrl: avatarUrl,
                    ));
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hello!',
                        style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageItem(s, msg);
                    },
                  );
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
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.roomName,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessagesListScreen(
                    roomId: widget.roomId,
                    roomName: widget.roomName,
                  ),
                ),
              );
            },
            child: Text(
              'Messages',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: themeGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(double s, _ChatMessage msg) {
    final isSent = msg.type == _MessageType.sent;

    return Column(
      crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (msg.showTimestamp && msg.timestamp != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16 * s),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E252C),
                  borderRadius: BorderRadius.circular(20 * s),
                ),
                child: Text(
                  msg.timestamp!,
                  style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: 12 * s),
          child: isSent ? _buildSentBubble(s, msg) : _buildReceivedBubble(s, msg),
        ),
      ],
    );
  }

  Widget _buildReceivedBubble(double s, _ChatMessage msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
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
                  ),
                  child: ClipOval(
                    child: msg.avatarUrl != null && msg.avatarUrl!.startsWith('http')
                        ? Image.network(msg.avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: themeGreen, size: 24 * s))
                        : Image.asset('assets/fonts/male.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: themeGreen, size: 24 * s)),
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  msg.senderName,
                  style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else
                SizedBox(width: 38 * s),
            ],
          ),
        ),
        SizedBox(width: 8 * s),
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
              style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white, height: 1.4),
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
              style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.black, fontWeight: FontWeight.w600, height: 1.4),
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
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message....',
                        hintStyle: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 0),
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8 * s),
                    child: Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.white38, size: 18 * s),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(color: themeGreen, shape: BoxShape.circle),
              child: Icon(Icons.send_rounded, color: Colors.black, size: 18 * s),
            ),
          ),
        ],
      ),
    );
  }
}

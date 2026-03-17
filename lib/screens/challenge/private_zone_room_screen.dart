import 'package:flutter/material.dart';
import '../../core/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'group_chat_screen.dart';
import 'messages_list_screen.dart';
import 'private_zone_rules_screen.dart';
import 'room_members_screen.dart';
import 'share_activity_card_screen.dart';
import '../../services/challenge_service.dart';

class PrivateZoneRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String bannerImage;
  final int entryFee;
  final int members;
  final int maxMembers;
  final String adminName;
  final String rules;
  final bool isLocked;
  final List<String> participantIds;

  const PrivateZoneRoomScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Elite Runners Club',
    this.bannerImage = 'assets/challenge/challenge_24_main_1.png',
    this.entryFee = 500,
    this.members = 1,
    this.maxMembers = 20,
    this.adminName = 'Admin',
    this.rules = '',
    this.isLocked = false,
    this.participantIds = const [],
  });

  @override
  State<PrivateZoneRoomScreen> createState() => _PrivateZoneRoomScreenState();
}

class _PrivateZoneRoomScreenState extends State<PrivateZoneRoomScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  bool _isWeeklySelected = true;

  static const _leaderboardData = [
    {
      'rank': '01',
      'name': 'User Name',
      'calories': '850',
      'time': '1h 30m',
      'bpm': '850',
      'pace': '12.5',
      'height': "6'12\"",
      'isUser': false,
    },
    {
      'rank': '02',
      'name': 'User Name',
      'calories': '850',
      'time': '1h 30m',
      'bpm': '850',
      'pace': '12.5',
      'height': "6'12\"",
      'isUser': false,
    },
    {
      'rank': '03',
      'name': 'User Name',
      'calories': '850',
      'time': '1h 30m',
      'bpm': '850',
      'pace': '12.5',
      'height': "6'12\"",
      'isUser': false,
    },
    {
      'rank': '04',
      'name': 'User Name',
      'calories': '850',
      'time': '1h 30m',
      'bpm': '850',
      'pace': '12.5',
      'height': "6'12\"",
      'isUser': false,
    },
    {
      'rank': '05',
      'name': 'User Name',
      'calories': '850',
      'time': '1h 30m',
      'bpm': '850',
      'pace': '12.5',
      'height': "6'12\"",
      'isUser': false,
    },
  ];

  static const _userEntry = {
    'rank': '09',
    'name': 'Your Name',
    'calories': '850',
    'time': '1h 30m',
    'bpm': '850',
    'pace': '12.5',
    'height': "6'12\"",
    'isUser': true,
  };

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: bgDark,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8 * s),
                      _buildGreeting(s),
                      SizedBox(height: 4 * s),
                      _buildTitle(s),
                      SizedBox(height: 16 * s),
                      _buildRoomCard(s),
                      if (_isJoined(context)) ...[
                        SizedBox(height: 20 * s),
                        _buildLiveAndToggle(s),
                        SizedBox(height: 12 * s),
                        _buildLeaderboard(s),
                        SizedBox(height: 12 * s),
                        _buildSeeMore(s),
                        SizedBox(height: 8 * s),
                        _buildShareActivityLink(s),
                        SizedBox(height: 12 * s),
                        _buildUserRow(s),
                        SizedBox(height: 24 * s),
                        _buildQuitButton(s),
                      ] else if (widget.isLocked) ...[
                        SizedBox(height: 20 * s),
                        _buildAboutThisRoom(s),
                        SizedBox(height: 16 * s),
                        _buildApprovalRequired(s),
                        SizedBox(height: 24 * s),
                        _buildEntryFeeFooter(s),
                        _buildSendRequestButton(s),
                      ] else ...[
                        SizedBox(height: 20 * s),
                        _buildLiveAndToggle(s),
                        SizedBox(height: 12 * s),
                        _buildLeaderboard(s),
                        SizedBox(height: 12 * s),
                        _buildSeeMore(s),
                        SizedBox(height: 8 * s),
                        _buildShareActivityLink(s),
                        SizedBox(height: 12 * s),
                        _buildUserRow(s),
                        SizedBox(height: 24 * s),
                        _buildEntryFeeFooter(s),
                        _buildJoinNowButton(s),
                      ],
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
    return Consumer<AuthProvider>(
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
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        );
      },
    );
  }

  Widget _buildTitle(double s) {
    return Text(
      widget.roomName,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 26 * s,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildRoomCard(double s) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image inside card
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16 * s)),
            child: _buildRoomImage(widget.bannerImage, 140 * s, s),
          ),
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Room Admin + Room Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin avatar
                    Container(
                      width: 42 * s,
                      height: 42 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: themeGreen, width: 1.5 * s),
                        image: const DecorationImage(
                          image: AssetImage('assets/fonts/male.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Admin',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Text(
                            widget.adminName,
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w700,
                              color: themeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Room Status',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4 * s),
                        widget.isLocked
                            ? _buildLockedBadge(s)
                            : _buildOpenBadge(s),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14 * s),

                // Members row
                Row(
                  children: [
                    Text(
                      'Members',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      '${widget.members}/',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: themeGreen,
                      ),
                    ),
                    Text(
                      '${widget.maxMembers}',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * s),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4 * s),
                  child: LinearProgressIndicator(
                    value: widget.maxMembers > 0
                        ? widget.members / widget.maxMembers
                        : 0,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(themeGreen),
                    minHeight: 4 * s,
                  ),
                ),

                SizedBox(height: 14 * s),

                // Bottom row: avatar stack + View All + Messages + Group Chat
                Row(
                  children: [
                    SizedBox(
                      width: 60 * s,
                      height: 24 * s,
                      child: Stack(
                        children: [
                          _buildStackAvatar(s, 0),
                          _buildStackAvatar(s, 16 * s),
                          _buildStackAvatar(s, 32 * s),
                        ],
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RoomMembersScreen(
                                  roomId: widget.roomId,
                                  roomName: widget.roomName,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        'All',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: themeGreen,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: themeGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MessagesListScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 14 * s,
                                  color: themeGreen,
                                ),
                                SizedBox(width: 4 * s),
                                Text(
                                  'Chat',
                                  style: GoogleFonts.inter(
                                    fontSize: 11 * s,
                                    color: themeGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          _buildGroupChatButton(s),
                        ],
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

  Widget _buildLockedBadge(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF262C31),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: Colors.white70, size: 10 * s),
          SizedBox(width: 4 * s),
          Text(
            'Locked',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenBadge(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF262C31),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: themeGreen, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open_rounded, color: themeGreen, size: 10 * s),
          SizedBox(width: 4 * s),
          Text(
            'Open',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: themeGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutThisRoom(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            'About this room',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF13181D),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.rules.isNotEmpty
                    ? widget.rules
                    : 'Welcome to the elite circle of night runners. We push limits, break records, and earn massive DIGI points. This room is for those who take cardio seriously.',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 14 * s),
              Text(
                'Key Rules',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * s),
              _buildBullet(s, 'Sync your 24DIGI device daily before starting.'),
              _buildBullet(
                s,
                'Top 3 winners split the weekly pot (10k DIGI point).',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white70,
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
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: Colors.white54, size: 20 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              'Approval Required. This is a private room. Your profile stats will be reviewed by the admin before access is granted.',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Text(
            'ENTRY FEE',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            '${widget.entryFee}',
            style: GoogleFonts.outfit(
              fontSize: 20 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6 * s),
          Container(
            width: 22 * s,
            height: 22 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5FF), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              'DP',
              style: GoogleFonts.outfit(
                fontSize: 7 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendRequestButton(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * s),
      child: SizedBox(
        width: double.infinity,
        height: 52 * s,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: themeGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Send a Request',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinNowButton(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * s),
      child: SizedBox(
        width: double.infinity,
        height: 52 * s,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrivateZoneRulesScreen(
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  bannerImage: 'assets/challenge/challenge_24_main_7.png',
                  entryFeeOp: 500,
                  adminName: 'Admin_Name',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Join Now',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackAvatar(double s, double leftOffset) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 28 * s,
        height: 28 * s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: bgDark, width: 1.5),
          image: const DecorationImage(
            image: AssetImage('assets/fonts/male.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChatButton(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupChatScreen(roomId: widget.roomId, roomName: widget.roomName)),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36 * s,
            height: 36 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A31),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: themeGreen,
              size: 18 * s,
            ),
          ),
          SizedBox(width: 6 * s),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Group Chat',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: themeGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAndToggle(double s) {
    return Row(
      children: [
        // Live indicator
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(
            color: themeGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeGreen.withValues(alpha: 0.8),
                blurRadius: 6 * s,
                spreadRadius: 1 * s,
              ),
            ],
          ),
        ),
        SizedBox(width: 6 * s),
        Text(
          'Live',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        // Toggle pill
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E252C),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleOption(s, 'Weekly', _isWeeklySelected, () {
                setState(() => _isWeeklySelected = true);
              }),
              _buildToggleOption(s, 'All Time', !_isWeeklySelected, () {
                setState(() => _isWeeklySelected = false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    double s,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E3E48) : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(double s) {
    return Column(
      children: _leaderboardData.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8 * s),
          child: _buildLeaderboardRow(
            s,
            rank: entry['rank'] as String,
            name: entry['name'] as String,
            calories: entry['calories'] as String,
            time: entry['time'] as String,
            bpm: entry['bpm'] as String,
            pace: entry['pace'] as String,
            height: entry['height'] as String,
            isUser: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeeMore(double s) {
    return Text(
      'see more',
      style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white38),
    );
  }

  Widget _buildShareActivityLink(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShareActivityCardScreen(roomName: widget.roomName),
          ),
        );
      },
      child: Text(
        'Share Activity',
        style: GoogleFonts.inter(
          fontSize: 13 * s,
          color: themeGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserRow(double s) {
    return _buildLeaderboardRow(
      s,
      rank: _userEntry['rank'] as String,
      name: _userEntry['name'] as String,
      calories: _userEntry['calories'] as String,
      time: _userEntry['time'] as String,
      bpm: _userEntry['bpm'] as String,
      pace: _userEntry['pace'] as String,
      height: _userEntry['height'] as String,
      isUser: true,
    );
  }

  Widget _buildLeaderboardRow(
    double s, {
    required String rank,
    required String name,
    required String calories,
    required String time,
    required String bpm,
    required String pace,
    required String height,
    required bool isUser,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: themeGreen, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: isUser ? themeGreen : Colors.white70,
            ),
          ),
          SizedBox(height: 8 * s),
          // Stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank number
              Text(
                rank,
                style: GoogleFonts.outfit(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w800,
                  color: themeGreen,
                  height: 1,
                ),
              ),
              SizedBox(width: 8 * s),
              // Avatar
              Container(
                width: 34 * s,
                height: 34 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                  image: const DecorationImage(
                    image: AssetImage('assets/fonts/male.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(
                      s,
                      Icons.local_fire_department,
                      const Color(0xFFFF6B35),
                      calories,
                    ),
                    _buildStatCol(
                      s,
                      Icons.access_time_rounded,
                      Colors.blueAccent,
                      time,
                    ),
                    _buildStatCol(
                      s,
                      Icons.favorite,
                      const Color(0xFFE040FB),
                      bpm,
                    ),
                    _buildStatCol(
                      s,
                      Icons.location_on,
                      const Color(0xFFAB47BC),
                      pace,
                    ),
                    _buildStatCol(s, Icons.speed_rounded, themeGreen, height),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(double s, IconData icon, Color iconColor, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16 * s),
        SizedBox(height: 2 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  bool _isJoined(BuildContext context) {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) return false;
    return widget.participantIds.contains(userId);
  }

  Widget _buildQuitButton(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * s),
      child: SizedBox(
        width: double.infinity,
        height: 52 * s,
        child: ElevatedButton(
          onPressed: () => _showQuitConfirmation(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Quit Competition',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showQuitConfirmation() async {
    final s = AppConstants.scale(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A31),
        title: Text(
          'Quit Competition?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave this room? You will lose your current progress in this competition.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13 * s),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final userId = context.read<AuthProvider>().firebaseUser?.uid;
        if (userId != null) {
          await ChallengeService().quitChallengeRoom(
            roomId: widget.roomId,
            userId: userId,
          );
          if (mounted) {
            Navigator.pop(context);
            CustomSnackBar.show(context, message: 'Succesfully left the room', isAdventure: false);
          }
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(context, message: 'Error: ${e.toString()}', isError: true, isAdventure: false);
        }
      }
    }
  }

  Widget _buildRoomImage(String imagePath, double height, double s) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(height, s),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(height, s);
        },
      );
    }
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholder(height, s),
    );
  }

  Widget _buildPlaceholder(double height, double s) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.white12,
      child: Icon(Icons.image_outlined, color: Colors.white24, size: 30 * s),
    );
  }
}

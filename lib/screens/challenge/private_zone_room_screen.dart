import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'group_chat_screen.dart';
import 'private_zone_general_screen.dart';

class PrivateZoneRoomScreen extends StatefulWidget {
  final String roomName;
  const PrivateZoneRoomScreen({
    super.key,
    this.roomName = 'Elite Runners Club',
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
                      SizedBox(height: 20 * s),
                      _buildLiveAndToggle(s),
                      SizedBox(height: 12 * s),
                      _buildLeaderboard(s),
                      SizedBox(height: 12 * s),
                      _buildSeeMore(s),
                      SizedBox(height: 12 * s),
                      _buildUserRow(s),
                      SizedBox(height: 24 * s),
                      _buildCompetitionButton(s),
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
        color: Colors.white,
        letterSpacing: 1.0,
      ),
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
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
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
                      'Khalfan',
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
                  _buildLockedBadge(s),
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
                '48/',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                ),
              ),
              Text(
                '50',
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
              value: 48 / 50,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(themeGreen),
              minHeight: 4 * s,
            ),
          ),

          SizedBox(height: 14 * s),

          // Bottom row: avatar stack + View All + Group Chat
          Row(
            children: [
              // Avatar stack
              SizedBox(
                width: 72 * s,
                height: 28 * s,
                child: Stack(
                  children: [
                    _buildStackAvatar(s, 0),
                    _buildStackAvatar(s, 20 * s),
                    _buildStackAvatar(s, 40 * s),
                  ],
                ),
              ),
              SizedBox(width: 8 * s),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: themeGreen,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: themeGreen,
                  ),
                ),
              ),
              const Spacer(),
              _buildGroupChatButton(s),
            ],
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
          MaterialPageRoute(builder: (_) => const GroupChatScreen()),
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

  Widget _buildCompetitionButton(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivateZoneGeneralScreen()),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 60 * s,
        child: CustomPaint(
          painter: _CompetitionButtonPainter(
            borderColor: themeGreen,
            fillColor: const Color(0xFF13181D),
          ),
          child: ClipPath(
            clipper: _CompetitionButtonClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1A2620), const Color(0xFF0D1217)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Competition',
                style: GoogleFonts.outfit(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w800,
                  color: themeGreen,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: themeGreen.withValues(alpha: 0.6),
                      blurRadius: 12 * s,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips the competition button into a parallelogram shape (left-slanted)
class _CompetitionButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const slant = 24.0;
    final path = Path();
    path.moveTo(slant, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - slant, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints the border of the parallelogram button
class _CompetitionButtonPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  _CompetitionButtonPainter({
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const slant = 24.0;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(slant, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - slant, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../services/challenge_service.dart';
import '../../services/adventure_service.dart';
import 'group_chat_screen.dart';

/// My Room (public) detail: ended-competition style with Firestore data.
/// Dummy podium/leaderboard. My Performance, Full Leaderboard, Share Results, Group Chat.
class MyRoomPublicDetailScreen extends StatelessWidget {
  final String roomId;
  final bool isAdventure;

  const MyRoomPublicDetailScreen({
    super.key,
    required this.roomId,
    this.isAdventure = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ((isAdventure ? AdventureService() : ChallengeService())
              as dynamic)
          .getRoomStream(roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1217),
            body: Center(
              child:
                  snapshot.connectionState == ConnectionState.waiting
                      ? CircularProgressIndicator(
                        color: const Color(0xFF00FF88),
                      )
                      : Text(
                        'Room not found',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
            ),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        return _MyRoomPublicDetailContent(
          roomId: roomId,
          data: data,
          isAdventure: isAdventure,
        );
      },
    );
  }
}

class _MyRoomPublicDetailContent extends StatelessWidget {
  final String roomId;
  final Map<String, dynamic> data;
  final bool isAdventure;

  const _MyRoomPublicDetailContent({
    required this.roomId,
    required this.data,
    this.isAdventure = false,
  });

  String get _name => data['name']?.toString() ?? 'Competition';
  String get _imageUrl =>
      data['image_url']?.toString() ??
      'assets/challenge/challenge_24_main_2.png';
  int get _currentParticipants =>
      (data['current_participants'] is int)
          ? data['current_participants'] as int
          : ((data['current_participants'] is num)
              ? (data['current_participants'] as num).toInt()
              : 0);
  int get _maxParticipants =>
      (data['max_participants'] is int) ? data['max_participants'] as int : 120;
  String get _startDateFormatted {
    final startAt = data['start_at'];
    if (startAt is Timestamp) {
      final d = startAt.toDate();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    }
    return 'Jan 1, 2026';
  }

  String get _difficulty => data['difficulty']?.toString() ?? 'Beginner';
  String get _objective =>
      data['objective']?.toString() ??
      'Accumulate 50km total distance in urban zones.';
  int get _prizeAmount =>
      (data['prize_amount'] is int)
          ? data['prize_amount'] as int
          : ((data['prize_amount'] is num)
              ? (data['prize_amount'] as num).toInt()
              : 0);
  List<String> get _conditions {
    final c = data['conditions'];
    if (c is List) return c.map((e) => e.toString()).toList();
    return [
      'Must use the official app for tracking',
      'GPS tracking must be active all the time',
      'Activities must be completed within the time frame',
    ];
  }

  List<String> get _eligibility {
    final e = data['eligibility'];
    if (e is List) return e.map((e) => e.toString()).toList();
    return [
      'Age 16 or above',
      'Valid UAE residence',
      'Active challenge zone membership',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen =
        isAdventure ? const Color(0xFFE0A10A) : const Color(0xFF00FF88);
    const cardDark = Color(0xFF1E2A31);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, s),
            _buildGreeting(s),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10 * s),
                    _buildBanner(context, s),
                    SizedBox(height: 16 * s),
                    _buildTitleAndEnded(s, themeGreen),
                    SizedBox(height: 20 * s),
                    _buildPodium(s, themeGreen),
                    SizedBox(height: 16 * s),
                    _buildEmptyLeaderboard(s, themeGreen),
                    SizedBox(height: 10 * s),
                    Center(
                      child: Text(
                        'See more',
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    _buildSummaryCards(s, cardDark),
                    SizedBox(height: 20 * s),
                    _buildCompetitionDetails(s),
                    SizedBox(height: 20 * s),
                    _buildPrize(s, themeGreen),
                    SizedBox(height: 20 * s),
                    _buildObjective(s),
                    SizedBox(height: 20 * s),
                    _buildMyPerformance(s, themeGreen),
                    SizedBox(height: 24 * s),
                    _buildFullLeaderboardAndShare(s),
                    SizedBox(height: 16 * s),
                    _buildGroupChatButton(context, s, themeGreen),
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

  Widget _buildHeader(BuildContext context, double s) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      height: 52 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * s),
        gradient: const LinearGradient(
          colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1217),
          borderRadius: BorderRadius.circular(30 * s),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: EdgeInsets.all(4 * s),
                child: Icon(
                  Icons.chevron_left,
                  color: const Color(0xFF00F0FF),
                  size: 28 * s,
                ),
              ),
            ),
            Image.asset(
              'assets/images/digi_logo.png',
              height: 38 * s,
              fit: BoxFit.contain,
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 32 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipOval(
                  child:
                      profile?.profileImage != null &&
                              profile!.profileImage!.isNotEmpty
                          ? Image.network(
                            profile.profileImage!,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            profile?.gender?.toLowerCase() == 'female'
                                ? 'assets/fonts/female.png'
                                : 'assets/fonts/male.png',
                            fit: BoxFit.cover,
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
      builder:
          (context, auth, _) => Padding(
            padding: EdgeInsets.only(top: 4 * s, bottom: 8 * s),
            child: Text(
              'HI, ${(auth.profile?.name?.trim() ?? 'USER').toUpperCase()}',
              style: GoogleFonts.outfit(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
    );
  }

  Widget _buildBanner(BuildContext context, double s) {
    final isNetwork = _imageUrl.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child:
          isNetwork
              ? Image.network(
                _imageUrl,
                width: double.infinity,
                height: 160 * s,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(s),
              )
              : Image.asset(
                _imageUrl,
                width: double.infinity,
                height: 160 * s,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(s),
              ),
    );
  }

  Widget _placeholder(double s) => Container(
    width: double.infinity,
    height: 160 * s,
    color: const Color(0xFF1E2A31),
    alignment: Alignment.center,
    child: Icon(Icons.image_not_supported, color: Colors.white38, size: 48 * s),
  );

  Widget _buildTitleAndEnded(double s, Color themeGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _name,
          style: GoogleFonts.outfit(
            fontSize: 24 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8 * s),
        Row(
          children: [
            Container(
              width: 10 * s,
              height: 10 * s,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            Text(
              'LIVE',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPodium(double s, Color themeGreen) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          isAdventure
              ? AdventureService().getMessagesStream(roomId)
              : ChallengeService().getParticipantsStream(roomId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final top3 = docs.take(3).toList();

        if (top3.isEmpty) {
          return SizedBox(
            height: 200 * s,
            child: Center(
              child: Text(
                'No participants yet',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        }

        final names = top3.asMap().map((i, d) {
          final data = d.data() as Map<String, dynamic>;
          return MapEntry(i, data['display_name']?.toString() ?? 'User');
        });

        return SizedBox(
          height: 200 * s,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (top3.length > 1)
                _spot(
                  s,
                  2,
                  120 * s,
                  names[1] ?? '--',
                  const Color(0xFF4FC3F7),
                  'nd',
                ),
              if (top3.isNotEmpty)
                _spot(
                  s,
                  1,
                  160 * s,
                  names[0] ?? '--',
                  const Color(0xFFFFD700),
                  'st',
                  true,
                ),
              if (top3.length > 2)
                _spot(
                  s,
                  3,
                  100 * s,
                  names[2] ?? '--',
                  const Color(0xFFFFB74D),
                  'rd',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _spot(
    double s,
    int place,
    double height,
    String name,
    Color color,
    String suffix, [
    bool isCenter = false,
  ]) {
    final avatarSize = isCenter ? 72 * s : 56 * s;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.2),
                  border: Border.all(color: color, width: 2 * s),
                  image: DecorationImage(
                    image: AssetImage(
                      place == 1
                          ? 'assets/fonts/female.png'
                          : 'assets/fonts/male.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -8 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * s,
                    vertical: 2 * s,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8 * s),
                  ),
                  child: Text(
                    '$place$suffix',
                    style: GoogleFonts.outfit(
                      fontSize: isCenter ? 12 * s : 10 * s,
                      fontWeight: FontWeight.w800,
                      color: isCenter ? const Color(0xFF0D1217) : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4 * s),
          Container(
            width: double.infinity,
            height: height - avatarSize - 32 * s,
            decoration: BoxDecoration(
              color: isCenter ? color : color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8 * s)),
              border: Border(top: BorderSide(color: color, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboard(double s, Color themeGreen) {
    return Column(
      children: [
        for (int r = 4; r <= 10; r++)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: Container(
              height: 44 * s,
              padding: EdgeInsets.symmetric(horizontal: 10 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF13181D),
                borderRadius: BorderRadius.circular(22 * s),
                border: Border.all(
                  color: themeGreen.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30 * s,
                    height: 22 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1F17),
                      borderRadius: BorderRadius.circular(11 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r.toString().padLeft(2, '0'),
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: themeGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Container(
                    width: 28 * s,
                    height: 28 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/fonts/male.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Text(
                    '--',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildUserRankRow(s, themeGreen),
      ],
    );
  }

  Widget _buildUserRankRow(double s, Color themeGreen) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.profile?.name ?? 'You';
        return Padding(
          padding: EdgeInsets.only(bottom: 8 * s),
          child: Container(
            height: 44 * s,
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            decoration: BoxDecoration(
              color: themeGreen,
              borderRadius: BorderRadius.circular(22 * s),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 30 * s,
                  height: 22 * s,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(11 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '--',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8 * s),
                Container(
                  width: 28 * s,
                  height: 28 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/fonts/male.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double s, Color cardDark) {
    return Row(
      children: [
        Expanded(
          child: _card(
            s,
            cardDark,
            '$_currentParticipants/$_maxParticipants',
            'Participants',
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(child: _card(s, cardDark, _startDateFormatted, 'Start Date')),
        SizedBox(width: 8 * s),
        Expanded(child: _card(s, cardDark, _difficulty, 'Difficulty')),
      ],
    );
  }

  Widget _card(double s, Color cardDark, String val, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * s, horizontal: 8 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionDetails(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competition Details:',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * s),
          Padding(
            padding: EdgeInsets.only(left: 4 * s, bottom: 4 * s),
            child: Text(
              'Conditions:',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ..._conditions.map(
            (c) => Padding(
              padding: EdgeInsets.only(left: 20 * s, bottom: 2 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      c,
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          Padding(
            padding: EdgeInsets.only(left: 4 * s, bottom: 4 * s),
            child: Text(
              'Eligibility:',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ..._eligibility.map(
            (e) => Padding(
              padding: EdgeInsets.only(left: 20 * s, bottom: 2 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e,
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        color: Colors.white70,
                        height: 1.4,
                      ),
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

  Widget _buildPrize(double s, Color themeGreen) {
    final amountStr = _prizeAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    const bg = Color(0xFF1B2228);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prize',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Text(
                amountStr,
                style: GoogleFonts.outfit(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6 * s),
              Container(
                width: 24 * s,
                height: 24 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2D24),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeGreen),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DP',
                  style: GoogleFonts.outfit(
                    fontSize: 8 * s,
                    fontWeight: FontWeight.w800,
                    color: themeGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Expanded(
                child: _trophy(
                  s,
                  bg,
                  '1',
                  'Gold',
                  'assets/challenge/challenge_24_gold.png',
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: _trophy(
                  s,
                  bg,
                  '2',
                  'Silver',
                  'assets/challenge/challenge_24_silver.png',
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: _trophy(
                  s,
                  bg,
                  '3',
                  'Bronze',
                  'assets/challenge/challenge_24_bronze.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trophy(double s, Color bg, String rank, String label, String asset) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(asset, height: 48 * s, fit: BoxFit.contain),
              Positioned(
                top: 0,
                child: Text(
                  rank,
                  style: GoogleFonts.outfit(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjective(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A31),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objective',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            _objective,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPerformance(double s, Color themeGreen) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          isAdventure
              ? AdventureService().getRoomStream(roomId)
              : ChallengeService().getCompetitionStream(roomId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final myRank = data['my_rank']?.toString() ?? '--';
        final totalParticipants =
            data['total_participants']?.toString() ?? '--';
        final myScore = data['my_score']?.toString() ?? '--';
        final distance = data['distance_km']?.toString() ?? '--';
        final calories = data['calories']?.toString() ?? '--';
        final sessions = data['sessions']?.toString() ?? '--';

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF13181D),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Performance',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (myRank != '--' && totalParticipants != '--')
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 4 * s,
                      ),
                      decoration: BoxDecoration(
                        color: themeGreen,
                        borderRadius: BorderRadius.circular(8 * s),
                      ),
                      child: Text(
                        'Top ${((int.tryParse(myRank) ?? 0) / (int.tryParse(totalParticipants) ?? 1) * 100).ceil()}%',
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Rank',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: Colors.white54,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '#$myRank',
                            style: GoogleFonts.outfit(
                              fontSize: 28 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6 * s),
                            child: Text(
                              ' / $totalParticipants',
                              style: GoogleFonts.outfit(
                                fontSize: 12 * s,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Score',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: Colors.white54,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            myScore,
                            style: GoogleFonts.outfit(
                              fontSize: 20 * s,
                              fontWeight: FontWeight.w800,
                              color: themeGreen,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 4 * s),
                            child: Text(
                              ' pts',
                              style: GoogleFonts.inter(
                                fontSize: 11 * s,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20 * s),
              Row(
                children: [
                  Expanded(
                    child: _smallStat(s, distance, 'KM', Icons.linear_scale),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: _smallStat(
                      s,
                      calories,
                      'Kcal',
                      Icons.fitness_center,
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: _smallStat(
                      s,
                      sessions,
                      'Sessions',
                      Icons.directions_run,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _smallStat(double s, String val, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16 * s,
            color: const Color(0xFF00FF88).withValues(alpha: 0.7),
          ),
          SizedBox(height: 4 * s),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 15 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildFullLeaderboardAndShare(double s) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16 * s),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: Colors.white24, width: 1.5 * s),
            ),
            alignment: Alignment.center,
            child: Text(
              'Full Leaderboard',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2228),
              borderRadius: BorderRadius.circular(16 * s),
            ),
            alignment: Alignment.center,
            child: Text(
              'Share Results',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChatButton(
    BuildContext context,
    double s,
    Color themeGreen,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52 * s,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => GroupChatScreen(
                    roomId: roomId,
                    roomName: _name,
                    isAdventure: isAdventure,
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
          'Group Chat',
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

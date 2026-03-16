import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../services/challenge_service.dart';
import 'competition_system_alert_screen.dart';
import 'group_chat_screen.dart';

/// Joined challenge details screen for Private Zone — pixel-perfect UI with
/// Firestore data. Position/leaderboard is dummy. Quit option only when status == ACTIVE.
class JoinedChallengeDetailScreen extends StatelessWidget {
  final String roomId;

  const JoinedChallengeDetailScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ChallengeService().getRoomStream(roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1217),
            body: Center(
              child: CircularProgressIndicator(color: const Color(0xFF00FF88)),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1217),
            appBar: AppBar(backgroundColor: const Color(0xFF0D1217)),
            body: Center(
              child: Text(
                'Challenge not found',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
            ),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        return _JoinedChallengeDetailContent(
          roomId: roomId,
          data: data,
        );
      },
    );
  }
}

class _JoinedChallengeDetailContent extends StatelessWidget {
  final String roomId;
  final Map<String, dynamic> data;

  const _JoinedChallengeDetailContent({
    required this.roomId,
    required this.data,
  });

  bool get _isActive => (data['status'] ?? '').toString().toUpperCase() == 'ACTIVE';

  String get _name => data['name']?.toString() ?? 'Competition';

  String get _imageUrl =>
      data['image_url']?.toString() ?? 'assets/challenge/challenge_24_main_2.png';

  int get _currentParticipants => data['current_participants'] is int
      ? data['current_participants'] as int
      : (data['current_participants'] is num
          ? (data['current_participants'] as num).toInt()
          : 0);

  int get _maxParticipants => data['max_participants'] is int
      ? data['max_participants'] as int
      : (data['max_participants'] is num
          ? (data['max_participants'] as num).toInt()
          : 120);

  String get _startDateFormatted {
    final startAt = data['start_at'];
    if (startAt == null) return 'Jan 1, 2026';
    if (startAt is Timestamp) {
      final d = startAt.toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    }
    return 'Jan 1, 2026';
  }

  String get _difficulty =>
      data['difficulty']?.toString() ?? 'Beginner';

  String get _objective =>
      data['objective']?.toString() ??
      'Accumulate 50km total distance in urban zones.';

  int get _prizeAmount => data['prize_amount'] is int
      ? data['prize_amount'] as int
      : (data['prize_amount'] is num
          ? (data['prize_amount'] as num).toInt()
          : 50000);

  List<String> get _conditions {
    final c = data['conditions'];
    if (c is List) return c.map((e) => e.toString()).toList();
    if (c != null) return [c.toString()];
    return [
      'Must use the official app for tracking',
      'GPS tracking must be active all the time',
      'Activities must be completed within the time frame',
    ];
  }

  List<String> get _eligibility {
    final e = data['eligibility'];
    if (e is List) return e.map((e) => e.toString()).toList();
    if (e != null) return [e.toString()];
    return [
      'Age 16 or above',
      'Valid UAE residence',
      'Active challenge zone membership',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    const themeGreen = Color(0xFF00FF88);
    const bgDark = Color(0xFF0D1217);
    const cardDark = Color(0xFF1E2A31);

    final isEnded = !_isActive;

    return Scaffold(
      backgroundColor: bgDark,
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
                    _buildTitleAndStatus(s, themeGreen, isEnded),
                    SizedBox(height: 20 * s),
                    _buildPodium(s, themeGreen),
                    SizedBox(height: 16 * s),
                    _buildDummyLeaderboard(s, themeGreen),
                    SizedBox(height: 10 * s),
                    _buildSeeMore(s),
                    SizedBox(height: 16 * s),
                    _buildAiInsight(s, cardDark),
                    SizedBox(height: 16 * s),
                    _buildSummaryCards(s, cardDark),
                    SizedBox(height: 20 * s),
                    _buildCompetitionDetails(s),
                    SizedBox(height: 20 * s),
                    _buildObjective(s),
                    SizedBox(height: 20 * s),
                    _buildPrize(s, themeGreen),
                    if (_isActive) ...[
                      SizedBox(height: 24 * s),
                      _buildQuitButton(context, s),
                    ],
                    SizedBox(height: 24 * s),
                    _buildGroupChatButton(context, s),
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
              child: Container(
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
                  child: profile?.profileImage != null &&
                          profile!.profileImage!.isNotEmpty
                      ? Image.network(
                          profile.profileImage!,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        )
                      : Image.asset(
                          profile?.gender?.toLowerCase() == 'female'
                              ? 'assets/fonts/female.png'
                              : 'assets/fonts/male.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
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
        final name = auth.profile?.name?.trim() ?? 'USER';
        return Padding(
          padding: EdgeInsets.only(top: 4 * s, bottom: 8 * s),
          child: Text(
            'HI, ${name.toUpperCase()}',
            style: GoogleFonts.outfit(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context, double s) {
    final isNetwork = _imageUrl.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: isNetwork
          ? Image.network(
              _imageUrl,
              width: double.infinity,
              height: 160 * s,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _bannerPlaceholder(s),
            )
          : Image.asset(
              _imageUrl,
              width: double.infinity,
              height: 160 * s,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _bannerPlaceholder(s),
            ),
    );
  }

  Widget _bannerPlaceholder(double s) {
    return Container(
      width: double.infinity,
      height: 160 * s,
      color: const Color(0xFF1E2A31),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, color: Colors.white38, size: 48 * s),
    );
  }

  Widget _buildTitleAndStatus(double s, Color themeGreen, bool isEnded) {
    final statusText = isEnded ? 'Ended' : 'Live';
    final statusColor = isEnded ? const Color(0xFFFF5252) : themeGreen;

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
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            Text(
              statusText,
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPodium(double s, Color themeGreen) {
    return SizedBox(
      height: 200 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _podiumSpot(
            s: s,
            place: 2,
            height: 120 * s,
            name: 'Essa',
            color: const Color(0xFF4FC3F7),
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'nd',
          ),
          _podiumSpot(
            s: s,
            place: 1,
            height: 160 * s,
            name: 'Maryam',
            color: const Color(0xFFFFD700),
            avatarAsset: 'assets/fonts/female.png',
            suffix: 'st',
            isCenter: true,
          ),
          _podiumSpot(
            s: s,
            place: 3,
            height: 100 * s,
            name: 'Khalid',
            color: const Color(0xFFFFB74D),
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'rd',
          ),
        ],
      ),
    );
  }

  Widget _podiumSpot({
    required double s,
    required int place,
    required double height,
    required String name,
    required Color color,
    required String avatarAsset,
    required String suffix,
    bool isCenter = false,
  }) {
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
                    image: AssetImage(avatarAsset),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
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
              border: Border(
                top: BorderSide(color: color, width: 2),
                left: BorderSide(color: color.withValues(alpha: 0.4), width: 1),
                right: BorderSide(color: color.withValues(alpha: 0.4), width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyLeaderboard(double s, Color themeGreen) {
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
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Text(
                    'User Name',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
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
                    '24',
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
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Text(
                  'Your Name',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeeMore(double s) {
    return Center(
      child: Text(
        'See more',
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          color: Colors.white38,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAiInsight(double s, Color cardDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(18 * s),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB161FF).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20 * s,
                color: const Color(0xFF00FF88),
              ),
              SizedBox(width: 10 * s),
              Text(
                'AI INSIGHT',
                style: GoogleFonts.outfit(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00FF88),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Text(
            '"Great cadence! You\'re crushing your pace by 5%. Maintain this rhythm for the next kilometer."',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double s, Color cardDark) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            s,
            cardDark,
            '$_currentParticipants/$_maxParticipants',
            'Participants',
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: _summaryCard(s, cardDark, _startDateFormatted, 'Start Date'),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: _summaryCard(s, cardDark, _difficulty, 'Difficulty'),
        ),
      ],
    );
  }

  Widget _summaryCard(
      double s, Color cardDark, String val, String label) {
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
          _detailLabel(s, 'Conditions:'),
          ..._conditions.map((c) => _bullet(s, c)),
          SizedBox(height: 12 * s),
          _detailLabel(s, 'Eligibility:'),
          ..._eligibility.map((e) => _bullet(s, e)),
        ],
      ),
    );
  }

  Widget _detailLabel(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * s, bottom: 4 * s),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _bullet(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 20 * s, bottom: 2 * s),
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

  Widget _buildObjective(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A31),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
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

  Widget _buildPrize(double s, Color themeGreen) {
    const prizeCardBg = Color(0xFF1B2228);
    final amountStr = _prizeAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: prizeCardBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white12, width: 1),
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
                      border: Border.all(color: themeGreen, width: 1),
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
                    child: _trophyCard(
                      s,
                      prizeCardBg,
                      '1',
                      'Gold',
                      'assets/challenge/challenge_24_gold.png',
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _trophyCard(
                      s,
                      prizeCardBg,
                      '2',
                      'Silver',
                      'assets/challenge/challenge_24_silver.png',
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _trophyCard(
                      s,
                      prizeCardBg,
                      '3',
                      'Bronze',
                      'assets/challenge/challenge_24_bronze.png',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trophyCard(
    double s,
    Color bg,
    String rank,
    String label,
    String asset,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
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
                    shadows: [
                      const Shadow(color: Colors.black, blurRadius: 4),
                    ],
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

  Widget _buildGroupChatButton(BuildContext context, double s) {
    const themeGreen = Color(0xFF00FF88);
    return SizedBox(
      width: double.infinity,
      height: 52 * s,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupChatScreen(roomId: roomId, roomName: _name),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: themeGreen,
          side: BorderSide(color: themeGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * s)),
        ),
        child: Text(
          'Group Chat',
          style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildQuitButton(BuildContext context, double s) {
    return SizedBox(
      width: double.infinity,
      height: 56 * s,
      child: ElevatedButton(
        onPressed: () async {
          final quit = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CompetitionSystemAlertScreen(alertType: AlertType.quit),
            ),
          );
          if (quit == true && context.mounted) {
            final userId = context.read<AuthProvider>().firebaseUser?.uid;
            if (userId != null) {
              await ChallengeService().quitChallengeRoom(
                roomId: roomId,
                userId: userId,
              );
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7E7E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * s),
          ),
        ),
        child: Text(
          'Quit Competition',
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../auth/auth_provider.dart';
import '../../services/challenge_service.dart';
import 'competition_system_alert_screen.dart';
import 'private_zone_rules_screen.dart';

/// Competition view state: not joined (Join Now), joined (Live + Quit), or ended (My Performance + Full Leaderboard / Share).
enum CompetitionViewState { liveNotJoined, liveJoined, ended }

/// Live Competition — banner, podium (challenge-screen accurate), rank list,
/// optional AI insight, summary, details, prize. Join Now / Quit / My Performance + actions by state.
class LiveCompetitionScreen extends StatelessWidget {
  final String roomId;
  final String competitionName;
  final String bannerImage;
  final CompetitionViewState viewState;

  const LiveCompetitionScreen({
    super.key,
    this.roomId = '',
    this.competitionName = 'Red Bull Urban Run 2026',
    this.bannerImage = 'assets/challenge/challenge_24_main_2.png',
    this.viewState = CompetitionViewState.liveJoined,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen = const Color(0xFF00FF88);
    final bgDark = const Color(0xFF0D1217);
    final cardDark = const Color(0xFF1E2A31);
    final listGreen = const Color(0xFF0F1F17);

    final isEnded = viewState == CompetitionViewState.ended;
    final isLiveNotJoined = viewState == CompetitionViewState.liveNotJoined;
    final isLiveJoined = viewState == CompetitionViewState.liveJoined;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(context, s),
            _buildGreeting(s),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10 * s),
                    _buildBanner(context, s, themeGreen, isEnded),
                    SizedBox(height: 16 * s),
                    _buildCompetitionTitleAndStatus(s, themeGreen, isEnded),
                    if (isEnded) ...[
                      SizedBox(height: 20 * s),
                      _buildPodium(s, themeGreen),
                      SizedBox(height: 16 * s),
                      _buildRankList(s, listGreen),
                      SizedBox(height: 10 * s),
                      _buildUserRankRow(s, themeGreen),
                    ],
                    if (isLiveJoined && !isEnded) ...[
                      SizedBox(height: 20 * s),
                      _buildAiInsight(s, cardDark),
                    ],
                    SizedBox(height: 16 * s),
                    _buildSummaryCards(s, cardDark),
                    SizedBox(height: 20 * s),
                    _buildCompetitionDetailsSection(s),
                    if (!isEnded) ...[
                      SizedBox(height: 20 * s),
                      _buildObjectiveBox(s),
                      SizedBox(height: 20 * s),
                      _buildPrize(s, themeGreen),
                    ] else ...[
                      SizedBox(height: 20 * s),
                      _buildPrize(s, themeGreen),
                      SizedBox(height: 20 * s),
                      _buildObjectiveBox(s),
                    ],
                    if (isEnded) ...[
                      SizedBox(height: 20 * s),
                      _buildMyPerformanceBox(s, themeGreen),
                      SizedBox(height: 24 * s),
                      _buildFullLeaderboardAndShareResults(s),
                    ],
                    if (isLiveNotJoined) ...[
                      SizedBox(height: 24 * s),
                      _buildEntryFeeAndJoinNow(context, s, themeGreen),
                    ],
                    if (isLiveJoined) ...[
                      SizedBox(height: 24 * s),
                      _buildQuitButton(context, s),
                    ],
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

  Widget _buildCustomHeader(BuildContext context, double s) {
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
                color: Colors.transparent,
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

  Widget _buildBanner(
    BuildContext context,
    double s,
    Color themeGreen,
    bool isEnded,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: Image.asset(
        bannerImage,
        width: double.infinity,
        height: 160 * s,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCompetitionTitleAndStatus(
    double s,
    Color themeGreen,
    bool isEnded,
  ) {
    final statusText = isEnded ? 'ENDED' : 'Live';
    final statusColor = isEnded ? const Color(0xFFFF5252) : themeGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          competitionName,
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

  /// Podium from challenge screen: 2nd left, 1st center, 3rd right; pedestal heights and medal colors.
  Widget _buildPodium(double s, Color themeGreen) {
    return SizedBox(
      height: 200 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPodiumSpot(
            s: s,
            place: 2,
            height: 120 * s,
            name: 'Eren',
            color: const Color(0xFFC0C0C0),
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'nd',
            themeGreen: themeGreen,
            isLeft: true,
          ),
          _buildPodiumSpot(
            s: s,
            place: 1,
            height: 160 * s,
            name: 'Maryam',
            color: const Color(0xFFFFD700),
            avatarAsset: 'assets/fonts/female.png',
            suffix: 'st',
            themeGreen: themeGreen,
            isCenter: true,
          ),
          _buildPodiumSpot(
            s: s,
            place: 3,
            height: 100 * s,
            name: 'Khalfan',
            color: const Color(0xFFCD7F32),
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'rd',
            themeGreen: themeGreen,
            isRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot({
    required double s,
    required int place,
    required double height,
    required String name,
    required Color color,
    required String avatarAsset,
    required String suffix,
    required Color themeGreen,
    bool isCenter = false,
    bool isLeft = false,
    bool isRight = false,
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
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
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
            height: height - avatarSize,
            decoration: BoxDecoration(
              gradient: isCenter
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.25),
                        color.withValues(alpha: 0.0),
                      ],
                    ),
              color: isCenter ? color : null,
              border: Border(
                top: BorderSide(color: color, width: 2),
                left: isRight
                    ? BorderSide.none
                    : BorderSide(
                        color: color.withValues(alpha: 0.4),
                        width: isCenter ? 0 : 1,
                      ),
                right: isLeft
                    ? BorderSide.none
                    : BorderSide(
                        color: color.withValues(alpha: 0.4),
                        width: isCenter ? 0 : 1,
                      ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 4 * s),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$place',
                      style:
                          GoogleFonts.outfit(
                            fontSize: isCenter ? 32 * s : 24 * s,
                            fontWeight: FontWeight.w800,
                            color: isCenter ? Colors.transparent : color,
                            height: 1,
                          ).copyWith(
                            foreground: isCenter
                                ? (Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2 * s
                                    ..color = const Color(0xFF0D1217))
                                : null,
                          ),
                    ),
                    Text(
                      suffix,
                      style: GoogleFonts.outfit(
                        fontSize: isCenter ? 12 * s : 10 * s,
                        fontWeight: FontWeight.w800,
                        color: isCenter ? const Color(0xFF0D1217) : color,
                        height: 1.5,
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

  Widget _buildRankList(double s, Color listGreen) {
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
                  color: const Color(0xFF00FF88).withValues(alpha: 0.5),
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
                        color: const Color(0xFF00FF88),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Container(
                    width: 28 * s,
                    height: 28 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
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
        SizedBox(height: 4 * s),
        Center(
          child: Text(
            'see more',
            style: GoogleFonts.inter(
              fontSize: 8 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRankRow(double s, Color themeGreen) {
    return Container(
      height: 44 * s,
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF88),
        borderRadius: BorderRadius.circular(22 * s),
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
              image: const DecorationImage(
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
    );
  }

  Widget _buildAiInsight(double s, Color cardDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF13181D),
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(color: Colors.white12, width: 1),
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
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double s, Color cardDark) {
    return Row(
      children: [
        Expanded(child: _summaryCard(s, cardDark, '39/120', 'Participants')),
        SizedBox(width: 8 * s),
        Expanded(child: _summaryCard(s, cardDark, 'Jan 1, 2026', 'Start Date')),
        SizedBox(width: 8 * s),
        Expanded(child: _summaryCard(s, cardDark, 'Beginner', 'Difficulty')),
      ],
    );
  }

  Widget _summaryCard(double s, Color cardDark, String val, String label) {
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
              fontSize: 15 * s,
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

  Widget _buildCompetitionDetailsSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              _bullet(s, 'Must use the official app for tracking'),
              _bullet(s, 'GPS tracking must be active all the time'),
              _bullet(s, 'Activities must be completed within the time frame'),
              SizedBox(height: 12 * s),
              _detailLabel(s, 'Eligibility:'),
              _bullet(s, 'Age 18 or above'),
              _bullet(s, 'Valid UAE residence'),
              _bullet(s, 'Active challenge zone membership'),
            ],
          ),
        ),
      ],
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

  Widget _buildPrize(double s, Color themeGreen) {
    final prizeCardBg = const Color(0xFF1B2228);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prize',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '50,000',
                  style: GoogleFonts.outfit(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6 * s),
                _buildSmallDpIcon(s, themeGreen),
              ],
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          children: [
            Expanded(
              child: _buildTrophyCard(
                s,
                prizeCardBg,
                '1',
                'Gold',
                'assets/challenge/challenge_24_gold.png',
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildTrophyCard(
                s,
                prizeCardBg,
                '2',
                'Silver',
                'assets/challenge/challenge_24_silver.png',
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildTrophyCard(
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
    );
  }

  Widget _buildSmallDpIcon(double s, Color themeGreen) {
    return Container(
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
    );
  }

  Widget _buildTrophyCard(
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

  Widget _buildObjectiveBox(double s) {
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
            'Accumulate 50km total distance in urban zones.',
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

  Widget _buildMyPerformanceBox(double s, Color themeGreen) {
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
                  'top 5%',
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
                        '#14',
                        style: GoogleFonts.outfit(
                          fontSize: 28 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6 * s),
                        child: Text(
                          ' / 1,204',
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
                        '1,250',
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
                child: _buildSmallPerfStat(s, '52.4', 'KM', Icons.linear_scale),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _buildSmallPerfStat(
                  s,
                  '4,200',
                  'Kcal',
                  Icons.fitness_center,
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _buildSmallPerfStat(
                  s,
                  '12',
                  'Sessions',
                  Icons.directions_run,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPerfStat(
    double s,
    String val,
    String label,
    IconData icon,
  ) {
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

  Widget _buildFullLeaderboardAndShareResults(double s) {
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

  Widget _buildEntryFeeAndJoinNow(
    BuildContext context,
    double s,
    Color themeGreen,
  ) {
    return Column(
      children: [
        Text(
          'Entry Fee 500 OP',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 10 * s),
        SizedBox(
          width: double.infinity,
          height: 52 * s,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateZoneRulesScreen(
                    roomId: this.roomId,
                    roomName: this.competitionName,
                    bannerImage: this.bannerImage,
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
                fontSize: 16 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
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
          foregroundColor: Colors.black,
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

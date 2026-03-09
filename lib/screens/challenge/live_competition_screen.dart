import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_system_alert_screen.dart';
import 'private_zone_rules_screen.dart';

/// Competition view state: not joined (Join Now), joined (Live + Quit), or ended (My Performance + Full Leaderboard / Share).
enum CompetitionViewState {
  liveNotJoined,
  liveJoined,
  ended,
}

/// Live Competition — banner, podium (challenge-screen accurate), rank list,
/// optional AI insight, summary, details, prize. Join Now / Quit / My Performance + actions by state.
class LiveCompetitionScreen extends StatelessWidget {
  final String competitionName;
  final String bannerImage;
  final CompetitionViewState viewState;

  const LiveCompetitionScreen({
    super.key,
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
            if (!isEnded) _buildSponsorLogo(s),
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(context, s, themeGreen, isEnded),
                    SizedBox(height: 20 * s),
                    _buildPodium(s, themeGreen),
                    SizedBox(height: 16 * s),
                    _buildRankList(s, listGreen),
                    if (isLiveJoined || isEnded) ...[
                      SizedBox(height: 10 * s),
                      _buildUserRankRow(s, themeGreen),
                    ],
                    if (isLiveJoined) ...[
                      SizedBox(height: 16 * s),
                      _buildAiInsight(s, cardDark),
                    ],
                    SizedBox(height: 16 * s),
                    _buildSummaryCards(s, cardDark),
                    SizedBox(height: 20 * s),
                    _buildCompetitionDetails(s),
                    SizedBox(height: 20 * s),
                    _buildPrize(s, themeGreen),
                    if (isEnded) ...[
                      SizedBox(height: 16 * s),
                      _buildObjectiveBox(s),
                      SizedBox(height: 16 * s),
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

  Widget _buildSponsorLogo(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 8 * s, bottom: 4 * s),
      child: Center(
        child: Text(
          'Red Bull',
          style: GoogleFonts.outfit(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context,
    double s,
    Color themeGreen,
    bool isEnded,
  ) {
    final statusText = isEnded ? 'ENDED' : 'Live';
    final statusColor = isEnded ? const Color(0xFFFF5252) : themeGreen;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: Image.asset(
            bannerImage,
            width: double.infinity,
            height: 160 * s,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * s),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: 14 * s,
          right: 14 * s,
          bottom: 12 * s,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  competitionName,
                  style: GoogleFonts.outfit(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 8),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 5 * s,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEnded)
                      Container(
                        width: 6 * s,
                        height: 6 * s,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!isEnded) SizedBox(width: 5 * s),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      style: GoogleFonts.outfit(
                        fontSize: isCenter ? 32 * s : 24 * s,
                        fontWeight: FontWeight.w800,
                        color: isCenter
                            ? Colors.transparent
                            : color,
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
                        color: isCenter
                            ? const Color(0xFF0D1217)
                            : color,
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
              height: 48 * s,
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              decoration: BoxDecoration(
                color: listGreen,
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                  '${r.toString().padLeft(2, '0')}',
                  style: GoogleFonts.outfit(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                  SizedBox(width: 12 * s),
                  Container(
                    width: 32 * s,
                    height: 32 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/fonts/male.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Text(
                    'User Name',
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserRankRow(double s, Color themeGreen) {
    return Container(
      height: 52 * s,
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      decoration: BoxDecoration(
        color: themeGreen.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: themeGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            '24',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w800,
              color: themeGreen,
            ),
          ),
          SizedBox(width: 10 * s),
          Container(
            width: 34 * s,
            height: 34 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/fonts/male.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Text(
            'Your Name',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16 * s,
              color: const Color(0xFF00FF88),
            ),
            SizedBox(width: 6 * s),
            Text(
              'AI INSIGHT',
              style: GoogleFonts.outfit(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Text(
            '"Great cadence! You\'re crushing your pace by 5%. Maintain this rhythm for the next kilometer."',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double s, Color cardDark) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(s, cardDark, '39/120\nParticipants'),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: _summaryCard(s, cardDark, 'Jan 1, 2026\nStart Date'),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: _summaryCard(s, cardDark, 'Beginner\nDifficulty'),
        ),
      ],
    );
  }

  Widget _summaryCard(double s, Color cardDark, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 8 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildCompetitionDetails(double s) {
    return Column(
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
        SizedBox(height: 8 * s),
        _detailLabel(s, 'Conditions:'),
        _bullet(s, 'Must use the official app for tracking'),
        _bullet(s, 'GPS tracking must be active all the time'),
        _bullet(s, 'Activities must be completed within the time frame'),
        SizedBox(height: 10 * s),
        _detailLabel(s, 'Eligibility:'),
        _bullet(s, 'Age 18 or above'),
        _bullet(s, 'Valid UAE residence'),
        _bullet(s, 'Active challenge zone membership'),
        SizedBox(height: 10 * s),
        _detailLabel(s, 'Objective'),
        Padding(
          padding: EdgeInsets.only(left: 16 * s),
          child: Text(
            'Accumulate 50km total distance in urban zones.',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
              height: 1.4,
            ),
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
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
            ),
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
    return Column(
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
        SizedBox(height: 8 * s),
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
            SizedBox(width: 8 * s),
            Container(
              width: 28 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: themeGreen, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                'OP',
                style: GoogleFonts.outfit(
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w800,
                  color: themeGreen,
                ),
              ),
            ),
            SizedBox(width: 16 * s),
            Image.asset(
              'assets/challenge/challenge_24_gold.png',
              height: 28 * s,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 6 * s),
            Image.asset(
              'assets/challenge/challenge_24_silver.png',
              height: 28 * s,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 6 * s),
            Image.asset(
              'assets/challenge/challenge_24_bronze.png',
              height: 28 * s,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
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
                child: _buildSmallPerfStat(s, '52.4\nKM'),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _buildSmallPerfStat(s, '4,200\nSteps'),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _buildSmallPerfStat(s, '12\nSessions'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPerfStat(double s, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(8 * s),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
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
      height: 52 * s,
      child: ElevatedButton(
        onPressed: () async {
          final quit = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionSystemAlertScreen(
                alertType: AlertType.quit,
              ),
            ),
          );
          if (quit == true && context.mounted) {
            Navigator.pop(context);
          }
        },
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
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

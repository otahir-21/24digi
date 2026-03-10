import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_system_alert_screen.dart';
import 'share_activity_card_screen.dart';

enum CompetitionStatus { upcoming, live, completed }

class CompetitionDetailScreen extends StatelessWidget {
  final CompetitionStatus status;
  final bool hasParticipated;
  final String? customTitle;
  final String? customImage;

  const CompetitionDetailScreen({
    super.key,
    required this.status,
    this.hasParticipated = true,
    this.customTitle,
    this.customImage,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen = const Color(0xFF00FF88);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImage(context, s, themeGreen)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: _buildContent(context, s, themeGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, double s, Color themeGreen) {
    if (status == CompetitionStatus.upcoming) {
      return Column(
        children: [
          SizedBox(height: 16 * s),
          _buildUpcomingStatsRow(s),
          SizedBox(height: 24 * s),
          _buildTextPrizePool(s),
          SizedBox(height: 24 * s),
          _buildUpcomingObjectiveAndRules(s),
          SizedBox(height: 24 * s),
          _buildLocationAndRoute(s),
          SizedBox(height: 24 * s),
          _buildUpcomingParticipants(s),
          SizedBox(height: 32 * s),
          _buildUpcomingEntryFeeBox(context, s, themeGreen),
          SizedBox(height: 48 * s),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(height: 24 * s),
        _buildPodium(s, themeGreen),
        SizedBox(height: 24 * s),
        _buildRankList(s, themeGreen),

        if (hasParticipated) ...[
          SizedBox(height: 16 * s),
          _buildUserRank(s, themeGreen),
        ],

        if (status == CompetitionStatus.live) ...[
          SizedBox(height: 32 * s),
          _buildAiInsight(s, themeGreen),
        ],

        SizedBox(height: 32 * s),
        _buildStatsRow(s),
        SizedBox(height: 24 * s),
        _buildDetailsBox(s),

        if (status == CompetitionStatus.completed) ...[
          SizedBox(height: 16 * s),
          _buildPrizeBox(s, themeGreen),
          SizedBox(height: 16 * s),
          _buildObjectiveBox(s),

          if (hasParticipated) ...[
            SizedBox(height: 16 * s),
            _buildMyPerformanceBox(s, themeGreen),
            SizedBox(height: 32 * s),
            _buildCompletedActionButtons(context, s),
          ],
        ] else ...[
          SizedBox(height: 16 * s),
          _buildObjectiveBox(s),
          SizedBox(height: 16 * s),
          _buildPrizeBox(s, themeGreen),
          SizedBox(height: 32 * s),
          _buildActionButton(
            s,
            'Quit Competition',
            const Color(0xFFFF5252),
            Colors.black,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompetitionSystemAlertScreen(
                    alertType: AlertType.quit,
                  ),
                ),
              );
            },
          ),
        ],
        SizedBox(height: 48 * s),
      ],
    );
  }

  Widget _buildHeaderImage(BuildContext context, double s, Color themeGreen) {
    String title = customTitle ?? 'Red Bull Urban Run 2026';
    String statusText = 'Live';
    Color statusColor = themeGreen;
    String bgImage = customImage ?? 'assets/challenge/challenge_24_main_1.png';

    if (status == CompetitionStatus.upcoming) {
      if (customTitle == null) title = 'Highland Cycle\nChampionship';
      statusText = 'Start in 02:15:45';
      statusColor = Colors.orangeAccent;
      if (customImage == null)
        bgImage = 'assets/challenge/challenge_24_main_4.png';
    } else if (status == CompetitionStatus.completed) {
      statusText = 'ENDED';
      statusColor = const Color(0xFFFF5252);
      if (customImage == null)
        bgImage =
            'assets/challenge/challenge_24_main_7.png'; // Use completed image
    }

    return SizedBox(
      height: 350 * s,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                    const Color(0xFF0D1217),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileTopBar(),
                SizedBox(height: 16 * s),
                Center(
                  child: Text(
                    'HI, USER',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Row(
                        children: [
                          Container(
                            width: 8 * s,
                            height: 8 * s,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.8),
                                  blurRadius: 8 * s,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            statusText,
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24 * s),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPCOMING SPECIFIC WIDGETS ---

  Widget _buildUpcomingStatsRow(double s) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              'Jan 4',
              style: GoogleFonts.outfit(
                fontSize: 18 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            'Date',
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              '20km',
              style: GoogleFonts.outfit(
                fontSize: 18 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            'Distance',
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              'Hard',
              style: GoogleFonts.outfit(
                fontSize: 18 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            'Difficulty',
          ),
        ),
      ],
    );
  }

  Widget _buildTextPrizePool(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prize pool',
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),
          _buildTextPrizeRow(
            s,
            '1st Place',
            'Champion Gold Medal',
            '2,500 Pts',
          ),
          SizedBox(height: 12 * s),
          Divider(color: Colors.white12, height: 1),
          SizedBox(height: 12 * s),
          _buildTextPrizeRow(s, '2nd Place', 'Silver Medal', '1,000 Pts'),
          SizedBox(height: 12 * s),
          Divider(color: Colors.white12, height: 1),
          SizedBox(height: 12 * s),
          _buildTextPrizeRow(s, '3rd Place', 'Bronze Medal', '500 Pts'),
        ],
      ),
    );
  }

  Widget _buildTextPrizeRow(
    double s,
    String place,
    String subtitle,
    String reward,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
            ),
          ],
        ),
        Text(
          reward,
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingObjectiveAndRules(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objective & Rules',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16 * s),
        _buildBulletText(
          s,
          'Complete the 20km highland track within the allocated time limit of 2 hours.',
        ),
        _buildBulletText(
          s,
          'Maintain an average speed of at least 15km/h to qualify for ranked points.',
        ),
        _buildBulletText(
          s,
          'GPS tracking must be enabled throughout the duration of the event.',
        ),
        SizedBox(height: 24 * s),
        Text(
          'Eligibility:',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12 * s),
        _buildBulletText(s, 'Age 18 or above'),
        _buildBulletText(s, 'Valid UAE residence'),
        _buildBulletText(s, 'Active challenge zone membership'),
      ],
    );
  }

  Widget _buildLocationAndRoute(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location & Route',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'View Full Map',
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                color: Colors.white54,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: Image.asset(
            'assets/challenge/challenge_map.png',
            width: double.infinity,
            height: 120 * s,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingParticipants(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '128 interested',
              style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2228),
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70 * s,
                height: 32 * s,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildAvatarCircle(s, const Color(0xFF42A5F5)),
                    ),
                    Positioned(
                      left: 20 * s,
                      child: _buildAvatarCircle(s, const Color(0xFFFFB061)),
                    ),
                    Positioned(
                      left: 40 * s,
                      child: _buildAvatarCircle(s, const Color(0xFFFF5252)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
              Text(
                'Friends are interested',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle(double s, Color borderColor) {
    return Container(
      width: 32 * s,
      height: 32 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
        border: Border.all(color: const Color(0xFF1B2228), width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/fonts/male.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUpcomingEntryFeeBox(
    BuildContext context,
    double s,
    Color themeGreen,
  ) {
    final cyanButton = const Color(0xFF00E5FF);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENTRY FEE',
                    style: GoogleFonts.inter(
                      fontSize: 9 * s,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Row(
                    children: [
                      Text(
                        '500',
                        style: GoogleFonts.outfit(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Container(
                        width: 16 * s,
                        height: 16 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cyanButton),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'DP',
                          style: GoogleFonts.outfit(
                            fontSize: 6 * s,
                            fontWeight: FontWeight.bold,
                            color: cyanButton,
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
                    'YOUR BALANCE',
                    style: GoogleFonts.inter(
                      fontSize: 9 * s,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Row(
                    children: [
                      Text(
                        '1,200',
                        style: GoogleFonts.outfit(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Container(
                        width: 16 * s,
                        height: 16 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cyanButton),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'DP',
                          style: GoogleFonts.outfit(
                            fontSize: 6 * s,
                            fontWeight: FontWeight.bold,
                            color: cyanButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          _buildActionButton(s, 'NOTIFY ME', cyanButton, Colors.black, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionSystemAlertScreen(
                  alertType: AlertType.notify,
                  competitionName: customTitle ?? 'Highland Cycle Championship',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- LIVE & COMPLETED SHARED WIDGETS ---

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
            name: 'Essa',
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
                  color: Colors.grey.withOpacity(0.2),
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
                      colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
                    ),
              color: isCenter ? color : null,
              border: Border(
                top: BorderSide(color: color, width: 2),
                left: isRight
                    ? BorderSide.none
                    : BorderSide(
                        color: color.withOpacity(0.4),
                        width: isCenter ? 0 : 1,
                      ),
                right: isLeft
                    ? BorderSide.none
                    : BorderSide(
                        color: color.withOpacity(0.4),
                        width: isCenter ? 0 : 1,
                      ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 4 * s),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (!isCenter)
                      Positioned(
                        bottom: 4 * s,
                        left: 12 * s,
                        right: 12 * s,
                        child: Container(height: 1 * s, color: color),
                      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankList(double s, Color themeGreen) {
    return Column(
      children: [
        for (int i = 4; i <= 10; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: _buildRankItem(
              s,
              i.toString().padLeft(2, '0'),
              'User Name',
              false,
              themeGreen,
            ),
          ),
        SizedBox(height: 8 * s),
        Text(
          'see more',
          style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildUserRank(double s, Color themeGreen) {
    return _buildRankItem(s, '24', 'Your Name', true, themeGreen);
  }

  Widget _buildRankItem(
    double s,
    String rank,
    String name,
    bool isUser,
    Color themeGreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: isUser ? themeGreen : const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: isUser ? null : Border.all(color: themeGreen, width: 1.5),
        boxShadow: isUser
            ? [
                BoxShadow(
                  color: themeGreen.withOpacity(0.3),
                  blurRadius: 10 * s,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24 * s,
            child: Text(
              rank,
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: isUser ? Colors.black : Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Container(
            width: 20 * s,
            height: 20 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: const DecorationImage(
                image: AssetImage('assets/fonts/male.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: isUser ? Colors.black : themeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsight(double s, Color themeGreen) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * s),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1C2D3A), const Color(0xFF0F141A)],
        ),
        border: Border.all(color: themeGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.1),
            blurRadius: 16 * s,
            spreadRadius: 2 * s,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: themeGreen, size: 16 * s),
              SizedBox(width: 8 * s),
              Text(
                'AI INSIGHT',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Text(
            '"Great cadence! You\'re crushing\nyour pace by 5%. Maintain this\nrhythm for the next kilometer."',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double s) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            s,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '39',
                    style: GoogleFonts.outfit(
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '/120',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            'Participants',
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              'Jan 1, 2026',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            'Start Date',
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              'Beginner',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            'Difficulty',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(double s, Widget valueWidget, String label) {
    return Container(
      height: 72 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          valueWidget,
          SizedBox(height: 6 * s),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
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
          SizedBox(height: 16 * s),
          Text(
            'Conditions:',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * s),
          _buildBulletText(s, 'Must use the official app for tracking'),
          _buildBulletText(s, 'GPS tracking must be active all the time'),
          _buildBulletText(
            s,
            'Activities must be completed within the time frame',
          ),
          SizedBox(height: 16 * s),
          Text(
            'Eligibility:',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * s),
          _buildBulletText(s, 'Age 18 or above'),
          _buildBulletText(s, 'Valid UAE residence'),
          _buildBulletText(s, 'Active challenge zone membership'),
        ],
      ),
    );
  }

  Widget _buildBulletText(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white70),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveBox(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objective',
            style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Accumulate 50km total distance in\nurban zones.',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeBox(double s, Color themeGreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prize',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
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
                  Container(
                    width: 24 * s,
                    height: 24 * s,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0D1217),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'DP',
                      style: GoogleFonts.outfit(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.bold,
                        color: themeGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrophyCol(
                s,
                'assets/challenge/challenge_24_gold.png',
                'Gold',
                const Color(0xFFFFD700),
              ),
              _buildTrophyCol(
                s,
                'assets/challenge/challenge_24_silver.png',
                'Silver',
                const Color(0xFFC0C0C0),
              ),
              _buildTrophyCol(
                s,
                'assets/challenge/challenge_24_bronze.png',
                'Bronze',
                const Color(0xFFCD7F32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyCol(double s, String asset, String label, Color color) {
    return Column(
      children: [
        Image.asset(asset, height: 80 * s),
        SizedBox(height: 12 * s),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
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
              Expanded(child: _buildSmallPerfStat(s, '52.4\nKM')),
              SizedBox(width: 8 * s),
              Expanded(child: _buildSmallPerfStat(s, '4,200\nKcal')),
              SizedBox(width: 8 * s),
              Expanded(child: _buildSmallPerfStat(s, '12\nSessions')),
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

  Widget _buildCompletedActionButtons(BuildContext context, double s) {
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShareActivityCardScreen(roomName: 'Competition Results'),
                ),
              );
            },
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
        ),
      ],
    );
  }

  Widget _buildActionButton(
    double s,
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

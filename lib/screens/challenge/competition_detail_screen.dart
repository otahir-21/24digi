import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kivi_24/screens/challenge/share_activity_card_screen.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../services/challenge_service.dart';
import '../../services/wallet_service.dart';
import 'competition_system_alert_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart' as app_auth;

enum CompetitionStatus { upcoming, live, completed }

class CompetitionDetailScreen extends StatefulWidget {
  final CompetitionStatus status;
  final String? competitionId;
  final bool hasParticipated;
  final String? customTitle;
  final String? customImage;

  const CompetitionDetailScreen({
    super.key,
    required this.status,
    this.competitionId,
    this.hasParticipated = false,
    this.customTitle,
    this.customImage,
  });

  @override
  State<CompetitionDetailScreen> createState() =>
      _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final Color themeGreen = const Color(0xFF00FF88);
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _leaderboardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.competitionId == null) {
      return _buildStaticLayout(context);
    }

    final auth = context.watch<app_auth.AuthProvider>();
    final userId = auth.firebaseUser?.uid ?? "anonymous";
    final userName = auth.profile?.name ?? "User";

    return StreamBuilder<DocumentSnapshot>(
      stream: _challengeService.getCompetitionStream(widget.competitionId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1217),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF5CE1E6)),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildStaticLayout(context);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Competition';

        return StreamBuilder<DocumentSnapshot>(
          stream: _challengeService.getUserEnrollmentStream(title, userId),
          builder: (context, partSnapshot) {
            final isJoined = partSnapshot.hasData && partSnapshot.data!.exists;
            return _buildDynamicLayout(
              context,
              data,
              isJoined,
              userId,
              userName,
            );
          },
        );
      },
    );
  }

  Widget _buildDynamicLayout(
    BuildContext context,
    Map<String, dynamic> data,
    bool isJoined,
    String userId,
    String userName,
  ) {
    final s = AppConstants.scale(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderImageDynamic(
              context,
              s,
              themeGreen,
              data,
              userName,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: _buildContentDynamic(
                context,
                s,
                themeGreen,
                data,
                isJoined,
                userId,
                userName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticLayout(BuildContext context) {
    final s = AppConstants.scale(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderImageStatic(context, s, themeGreen),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: _buildContentStatic(context, s, themeGreen),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Layout Helpers ---

  Widget _buildHeaderImageDynamic(
    BuildContext context,
    double s,
    Color themeGreen,
    Map<String, dynamic> data,
    String userName,
  ) {
    final title = data['title'] ?? 'Competition';
    final statusStr = data['status'] ?? 'UPCOMING';
    final bgImage =
        data['bg_image'] ??
        data['cover_image'] ??
        'assets/challenge/challenge_24_main_1.png';

    String statusText = 'Live';
    Color statusColor = themeGreen;

    if (statusStr == 'UPCOMING') {
      final startAt = (data['start_at'] as Timestamp?)?.toDate();
      statusText = _formatCountdown(startAt);
      statusColor = Colors.orangeAccent;
    } else if (statusStr == 'COMPLETED') {
      statusText = 'ENDED';
      statusColor = const Color(0xFFFF5252);
    }

    return SizedBox(
      height: 350 * s,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: bgImage.startsWith('http')
                ? Image.network(bgImage, fit: BoxFit.cover)
                : Image.asset(bgImage, fit: BoxFit.cover),
          ),
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
                    'HI, ${userName.toUpperCase()}',
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

  String _formatCountdown(DateTime? target) {
    if (target == null) return 'Soon';
    final now = DateTime.now();
    final diff = target.difference(now);
    if (diff.isNegative) return 'Live';

    final d = diff.inDays;
    final h = (diff.inHours % 24).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final se = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (d > 0) return 'Start in ${d}d ${h}h';
    return 'Start in $h:$m:$se';
  }

  Widget _buildContentDynamic(
    BuildContext context,
    double s,
    Color themeGreen,
    Map<String, dynamic> data,
    bool isJoined,
    String userId,
    String userName,
  ) {
    final statusStr = data['status'] ?? 'UPCOMING';
    final competitionId = widget.competitionId!;
    final title = data['title'] ?? 'Competition';

    if (statusStr == 'UPCOMING') {
      return Column(
        children: [
          SizedBox(height: 16 * s),
          _buildUpcomingStatsRowDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildPrizePoolDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildObjectiveDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildLocationAndRouteDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildParticipantsDynamic(s, data),
          SizedBox(height: 32 * s),
          if (isJoined)
            _buildActionButton(
              s,
              'NOTIFIED',
              themeGreen.withOpacity(0.2),
              themeGreen,
              () {},
            )
          else
            _buildJoinOrNotifyBox(
              context: context,
              s: s,
              themeGreen: themeGreen,
              data: data,
              isNotify: true,
              userId: userId,
              competitionId: competitionId,
              onTap: () => _onToggleNotify(data, userId),
            ),
          SizedBox(height: 48 * s),
        ],
      );
    }

    final bool isLive = statusStr == 'ACTIVE';

    return StreamBuilder<QuerySnapshot>(
      stream: _challengeService.getParticipantsStream(title),
      builder: (context, partSnapshot) {
        final participants = partSnapshot.data?.docs ?? [];
        // Let's find index
        int myRank = -1;
        Map<String, dynamic>? myData;
        for (int i = 0; i < participants.length; i++) {
          final pd = participants[i].data() as Map<String, dynamic>;
          if (pd['userId'] == userId || participants[i].id == userId) {
            myRank = i + 1;
            myData = pd;
            break;
          }
        }

        return Column(
          children: [
            if (isLive) ...[_buildAIInsightBox(s), SizedBox(height: 24 * s)],

            _buildPodiumDynamic(s, themeGreen, participants),
            SizedBox(height: 24 * s),

            Text(
              'Leaderboard',
              key: _leaderboardKey,
              style: GoogleFonts.outfit(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16 * s),
            if (!isLive) ...[
              _buildRankListDynamic(s, themeGreen, participants, userId),
              SizedBox(height: 32 * s),
            ],
            _buildUpcomingStatsRowDynamic(s, data),
            SizedBox(height: 24 * s),

            _buildExpandableBox(
              s,
              'Competition Details',
              data['description'] ??
                  'Overall statistics and performance breakdown.',
            ),
            SizedBox(height: 16 * s),
            _buildObjectiveDynamic(s, data),
            SizedBox(height: 16 * s),
            _buildPrizePoolDynamic(s, data),

            if (isJoined) ...[
              SizedBox(height: 32 * s),
              _buildMyPerformanceSection(
                s,
                myRank,
                myData,
                participants.length,
              ),
            ],

            if (isLive) ...[
              SizedBox(height: 32 * s),
              if (!isJoined)
                _buildJoinOrNotifyBox(
                  context: context,
                  s: s,
                  themeGreen: themeGreen,
                  data: data,
                  isNotify: false,
                  userId: userId,
                  competitionId: competitionId,
                  onTap: () => _onJoin(data, userId),
                ),
              if (isJoined) ...[
                SizedBox(height: 16 * s),
                _buildActionButton(
                  s,
                  'Quit Competition',
                  const Color(0xFFFF5252).withOpacity(0.2),
                  const Color(0xFFFF5252),
                  () => _onQuit(data, userId),
                ),
              ],
            ],

            // Final buttons at bottom
            if (!isLive) ...[
              SizedBox(height: 48 * s),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      s,
                      'Full Leaderboard',
                      const Color(0xFF1B2228),
                      Colors.white,
                      _scrollToLeaderboard,
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _buildActionButton(
                      s,
                      'Share Results',
                      themeGreen,
                      Colors.black,
                      () => _onShare(data, myData, userName),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 48 * s),
          ],
        );
      },
    );
  }

  dynamic docsShim() => null;

  Widget _buildAIInsightBox(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeGreen.withOpacity(0.15),
            Colors.blueAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: themeGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: themeGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: themeGreen, size: 24 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
                    color: themeGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'You are doing great! Maintain this pace to reach Top 10 in next 15 mins.',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPerformanceSection(
    double s,
    int rank,
    Map<String, dynamic>? data,
    int totalParticipants,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(24 * s),
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
                  fontSize: 14 * s,
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
                  'Top 5%',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Final Rank',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: rank > 0 ? '#$rank' : '--',
                          style: GoogleFonts.outfit(
                            fontSize: 32 * s,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' / $totalParticipants',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Score',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${data?['score'] ?? 0}',
                          style: GoogleFonts.outfit(
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w800,
                            color: themeGreen,
                          ),
                        ),
                        TextSpan(
                          text: ' pts',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            color: themeGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatBox(
                  s,
                  '${data?['distance_km'] ?? 52.4}',
                  'KM',
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: _buildMiniStatBox(
                  s,
                  '${data?['calories'] ?? 4200}',
                  'Kcal',
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: _buildMiniStatBox(
                  s,
                  '${data?['sessions'] ?? 12}',
                  'Sessions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox(double s, String value, String unit) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Component Builders (Improved) ---

  Widget _buildUpcomingStatsRowDynamic(double s, Map<String, dynamic> data) {
    final startAt = (data['start_at'] as Timestamp?)?.toDate();
    final dateStr = startAt != null
        ? DateFormat('MMM d').format(startAt)
        : '--';
    final distance = '${data['distance_km'] ?? 0}km';
    final difficulty = data['difficulty'] ?? 'Medium';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            s,
            Text(
              dateStr,
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
              distance,
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
              difficulty,
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

  Widget _buildPrizePoolDynamic(double s, Map<String, dynamic> data) {
    final pool = data['prize_pool'] as Map<String, dynamic>?;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prize Pool & Rewards',
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20 * s),
          _buildRichPrizeRow(
            s,
            '1st Place',
            pool?['1st_label'] ?? 'Champion Gold Medal',
            pool?['1st'] ?? '0 Pts',
            'assets/challenge/gold.png',
            const Color(0xFFFFD700),
          ),
          SizedBox(height: 16 * s),
          _buildRichPrizeRow(
            s,
            '2nd Place',
            pool?['2nd_label'] ?? 'Silver Runner Up',
            pool?['2nd'] ?? '0 Pts',
            'assets/challenge/silver.png',
            const Color(0xFFC0C0C0),
          ),
          SizedBox(height: 16 * s),
          _buildRichPrizeRow(
            s,
            '3rd Place',
            pool?['3rd_label'] ?? 'Bronze Finalist',
            pool?['3rd'] ?? '0 Pts',
            'assets/challenge/bronze.png',
            const Color(0xFFCD7F32),
          ),
        ],
      ),
    );
  }

  Widget _buildRichPrizeRow(
    double s,
    String place,
    String subtitle,
    String reward,
    String asset,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 44 * s,
          height: 44 * s,
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12 * s),
          ),
          child: Image.asset(
            asset,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.emoji_events, color: color, size: 24 * s),
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
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
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Text(
          reward,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w800,
            color: themeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildObjectiveDynamic(double s, Map<String, dynamic> data) {
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
          data['objective'] ??
              data['description'] ??
              'Complete the track within the time limit.',
        ),
        _buildBulletText(
          s,
          data['rules'] ?? 'Ensure GPS tracking is active at all times.',
        ),
      ],
    );
  }

  Widget _buildBulletText(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: themeGreen, fontSize: 14 * s),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndRouteDynamic(double s, Map<String, dynamic> data) {
    final location = data['location'] ?? 'TBD';
    final mapImg = data['map_image'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              location,
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
          child: Container(
            height: 120 * s,
            color: Colors.white10,
            child:
                mapImg != null && mapImg.isNotEmpty && mapImg.startsWith('http')
                ? Image.network(
                    mapImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : const Center(
                    child: Icon(Icons.map, color: Colors.white24, size: 40),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsDynamic(double s, Map<String, dynamic> data) {
    final count = data['interested_count'] ?? 0;
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
              '$count interested',
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
                'Many are interested',
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

  Widget _buildAvatarCircle(double s, Color color) {
    return Container(
      width: 32 * s,
      height: 32 * s,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1B2228), width: 2 * s),
      ),
    );
  }

  Widget _buildPodiumDynamic(
    double s,
    Color themeGreen,
    List<QueryDocumentSnapshot> participants,
  ) {
    if (participants.isEmpty) {
      return Container(
        height: 260 * s,
        child: Center(
          child: Text(
            'No active participants yet',
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        ),
      );
    }
    final p1 = participants.length > 0
        ? (participants[0].data() as Map<String, dynamic>)
        : null;
    final p2 = participants.length > 1
        ? (participants[1].data() as Map<String, dynamic>)
        : null;
    final p3 = participants.length > 2
        ? (participants[2].data() as Map<String, dynamic>)
        : null;

    return Container(
      height: 320 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildPodiumSpot(
              s: s,
              place: 2,
              height: 70 * s,
              name: p2?['display_name'] ?? 'Essa',
              avatar: p2?['avatar_url'] ?? 'assets/fonts/male.png',
              color: const Color(0xFFC0C0C0),
              label: '2nd',
            ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: _buildPodiumSpot(
              s: s,
              place: 1,
              height: 120 * s,
              name: p1?['display_name'] ?? 'Maryam',
              avatar: p1?['avatar_url'] ?? 'assets/fonts/male.png',
              color: const Color(0xFFFFD700),
              label: '1st',
            ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: _buildPodiumSpot(
              s: s,
              place: 3,
              height: 40 * s,
              name: p3?['display_name'] ?? 'Khalfan',
              avatar: p3?['avatar_url'] ?? 'assets/fonts/male.png',
              color: const Color(0xFFCD7F32),
              label: '3rd',
            ),
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
    required String avatar,
    required Color color,
    required String label,
  }) {
    final avatarSize = (place == 1 ? 100 : 80) * s;
    final labelSize = (place == 1 ? 24 : 18) * s;
    final rankSize = (place == 1 ? 40 : 32) * s;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar with border
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3 * s),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 15 * s,
                spreadRadius: 2 * s,
              ),
            ],
          ),
          child: ClipOval(
            child: avatar.startsWith('http')
                ? Image.network(avatar, fit: BoxFit.cover)
                : Image.asset(avatar, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 8 * s),
        // Name Label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15 * s),
          ),
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 4 * s),
        // Rank Text (1st, 2nd, 3rd)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label.substring(0, 1),
                style: GoogleFonts.outfit(
                  fontSize: rankSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              TextSpan(
                text: label.substring(1),
                style: GoogleFonts.outfit(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * s),
        // Pillar
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8 * s)),
          ),
        ),
      ],
    );
  }

  void _scrollToLeaderboard() {
    Scrollable.ensureVisible(
      _leaderboardKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onShare(
    Map<String, dynamic> data,
    Map<String, dynamic>? myData,
    String userName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareActivityCardScreen(
          roomName: data['title'] ?? 'Competition',
          distance:
              '${myData?['distance_km'] ?? data['distance_km'] ?? '0'} km',
          time: myData?['time_elapsed'] ?? myData?['duration'] ?? '0 m',
          imageUrl: data['bg_image'] ?? data['cover_image'],
          userName: userName,
          date: data['completed_at'] != null
              ? DateFormat(
                  'MMM dd, yyyy',
                ).format((data['completed_at'] as Timestamp).toDate())
              : null,
        ),
      ),
    );
  }

  Widget _buildRankListDynamic(
    double s,
    Color themeGreen,
    List<QueryDocumentSnapshot> participants,
    String userId,
  ) {
    if (participants.isEmpty) return const SizedBox();

    // Ranks 1, 2, 3 are in podium
    final listParticipants = participants.length > 3
        ? participants.sublist(3)
        : <QueryDocumentSnapshot>[];

    // Limits ranks shown to top 10 (which means index 3 to 9 in original list)
    final topRanksForList = listParticipants.length > 7
        ? listParticipants.sublist(0, 7)
        : listParticipants;

    // Find if current user is in participants but not in top 10
    int myGlobalIndex = -1;
    Map<String, dynamic>? myData;
    for (int i = 0; i < participants.length; i++) {
      final d = participants[i].data() as Map<String, dynamic>;
      if (d['userId'] == userId || participants[i].id == userId) {
        myGlobalIndex = i;
        myData = d;
        break;
      }
    }

    final bool meIsInTop10 = myGlobalIndex >= 0 && myGlobalIndex < 10;

    return Column(
      children: [
        ...topRanksForList.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final index = participants.indexOf(doc) + 1;
          final isMe = d['userId'] == userId || doc.id == userId;
          return _buildRankItem(
            s,
            index,
            d['display_name'] ?? 'User',
            d['time_elapsed'] ?? '--',
            isMe: isMe,
            avatar: d['avatar_url'] ?? '',
          );
        }).toList(),

        if (listParticipants.length > 7) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            child: Text(
              'SEE MORE',
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white24,
                letterSpacing: 2,
              ),
            ),
          ),
        ],

        // If Me is not in top 10, show a special bar at bottom
        if (!meIsInTop10 && myData != null) ...[
          _buildRankItem(
            s,
            myGlobalIndex + 1,
            myData['display_name'] ?? 'Your Name',
            myData['time_elapsed'] ?? '--',
            isMe: true,
            isSticky: true,
            avatar: myData['avatar_url'] ?? '',
          ),
        ],
      ],
    );
  }

  Widget _buildRankItem(
    double s,
    int rank,
    String name,
    String time, {
    bool isMe = false,
    bool isSticky = false,
    String avatar = '',
  }) {
    final rankStr = rank.toString().padLeft(2, '0');
    final Color bgColor = isMe && isSticky
        ? themeGreen
        : const Color(0xFF1B2228);
    final Color textColor = isMe && isSticky ? Colors.black : Colors.white;
    final Color rankBoxColor = isMe && isSticky
        ? Colors.black.withOpacity(0.1)
        : themeGreen;
    final Color rankTextColor = isMe && isSticky ? Colors.black : Colors.black;

    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: themeGreen, width: 1.5 * s),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.2),
            blurRadius: 8 * s,
            spreadRadius: 1 * s,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              color: rankBoxColor,
              borderRadius: BorderRadius.circular(6 * s),
            ),
            child: Text(
              rankStr,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w900,
                color: rankTextColor,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          // Avatar
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? (avatar.startsWith('http')
                        ? Image.network(avatar, fit: BoxFit.cover)
                        : Image.asset(avatar, fit: BoxFit.cover))
                  : Icon(
                      Icons.person,
                      size: 16 * s,
                      color: textColor.withOpacity(0.54),
                    ),
            ),
          ),
          SizedBox(width: 12 * s),
          // Name
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          // Time/Value (Optional)
          if (!isSticky)
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: textColor.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(double s, Widget value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        children: [
          value,
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableBox(double s, String title, String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
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
                title,
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: 20 * s,
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinOrNotifyBox({
    required BuildContext context,
    required double s,
    required Color themeGreen,
    Map<String, dynamic>? data,
    bool isNotify = true,
    required String userId,
    required String competitionId,
    VoidCallback? onTap,
  }) {
    final cyanButton = const Color(0xFF00E5FF);
    final entryFee = data?['entry_fee'] ?? 0;

    return StreamBuilder<bool>(
      stream: _challengeService.isUserNotifiedStream(competitionId, userId),
      builder: (context, notifySnapshot) {
        final bool isAlreadyNotified = notifySnapshot.data ?? false;
        final btnText = isNotify
            ? (isAlreadyNotified ? 'STOP NOTIFY' : 'NOTIFY ME')
            : 'JOIN NOW';

        return StreamBuilder<DocumentSnapshot>(
          stream: WalletService().getBalanceStream(userId),
          builder: (context, balanceSnapshot) {
            final balData =
                balanceSnapshot.data?.data() as Map<String, dynamic>?;
            final balance = balData?['points'] ?? 0;

            return Container(
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2228),
                borderRadius: BorderRadius.circular(16 * s),
                border: Border.all(color: Colors.white12),
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
                                '$entryFee',
                                style: GoogleFonts.outfit(
                                  fontSize: 16 * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4 * s),
                              Image.asset(
                                'assets/profile/profile_digi_point.png',
                                width: 24 * s,
                                height: 24 * s,
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
                                '$balance',
                                style: GoogleFonts.outfit(
                                  fontSize: 16 * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4 * s),
                              Image.asset(
                                'assets/profile/profile_digi_point.png',
                                width: 24 * s,
                                height: 24 * s,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * s),
                  _buildActionButton(
                    s,
                    btnText,
                    isAlreadyNotified ? Colors.white12 : cyanButton,
                    isAlreadyNotified ? Colors.white : Colors.black,
                    onTap ?? () {},
                  ),
                ],
              ),
            );
          },
        );
      },
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
        height: 50 * s,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25 * s),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // --- Handlers & Messaging ---

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final s = AppConstants.scale(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          margin: EdgeInsets.only(bottom: 20 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: isError
                ? const Color(0xFFFF5252).withOpacity(0.9)
                : const Color(0xFF1B2228).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: isError ? Colors.white38 : themeGreen.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 22 * s,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onToggleNotify(Map<String, dynamic> data, String userId) async {
    try {
      final added = await _challengeService.toggleNotification(
        competitionId: widget.competitionId!,
        userId: userId,
      );
      if (mounted) {
        if (added) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompetitionSystemAlertScreen(
                alertType: AlertType.notify,
                competitionName: data['title'],
              ),
            ),
          );
        } else {
          _showCustomSnackBar(context, 'Notifications turned off');
        }
      }
    } catch (e) {
      if (mounted) _showCustomSnackBar(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _onJoin(Map<String, dynamic> data, String userId) async {
    if (widget.competitionId == null) {
      _showCustomSnackBar(context, 'Invalid Competition ID', isError: true);
      return;
    }

    final auth = context.read<app_auth.AuthProvider>();
    final p = auth.profile;

    try {
      await _challengeService.joinCompetition(
        competitionId: widget.competitionId!,
        competitionTitle: data['title'] ?? 'Competition',
        userId: userId,
        displayName: p?.name ?? "User",
        avatarUrl: p?.profileImage ?? "assets/fonts/male.png",
        gender: p?.gender ?? "male",
        joiningFee: data['entry_fee'] ?? 0,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionSystemAlertScreen(
              alertType: AlertType.join_success,
              competitionName: data['title'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(context, 'Join failed: $e', isError: true);
      }
    }
  }

  Future<void> _onQuit(Map<String, dynamic> data, String userId) async {
    final confirm = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CompetitionSystemAlertScreen(alertType: AlertType.quit),
      ),
    );
    if (confirm == true) {
      try {
        await _challengeService.quitCompetition(
          competitionId: widget.competitionId!,
          competitionTitle: data['title'] ?? 'Competition',
          userId: userId,
        );
        if (mounted) _showCustomSnackBar(context, 'Left the competition');
      } catch (e) {
        if (mounted)
          _showCustomSnackBar(context, 'Quit failed: $e', isError: true);
      }
    }
  }

  // --- Static Layout Logic ---

  Widget _buildHeaderImageStatic(
    BuildContext context,
    double s,
    Color themeGreen,
  ) {
    return _buildHeaderImageDynamic(context, s, themeGreen, {
      'title': widget.customTitle ?? 'Sample Competition',
      'status': widget.status == CompetitionStatus.upcoming
          ? 'UPCOMING'
          : (widget.status == CompetitionStatus.live ? 'ACTIVE' : 'COMPLETED'),
    }, 'USER');
  }

  Widget _buildContentStatic(BuildContext context, double s, Color themeGreen) {
    return _buildContentDynamic(
      context,
      s,
      themeGreen,
      {
        'title': 'Sample Competition',
        'status': widget.status == CompetitionStatus.upcoming
            ? 'UPCOMING'
            : (widget.status == CompetitionStatus.live
                  ? 'ACTIVE'
                  : 'COMPLETED'),
        'entry_fee': 500,
        'distance_km': 10,
      },
      false,
      'anon',
      'USER',
    );
  }
}

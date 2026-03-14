import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  State<CompetitionDetailScreen> createState() => _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final Color themeGreen = const Color(0xFF00FF88);

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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildStaticLayout(context);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        
        // Secondary stream for participation status
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('competitions')
              .doc(widget.competitionId!)
              .collection('participants')
              .doc(userId)
              .snapshots(),
          builder: (context, partSnapshot) {
            final isJoined = partSnapshot.hasData && partSnapshot.data!.exists;
            return _buildDynamicLayout(context, data, isJoined, userId, userName);
          },
        );
      },
    );
  }

  Widget _buildDynamicLayout(BuildContext context, Map<String, dynamic> data, bool isJoined, String userId, String userName) {
    final s = AppConstants.scale(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImageDynamic(context, s, themeGreen, data, userName)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: _buildContentDynamic(context, s, themeGreen, data, isJoined, userId, userName),
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
          SliverToBoxAdapter(child: _buildHeaderImage(context, s, themeGreen)),
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

  Widget _buildHeaderImageDynamic(BuildContext context, double s, Color themeGreen, Map<String, dynamic> data, String userName) {
    final title = data['title'] ?? 'Competition';
    final statusStr = data['status'] ?? 'UPCOMING';
    final bgImage = data['bg_image'] ?? data['cover_image'] ?? 'assets/challenge/challenge_24_main_1.png';
    
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
          Positioned(
            top: 40 * s,
            left: 16 * s,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8 * s),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(DateTime? target) {
    if (target == null) return 'Soon';
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return 'Starting...';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final se = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return 'Start in $h:$m:$se';
  }

  Widget _buildContentDynamic(BuildContext context, double s, Color themeGreen, Map<String, dynamic> data, bool isJoined, String userId, String userName) {
    final statusStr = data['status'] ?? 'UPCOMING';
    final competitionId = widget.competitionId!;
    
    if (statusStr == 'UPCOMING') {
      return Column(
        children: [
          SizedBox(height: 16 * s),
          _buildUpcomingStatsRowDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildTextPrizePoolDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildUpcomingObjectiveAndRulesDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildLocationAndRouteDynamic(s, data),
          SizedBox(height: 24 * s),
          _buildUpcomingParticipantsDynamic(s, data),
          SizedBox(height: 32 * s),
          if (!isJoined)
            _buildUpcomingEntryFeeBox(
              context: context, 
              s: s, 
              themeGreen: themeGreen, 
              data: data, 
              isNotify: true,
              userId: userId,
              competitionId: competitionId,
              onTap: () => _onToggleNotify(data, userId),
            ),
          if (isJoined)
            _buildActionButton(s, 'JOINED', themeGreen.withOpacity(0.2), themeGreen, () {}),
          SizedBox(height: 48 * s),
        ],
      );
    }

    final bool isLive = statusStr == 'ACTIVE';

    return Column(
      children: [
        SizedBox(height: 24 * s),
        _buildPodium(s, themeGreen),
        SizedBox(height: 24 * s),
        _buildRankList(s, themeGreen),
        SizedBox(height: 32 * s),
        _buildStatsRow(s),
        SizedBox(height: 24 * s),
        _buildDetailsBox(s),
        SizedBox(height: 16 * s),
        _buildObjectiveBoxDynamic(s, data),
        SizedBox(height: 16 * s),
        _buildPrizeBoxDynamic(s, themeGreen, data),
        
        if (isLive) ...[
          SizedBox(height: 32 * s),
          if (!isJoined)
            _buildUpcomingEntryFeeBox(
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
            _buildActionButton(s, 'GO TO LIVE COMPETITION', themeGreen, Colors.black, () {
              // Navigate to actual live tracking
            }),
            SizedBox(height: 16 * s),
            _buildActionButton(
              s,
              'Quit Competition',
              const Color(0xFFFF5252),
              Colors.black,
              () => _onQuit(data, userId),
            ),
          ],
        ],
        SizedBox(height: 48 * s),
      ],
    );
  }

  Widget _buildUpcomingStatsRowDynamic(double s, Map<String, dynamic> data) {
    final startAt = (data['start_at'] as Timestamp?)?.toDate();
    final dateStr = startAt != null ? DateFormat('MMM d').format(startAt) : '--';
    final distance = '${data['distance_km'] ?? 0}km';
    final difficulty = data['difficulty'] ?? 'Medium';

    return Row(
      children: [
        Expanded(child: _buildStatCard(s, Text(dateStr, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white)), 'Date')),
        SizedBox(width: 12 * s),
        Expanded(child: _buildStatCard(s, Text(distance, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white)), 'Distance')),
        SizedBox(width: 12 * s),
        Expanded(child: _buildStatCard(s, Text(difficulty, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white)), 'Difficulty')),
      ],
    );
  }

  Widget _buildUpcomingObjectiveAndRulesDynamic(double s, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Objective & Rules', style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 16 * s),
        _buildBulletText(s, data['objective'] ?? 'Complete the track within the time limit.'),
        _buildBulletText(s, data['rules'] ?? 'Ensure GPS tracking is active at all times.'),
      ],
    );
  }

  Widget _buildUpcomingParticipantsDynamic(double s, Map<String, dynamic> data) {
    final count = data['interested_count'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Participants', style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('$count interested', style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54)),
          ],
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(16 * s)),
          child: Row(children: [
            SizedBox(width: 70 * s, height: 32 * s, child: Stack(children: [
              Positioned(left: 0, child: _buildAvatarCircle(s, const Color(0xFF42A5F5))),
              Positioned(left: 20 * s, child: _buildAvatarCircle(s, const Color(0xFFFFB061))),
              Positioned(left: 40 * s, child: _buildAvatarCircle(s, const Color(0xFFFF5252))),
            ])),
            SizedBox(width: 12 * s),
            Text('Many are interested', style: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w500, color: Colors.white)),
          ]),
        ),
      ],
    );
  }

  Widget _buildUpcomingEntryFeeBox({
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
    final entryFee = data != null ? (data['entry_fee'] ?? 0) : 500;
    
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
            final balData = balanceSnapshot.data?.data() as Map<String, dynamic>?;
            final balance = balData?['points'] ?? 0;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
              decoration: BoxDecoration(
                  color: const Color(0xFF1B2228),
                  borderRadius: BorderRadius.circular(16 * s),
                  border: Border.all(color: Colors.white12)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ENTRY FEE', style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54)),
                    SizedBox(height: 4 * s),
                    Row(children: [
                      Text('$entryFee', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(width: 4 * s),
                      Image.asset('assets/profile/profile_digi_point.png', width: 28 * s, height: 28 * s),
                    ]),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('YOUR BALANCE', style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54)),
                    SizedBox(height: 4 * s),
                    Row(children: [
                      Text('$balance', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(width: 4 * s),
                      Image.asset('assets/profile/profile_digi_point.png', width: 28 * s, height: 28 * s),
                    ]),
                  ]),
                ]),
                SizedBox(height: 16 * s),
                _buildActionButton(
                  s, 
                  btnText, 
                  isAlreadyNotified ? Colors.white12 : cyanButton, 
                  isAlreadyNotified ? Colors.white : Colors.black, 
                  onTap ?? () {}
                ),
              ]),
            );
          },
        );
      },
    );
  }

  Future<void> _onToggleNotify(Map<String, dynamic> data, String userId) async {
    final compId = widget.competitionId!;
    try {
      final added = await _challengeService.toggleNotification(
        competitionId: compId,
        userId: userId,
      );
      if (mounted) {
        if (added) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CompetitionSystemAlertScreen(
            alertType: AlertType.notify,
            competitionName: data['title'] ?? 'Competition',
          )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications turned off.')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error toggling notify: $e')));
    }
  }

  Future<void> _onJoin(Map<String, dynamic> data, String userId) async {
    try {
      await _challengeService.joinCompetition(
        competitionId: widget.competitionId!,
        userId: userId,
        displayName: "User", 
        avatarUrl: "assets/challenge/male.png",
        joiningFee: data['entry_fee'] ?? 0,
      );
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CompetitionSystemAlertScreen(
          alertType: AlertType.join_success,
          competitionName: data['title'],
        )));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join failed: $e')));
    }
  }

  Future<void> _onQuit(Map<String, dynamic> data, String userId) async {
    final confirm = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CompetitionSystemAlertScreen(alertType: AlertType.quit)),
    );

    if (confirm == true) {
      try {
        await _challengeService.quitCompetition(competitionId: widget.competitionId!, userId: userId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have left the competition.')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quit failed: $e')));
      }
    }
  }

  Widget _buildObjectiveBoxDynamic(double s, Map<String, dynamic> data) {
    return _buildExpandableBox(s, 'Objective', data['description'] ?? data['objective'] ?? 'No objective defined.');
  }

  Widget _buildPrizeBoxDynamic(double s, Color themeGreen, Map<String, dynamic> data) {
    final pool = data['prize_pool'] as Map<String, dynamic>?;
    String content = 'Exclusive medals and digital points awarded to the top 3 finishers.';
    if (pool != null) {
      content = '1st: ${pool['1st'] ?? 'N/A'}\n2nd: ${pool['2nd'] ?? 'N/A'}\n3rd: ${pool['3rd'] ?? 'N/A'}';
    }
    return _buildExpandableBox(s, 'Prizes', content);
  }

  Widget _buildTextPrizePoolDynamic(double s, Map<String, dynamic> data) {
    final pool = data['prize_pool'] as Map<String, dynamic>?;
    if (pool == null) return _buildTextPrizePool(s);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(16 * s)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Prize pool', style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 16 * s),
        _buildTextPrizeRow(s, '1st Place', pool['1st_label'] ?? 'Champion Gold Medal', pool['1st'] ?? '0 Pts'),
        SizedBox(height: 12 * s),
        const Divider(color: Colors.white12, height: 1),
        SizedBox(height: 12 * s),
        _buildTextPrizeRow(s, '2nd Place', pool['2nd_label'] ?? 'Silver Medal', pool['2nd'] ?? '0 Pts'),
        SizedBox(height: 12 * s),
        const Divider(color: Colors.white12, height: 1),
        SizedBox(height: 12 * s),
        _buildTextPrizeRow(s, '3rd Place', pool['3rd_label'] ?? 'Bronze Medal', pool['3rd'] ?? '0 Pts'),
      ]),
    );
  }

  Widget _buildLocationAndRouteDynamic(double s, Map<String, dynamic> data) {
    final location = data['location'] ?? 'TBD';
    final mapImg = data['map_image'] as String?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(location, style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        Text('View Full Map', style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54, decoration: TextDecoration.underline)),
      ]),
      SizedBox(height: 16 * s),
      ClipRRect(
        borderRadius: BorderRadius.circular(16 * s), 
        child: Container(
          height: 120 * s, 
          color: Colors.white10, 
          child: mapImg != null && mapImg.isNotEmpty && mapImg.startsWith('http')
            ? Image.network(mapImg, fit: BoxFit.cover, width: double.infinity)
            : const Center(child: Icon(Icons.map, color: Colors.white24, size: 40))
        )
      ),
    ]);
  }

  // --- REUSED STATIC METHODS (POLISHED) ---

  Widget _buildHeaderImage(BuildContext context, double s, Color themeGreen) {
    String title = widget.customTitle ?? 'Red Bull Urban Run 2026';
    String statusText = 'Live';
    Color statusColor = themeGreen;
    String bgImage = widget.customImage ?? 'assets/challenge/challenge_24_main_1.png';

    if (widget.status == CompetitionStatus.upcoming) {
      if (widget.customTitle == null) title = 'Highland Cycle\nChampionship';
      statusText = 'Start in 02:15:45';
      statusColor = Colors.orangeAccent;
      if (widget.customImage == null) bgImage = 'assets/challenge/challenge_24_main_4.png';
    } else if (widget.status == CompetitionStatus.completed) {
      statusText = 'ENDED';
      statusColor = const Color(0xFFFF5252);
      if (widget.customImage == null) bgImage = 'assets/challenge/challenge_24_main_7.png';
    }

    return SizedBox(
      height: 350 * s,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6), const Color(0xFF0D1217)], stops: const [0.0, 0.5, 1.0])))),
          SafeArea(bottom: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ProfileTopBar(),
            SizedBox(height: 16 * s),
            Center(child: Text('HI, USER', style: GoogleFonts.outfit(fontSize: 12 * s, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.0))),
            const Spacer(),
            Padding(padding: EdgeInsets.symmetric(horizontal: 24 * s), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 24 * s, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(height: 8 * s),
              Row(children: [
                Container(width: 8 * s, height: 8 * s, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: statusColor.withOpacity(0.8), blurRadius: 8 * s)])),
                SizedBox(width: 6 * s),
                Text(statusText, style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w600, color: statusColor)),
              ]),
              SizedBox(height: 24 * s),
            ])),
          ])),
          Positioned(top: 40 * s, left: 16 * s, child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8 * s), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: Icon(Icons.arrow_back, color: Colors.white, size: 24 * s)))),
        ],
      ),
    );
  }

  Widget _buildContentStatic(BuildContext context, double s, Color themeGreen) {
    if (widget.status == CompetitionStatus.upcoming) {
      return Column(children: [
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
        _buildUpcomingEntryFeeBox(
          context: context, 
          s: s, 
          themeGreen: themeGreen,
          userId: "anonymous",
          competitionId: "static_comp",
        ),
        SizedBox(height: 48 * s),
      ]);
    }

    return Column(children: [
      SizedBox(height: 24 * s),
      _buildPodium(s, themeGreen),
      SizedBox(height: 24 * s),
      _buildRankList(s, themeGreen),
      SizedBox(height: 32 * s),
      _buildStatsRow(s),
      SizedBox(height: 24 * s),
      _buildDetailsBox(s),
      SizedBox(height: 16 * s),
      _buildObjectiveBox(s),
      SizedBox(height: 16 * s),
      _buildPrizeBox(s, themeGreen),
      SizedBox(height: 48 * s),
    ]);
  }

  // Helper widgets for static/shared views

  Widget _buildStatCard(double s, Widget value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(12 * s)),
      child: Column(children: [
        value,
        SizedBox(height: 4 * s),
        Text(label, style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54)),
      ]),
    );
  }

  Widget _buildTextPrizePool(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(16 * s)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Prize pool', style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 16 * s),
        _buildTextPrizeRow(s, '1st Place', 'Champion Gold Medal', '2,500 Pts'),
        SizedBox(height: 12 * s),
        const Divider(color: Colors.white12, height: 1),
        SizedBox(height: 12 * s),
        _buildTextPrizeRow(s, '2nd Place', 'Silver Medal', '1,000 Pts'),
        SizedBox(height: 12 * s),
        const Divider(color: Colors.white12, height: 1),
        SizedBox(height: 12 * s),
        _buildTextPrizeRow(s, '3rd Place', 'Bronze Medal', '500 Pts'),
      ]),
    );
  }

  Widget _buildTextPrizeRow(double s, String place, String subtitle, String reward) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(place, style: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 4 * s),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54)),
      ]),
      Text(reward, style: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w600, color: Colors.white)),
    ]);
  }

  Widget _buildBulletText(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('• ', style: TextStyle(color: themeGreen, fontSize: 14 * s)),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70, height: 1.4))),
      ]),
    );
  }

  Widget _buildUpcomingObjectiveAndRules(double s) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Objective & Rules', style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
      SizedBox(height: 16 * s),
      _buildBulletText(s, 'Complete the track within the allocated time limit.'),
      _buildBulletText(s, 'GPS tracking must be enabled throughout the duration.'),
    ]);
  }

  Widget _buildLocationAndRoute(double s) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Location & Route', style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        Text('View Full Map', style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54, decoration: TextDecoration.underline)),
      ]),
      SizedBox(height: 16 * s),
      ClipRRect(borderRadius: BorderRadius.circular(16 * s), child: Container(height: 120 * s, color: Colors.white10, child: const Center(child: Icon(Icons.map, color: Colors.white24, size: 40)))),
    ]);
  }

  Widget _buildUpcomingParticipants(double s) {
    return _buildUpcomingParticipantsDynamic(s, {'interested_count': 128});
  }

  Widget _buildAvatarCircle(double s, Color color) {
    return Container(width: 32 * s, height: 32 * s, decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: const Color(0xFF1B2228), width: 2)));
  }

  Widget _buildUpcomingStatsRow(double s) {
    return _buildUpcomingStatsRowDynamic(s, {});
  }

  Widget _buildPodium(double s, Color themeGreen) {
    return SizedBox(
      height: 180 * s,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
        _buildPodiumSpot(s: s, place: 2, height: 100 * s, name: 'Essa', color: const Color(0xFFC0C0C0), label: '2nd'),
        SizedBox(width: 8 * s),
        _buildPodiumSpot(s: s, place: 1, height: 140 * s, name: 'Maryam', color: const Color(0xFFFFD700), label: '1st'),
        SizedBox(width: 8 * s),
        _buildPodiumSpot(s: s, place: 3, height: 80 * s, name: 'Khalfan', color: const Color(0xFFCD7F32), label: '3rd'),
      ]),
    );
  }

  Widget _buildPodiumSpot({required double s, required int place, required double height, required String name, required Color color, required String label}) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10 * s, fontWeight: FontWeight.w700, color: color)),
      SizedBox(height: 4 * s),
      Container(width: 40 * s, height: 40 * s, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2), border: Border.all(color: color, width: 2))),
      SizedBox(height: 8 * s),
      Container(width: 80 * s, height: height, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.vertical(top: Radius.circular(8 * s))), child: Center(child: Text(name, style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white, fontWeight: FontWeight.w600)))),
    ]);
  }

  Widget _buildRankList(double s, Color themeGreen) {
    return Column(children: List.generate(3, (i) => _buildRankItem(s, i + 4, 'User ${i + 4}', '45:2$i')));
  }

  Widget _buildRankItem(double s, int rank, String name, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(12 * s)),
      child: Row(children: [
        Text('$rank', style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white54)),
        SizedBox(width: 16 * s),
        Text(name, style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white)),
        const Spacer(),
        Text(time, style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white70)),
      ]),
    );
  }

  Widget _buildStatsRow(double s) {
    return Row(children: [
      Expanded(child: _buildStatCard(s, const Icon(Icons.timer_outlined, color: Colors.white, size: 20), 'Duration')),
      SizedBox(width: 12 * s),
      Expanded(child: _buildStatCard(s, const Icon(Icons.flash_on_outlined, color: Colors.white, size: 20), 'Calories')),
      SizedBox(width: 12 * s),
      Expanded(child: _buildStatCard(s, const Icon(Icons.trending_up, color: Colors.white, size: 20), 'Avg Speed')),
    ]);
  }

  Widget _buildDetailsBox(double s) {
    return _buildExpandableBox(s, 'Details', 'Overall statistics and performance breakdown for this competition.');
  }

  Widget _buildObjectiveBox(double s) {
    return _buildExpandableBox(s, 'Objective', 'The main goal is to finish the course in the fastest time possible while maintaining safety.');
  }

  Widget _buildPrizeBox(double s, Color themeGreen) {
    return _buildExpandableBox(s, 'Prizes', 'Exclusive medals and digital points awarded to the top 3 finishers.');
  }

  Widget _buildExpandableBox(double s, String title, String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(color: const Color(0xFF1B2228), borderRadius: BorderRadius.circular(16 * s)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        ]),
        SizedBox(height: 12 * s),
        Text(content, style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54, height: 1.5)),
      ]),
    );
  }

  Widget _buildActionButton(double s, String text, Color bg, Color textCol, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30 * s)),
        child: Center(child: Text(text, style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w800, color: textCol))),
      ),
    );
  }
}

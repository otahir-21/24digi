import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../services/challenge_service.dart';
import 'competition_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart' as app_auth;

class CompetitionListScreen extends StatefulWidget {
  const CompetitionListScreen({super.key});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  int _selectedTab = 0; // 0=Active, 1=Upcoming, 2=Completed
  String _selectedSport = 'All';

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
                    children: [
                      SizedBox(height: 16 * s),
                      _buildHeader(s),
                      SizedBox(height: 24 * s),
                      _buildTabs(s),
                      SizedBox(height: 32 * s),
                      _buildTabContent(s),
                      SizedBox(height: 48 * s),
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

  Widget _buildHeader(double s) {
    final name = context.watch<app_auth.AuthProvider>().profile?.name ?? 'USER';
    return Column(
      children: [
        Text(
          'HI, ${name.toUpperCase()}',
          style: GoogleFonts.outfit(
            fontSize: 12 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(double s) {
    return Container(
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(30 * s),
      ),
      child: Row(
        children: [
          _buildTab(s, 0, 'Active'),
          _buildTab(s, 1, 'Upcoming'),
          _buildTab(s, 2, 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTab(double s, int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * s),
          decoration: BoxDecoration(
            color: isSelected ? themeGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(24 * s),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSportsFilter(s),
        SizedBox(height: 24 * s),
        _buildStreamedContent(s),
      ],
    );
  }

  Widget _buildStreamedContent(double s) {
    if (_selectedTab == 0) {
      return _buildActiveTabContent(s);
    }
    String statusStr = _selectedTab == 1 ? 'UPCOMING' : 'COMPLETED';
    return StreamBuilder<QuerySnapshot>(
      stream: _challengeService.getCompetitionsStream(
        statusStr,
        sportType: _selectedSport,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFF5CE1E6)),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.0 * s),
              child: Text(
                'No competitions found',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * s),
              child: _buildCompetitionCardFromData(s, id, data),
            );
          }).toList(),
        );
      },
    );
  }

  /// Active tab: show competitions whose status is ACTIVE.
  /// This matches the status field in Firestore (set via admin/CRM).
  Widget _buildActiveTabContent(double s) {
    return StreamBuilder<QuerySnapshot>(
      stream: _challengeService.getCompetitionsStream(
        'ACTIVE',
        sportType: _selectedSport,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFF5CE1E6)),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.0 * s),
              child: Text(
                'No competitions found',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * s),
              child: _buildCompetitionCardFromData(
                s,
                id,
                data,
                forceLive: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCompetitionCardFromData(
    double s,
    String id,
    Map<String, dynamic> data, {
    bool forceLive = false,
  }) {
    final status = forceLive ? 'ACTIVE' : (data['status'] ?? 'UPCOMING');
    final title = data['title'] ?? 'Title';
    final location = data['location'] ?? data['location_name'] ?? 'Location';
    final distance = data['distance_km'] ?? '0';
    final bgImage =
        data['bg_image'] ??
        data['cover_image'] ??
        'assets/challenge/challenge_24_main_1.png';
    final tag = data['tag'] ?? 'Challenge';

    final startAt = (data['start_at'] as Timestamp?)?.toDate();
    final endAt = (data['end_at'] as Timestamp?)?.toDate();

    final auth = context.read<app_auth.AuthProvider>();
    final userId = auth.firebaseUser?.uid ?? "anonymous";

    return StreamBuilder<DocumentSnapshot>(
      stream: _challengeService.getUserEnrollmentStream(title, userId),
      builder: (context, enrollSnapshot) {
        final bool isJoined =
            enrollSnapshot.hasData && enrollSnapshot.data!.exists;
        final enrollData = isJoined
            ? (enrollSnapshot.data!.data() as Map<String, dynamic>?)
            : null;

        Widget topLeft = const SizedBox();
        Widget topRight = const SizedBox();
        Widget bottomRow = const SizedBox();
        Widget? midRight;
        double? progressBar;

        if (status == 'UPCOMING') {
          final timeStr = _formatRemaining(startAt);
          topLeft = _buildPill(
            s,
            'Start in $timeStr',
            bg: Colors.white.withOpacity(0.9),
            textCol: Colors.black,
            noBorder: true,
          );
          topRight = _buildDotPill(s, 'Soon', const Color(0xFF42A5F5));
          midRight = _buildOutlinedTag(
            s,
            '${data['interested_count'] ?? 0} interested',
            Colors.orangeAccent,
          );
          bottomRow = _buildOutlinedButton(
            s,
            'Details',
            const Color(0xFF42A5F5),
            id: id,
          );
        } else if (status == 'ACTIVE') {
          final timeStr = _formatRemaining(endAt);
          final diff =
              endAt?.difference(DateTime.now()) ?? const Duration(days: 1);
          final bool isEndingSoon = diff.inHours < 5;

          topLeft = isEndingSoon
              ? _buildPill(
                  s,
                  'Ending Soon',
                  bg: const Color(0xFFFF5252).withOpacity(0.8),
                  textCol: Colors.white,
                  noBorder: true,
                )
              : _buildPill(
                  s,
                  '$timeStr LEFT',
                  bg: Colors.white.withOpacity(0.8),
                  textCol: Colors.black,
                  noBorder: true,
                );

          topRight = _buildDotPill(s, 'Active Now', themeGreen);

          if (isJoined) {
            progressBar = 0.65; // Sample progress
            bottomRow = _buildRankRow(
              s,
              rankStr: '#${enrollData?['rank'] ?? '--'}',
              total: '${data['current_participants'] ?? 0}',
              time: enrollData?['duration'] ?? '45:20',
              isEye: false,
              outlineArrow: false,
              id: id,
              isLive: true,
            );
          } else {
            bottomRow = _buildJoinButton(s, id);
          }
        } else {
          final dateStr = startAt != null
              ? DateFormat('MMM dd').format(startAt).toUpperCase()
              : '--';
          topLeft = _buildIconPill(s, Icons.calendar_today, dateStr);
          topRight = _buildPill(
            s,
            'Completed',
            bg: themeGreen,
            textCol: Colors.black,
            noBorder: true,
          );
          bottomRow = _buildRankRow(
            s,
            rankStr: '#${enrollData?['rank'] ?? '--'}',
            total: '${data['current_participants'] ?? 0}',
            time: enrollData?['duration'] ?? '00:00',
            isEye: true,
            outlineArrow: false,
            id: id,
            isLive: false,
          );
        }

        return _CompetitionCard(
          s: s,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionDetailScreen(
                  status: _getDetailStatus(status),
                  competitionId: id,
                ),
              ),
            );
          },
          bgImage: bgImage,
          topLeft: topLeft,
          topRight: topRight,
          tag: tag,
          title: title,
          location: location,
          distance: '${distance}km',
          bottomRow: bottomRow,
          midRight: midRight,
          progressBar: progressBar,
        );
      },
    );
  }

  Widget _buildJoinButton(double s, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionDetailScreen(
              status: CompetitionStatus.live,
              competitionId: id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * s),
          border: Border.all(color: const Color(0xFF00E5FF), width: 2 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.1),
              blurRadius: 10 * s,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Join Now',
          style: GoogleFonts.outfit(
            fontSize: 20 * s,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00E5FF),
          ),
        ),
      ),
    );
  }

  CompetitionStatus _getDetailStatus(String status) {
    if (status == 'ACTIVE') return CompetitionStatus.live;
    if (status == 'COMPLETED') return CompetitionStatus.completed;
    return CompetitionStatus.upcoming;
  }

  String _formatRemaining(DateTime? target) {
    if (target == null) return '--';
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '0 h 0M';
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '$hours h ${mins}M';
  }

  Widget _buildOutlinedButton(
    double s,
    String text,
    Color color, {
    required String id,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionDetailScreen(
              status: text == 'Join Now'
                  ? CompetitionStatus.live
                  : CompetitionStatus.upcoming,
              competitionId: id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * s),
          border: Border.all(color: color, width: 1.5 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSportsFilter(double s) {
    final sports = [
      {'icon': Icons.toys_outlined, 'label': 'All'},
      {'icon': Icons.directions_walk, 'label': 'Walking'},
      {'icon': Icons.directions_run, 'label': 'Running'},
      {'icon': Icons.directions_bike, 'label': 'Cycling'},
      {'icon': Icons.fitness_center, 'label': 'Workout'},
      {'icon': Icons.pool, 'label': 'Swimming'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filter By Sport',
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedSport = 'All'),
              child: Text(
                'Clear all',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: sports.map((sport) {
              final label = sport['label'] as String;
              final isActive = _selectedSport == label;
              final Color bgColor = isActive
                  ? themeGreen
                  : const Color(0xFF262C31);
              final Color iconColor = isActive ? bgDark : Colors.white;
              final Color textColor = isActive ? Colors.white : Colors.white54;

              return Padding(
                padding: EdgeInsets.only(right: 16 * s),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSport = label);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 54 * s,
                        height: 54 * s,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(18 * s),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: themeGreen.withOpacity(0.3),
                                    blurRadius: 10 * s,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          sport['icon'] as IconData,
                          color: iconColor,
                          size: 26 * s,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        sport['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: textColor,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPill(
    double s,
    String text, {
    Color bg = Colors.transparent,
    Color textCol = Colors.white,
    bool noBorder = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * s),
        border: noBorder ? null : Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
      ),
    );
  }

  Widget _buildDotPill(double s, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6 * s,
            height: 6 * s,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4 * s),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPill(double s, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10 * s),
          SizedBox(width: 4 * s),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedTag(double s, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9 * s,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRankRow(
    double s, {
    required String rankStr,
    required String total,
    required String time,
    required bool isEye,
    required bool outlineArrow,
    required String id,
    bool isLive = false,
  }) {
    final bool isDash = rankStr.contains('-');
    final Color rankColor = isDash ? Colors.white54 : themeGreen;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionDetailScreen(
              status: isLive
                  ? CompetitionStatus.live
                  : CompetitionStatus.completed,
              competitionId: id,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2228).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: Colors.white54,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rankStr,
                      style: GoogleFonts.inter(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w800,
                        color: rankColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 2 * s),
                      child: Text(
                        ' / $total',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 32 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time',
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isEye)
              Container(
                padding: EdgeInsets.all(8 * s),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 20 * s,
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(10 * s),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeGreen,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 20 * s,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final double s;
  final VoidCallback? onTap;
  final String bgImage;
  final Widget topLeft;
  final Widget topRight;
  final String tag;
  final String title;
  final String location;
  final String distance;
  final Widget bottomRow;
  final double? progressBar;
  final Widget? midRight;

  const _CompetitionCard({
    required this.s,
    this.onTap,
    required this.bgImage,
    required this.topLeft,
    required this.topRight,
    required this.tag,
    required this.title,
    required this.location,
    required this.distance,
    required this.bottomRow,
    this.progressBar,
    this.midRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24 * s)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24 * s),
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
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [topLeft, topRight],
                    ),
                    SizedBox(height: 72 * s),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 2 * s,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white54,
                          size: 14 * s,
                        ),
                        SizedBox(width: 4 * s),
                        Text(
                          '$location  •  $distance',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: Colors.white54,
                          ),
                        ),
                        if (midRight != null) ...[const Spacer(), midRight!],
                      ],
                    ),
                    if (progressBar != null) ...[
                      SizedBox(height: 12 * s),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4 * s),
                        child: Stack(
                          children: [
                            Container(
                              height: 4 * s,
                              width: double.infinity,
                              color: Colors.white24,
                            ),
                            FractionallySizedBox(
                              widthFactor: progressBar,
                              child: Container(
                                height: 4 * s,
                                color: const Color(0xFF00FF88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20 * s),
                    bottomRow,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

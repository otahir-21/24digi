import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/screens/challenge/adventure_zone_screen.dart';
import 'package:kivi_24/screens/challenge/ai_challenge_screen.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_general_screen.dart';
import 'private_zone_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/challenge_service.dart';

class ChallengeDashboardScreen extends StatefulWidget {
  const ChallengeDashboardScreen({super.key});

  @override
  State<ChallengeDashboardScreen> createState() =>
      _ChallengeDashboardScreenState();
}

class _ChallengeDashboardScreenState extends State<ChallengeDashboardScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  String selectedSport = 'All';

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16 * s),
                      _buildHeader(s),
                      SizedBox(height: 24 * s),
                      _buildSportsFilter(s),
                      SizedBox(height: 24 * s),
                      _buildFilterBy(s),
                      SizedBox(height: 32 * s),
                      _buildResultsSection(s),
                      SizedBox(height: 48 * s),
                      _buildDynamicAngledCards(s),
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

  /// Main screen hero: show first ACTIVE competition that matches selectedSport.
  Widget _buildActiveCompetitionHero(double s) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getCompetitionsStream(
        'ACTIVE',
        sportType: selectedSport == 'All' ? null : selectedSport,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Active competition';
        final subtitle = data['subtitle'] ?? data['description'] ?? '';
        final location = data['location'] ?? data['location_name'] ?? 'Location';
        final distance = data['distance_km']?.toString() ?? '0';
        final bgImage =
            data['bg_image'] ?? 'assets/challenge/challenge_24_main_1.png';

        final bool isRemote =
            bgImage is String && (bgImage.startsWith('http://') || bgImage.startsWith('https://'));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionGeneralScreen(),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * s),
              image: DecorationImage(
                image: isRemote
                    ? NetworkImage(bgImage) as ImageProvider
                    : AssetImage(bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.35),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: EdgeInsets.all(16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE NOW',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    color: themeGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (subtitle.toString().isNotEmpty) ...[
                  SizedBox(height: 4 * s),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white70,
                    ),
                  ),
                ],
                SizedBox(height: 10 * s),
                Row(
                  children: [
                    Icon(Icons.place, size: 14 * s, color: Colors.white70),
                    SizedBox(width: 4 * s),
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Icon(Icons.directions_run,
                        size: 14 * s, color: Colors.white70),
                    SizedBox(width: 4 * s),
                    Text(
                      '${distance} km',
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Consumer<AuthProvider>(
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
          ),
        ),
        SizedBox(height: 4 * s),
        Center(
          child: Text(
            '24 Challenge',
            style: GoogleFonts.outfit(
              fontSize: 28 * s,
              fontWeight: FontWeight.w800,
              color: themeGreen,
              letterSpacing: 0.5,
              shadows: [
                Shadow(color: themeGreen.withOpacity(0.5), blurRadius: 10 * s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSportsFilter(double s) {
    final sports = [
      {'icon': Icons.toys_outlined, 'label': 'All', 'active': true},
      {'icon': Icons.directions_walk, 'label': 'Walking', 'active': false},
      {'icon': Icons.directions_run, 'label': 'Running', 'active': false},
      {'icon': Icons.directions_bike, 'label': 'Cycling', 'active': false},
      {'icon': Icons.fitness_center, 'label': 'Workout', 'active': false},
      {'icon': Icons.pool, 'label': 'Swimming', 'active': false},
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
              onTap: () => setState(() => selectedSport = 'All'),
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
              final isActive = label == selectedSport;
              final Color bgColor = isActive
                  ? themeGreen
                  : const Color(0xFF262C31);
              final Color iconColor = isActive ? bgDark : Colors.white;
              final Color textColor = isActive ? Colors.white : Colors.white54;

              return Padding(
                padding: EdgeInsets.only(right: 16 * s),
                child: GestureDetector(
                  onTap: () => setState(() => selectedSport = label),
                  child: Column(
                    children: [
                      Container(
                        width: 50 * s,
                        height: 50 * s,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: Icon(
                          sport['icon'] as IconData,
                          color: iconColor,
                          size: 24 * s,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 10 * s,
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

  Widget _buildFilterBy(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter By ...',
          style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            _buildPill(s, 'All', true),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Distance', false),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Time', false),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Pace', false),
          ],
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: themeGreen,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'location',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: bgDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(Icons.keyboard_arrow_down, color: bgDark, size: 16 * s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill(double s, String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2E353C),
        borderRadius: BorderRadius.circular(16 * s),
        border: isActive ? Border.all(color: Colors.white38) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12 * s,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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
    required String tag,
    bool isCenter = false,
    bool isLeft = false,
    bool isRight = false,
  }) {
    final avatarSize = isCenter ? 80 * s : 64 * s;

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
                  color: Colors.grey.withValues(alpha: .2),
                  border: Border.all(color: themeGreen, width: 2 * s),
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
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(8 * s),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      fontWeight: FontWeight.w700,
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
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
                        themeGreen.withOpacity(0.25),
                        themeGreen.withOpacity(0.0),
                      ],
                    ),
              color: isCenter ? themeGreen : null,
              border: Border(
                top: BorderSide(
                  color: isCenter ? themeGreen : themeGreen.withOpacity(0.6),
                  width: 2,
                ),
                left: isRight
                    ? BorderSide.none
                    : BorderSide(
                        color: isCenter
                            ? themeGreen
                            : themeGreen.withOpacity(0.3),
                        width: isCenter ? 0 : 1,
                      ),
                right: isLeft
                    ? BorderSide.none
                    : BorderSide(
                        color: isCenter
                            ? themeGreen
                            : themeGreen.withOpacity(0.3),
                        width: isCenter ? 0 : 1,
                      ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 4 * s),
                Stack(
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
                                fontSize: isCenter ? 36 * s : 30 * s,
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
                            fontSize: isCenter ? 14 * s : 10 * s,
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

  Widget _buildUserRank(double s) {
    return _buildRankItem(s, '24', 'Your Name', true);
  }

  Widget _buildRankItem(double s, String rank, String name, bool isUser) {
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
            width: 24 * s,
            height: 24 * s,
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

  /// Results section: heading + global leaderboard (Top #10, podium, your rank).
  Widget _buildResultsSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results',
          style: GoogleFonts.outfit(
            fontSize: 20 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16 * s),
        _buildDynamicLeaderboard(s),
      ],
    );
  }

  Widget _buildDynamicLeaderboard(double s) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getGlobalLeaderboardStream(
        sportType: selectedSport,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5CE1E6)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * s),
              child: Text(
                'No leaderboard data yet.\nJoin a competition to appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 13 * s,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top #10',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16 * s),
            _buildPodiumFromData(s, docs),
            SizedBox(height: 24 * s),
            _buildRankListFromData(s, docs),
            SizedBox(height: 16 * s),
            _buildUserRank(s),
          ],
        );
      },
    );
  }

  Widget _buildPodiumFromData(double s, List<QueryDocumentSnapshot> docs) {
    // 1st, 2nd, 3rd logic
    final first = docs.isNotEmpty
        ? docs[0].data() as Map<String, dynamic>
        : null;
    final second = docs.length > 1
        ? docs[1].data() as Map<String, dynamic>
        : null;
    final third = docs.length > 2
        ? docs[2].data() as Map<String, dynamic>
        : null;

    return SizedBox(
      height: 240 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (second != null)
            _buildPodiumSpot(
              s: s,
              place: 2,
              height: 140 * s,
              name: second['display_name'] ?? 'User',
              color: const Color(0xFFC0C0C0),
              avatarAsset: second['avatar_url'] ?? 'assets/fonts/male.png',
              suffix: 'nd',
              tag: '#2',
              isLeft: true,
            ),
          if (first != null)
            _buildPodiumSpot(
              s: s,
              place: 1,
              height: 200 * s,
              name: first['display_name'] ?? 'User',
              color: const Color(0xFFFFD700),
              avatarAsset: first['avatar_url'] ?? 'assets/fonts/female.png',
              suffix: 'st',
              tag: first['display_name'] ?? 'Winner',
              isCenter: true,
            ),
          if (third != null)
            _buildPodiumSpot(
              s: s,
              place: 3,
              height: 120 * s,
              name: third['display_name'] ?? 'User',
              color: const Color(0xFFCD7F32),
              avatarAsset: third['avatar_url'] ?? 'assets/fonts/male.png',
              suffix: 'rd',
              tag: '#3',
              isRight: true,
            ),
        ],
      ),
    );
  }

  Widget _buildRankListFromData(double s, List<QueryDocumentSnapshot> docs) {
    if (docs.length < 4) return const SizedBox();
    return Column(
      children: [
        for (int i = 3; i < docs.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: _buildRankItem(
              s,
              (i + 1).toString().padLeft(2, '0'),
              (docs[i].data() as Map<String, dynamic>)['display_name'] ??
                  'User',
              false,
            ),
          ),
      ],
    );
  }

  Widget _buildDynamicAngledCards(double s) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ChallengeService().getLocksStream(),
      builder: (context, snapshot) {
        final Map<String, dynamic> locks =
            (snapshot.hasData && snapshot.data!.exists)
            ? snapshot.data!.data() as Map<String, dynamic>
            : {
                'private_zone_locked': true,
                'ai_challenge_locked': true,
                'adventure_zone_locked': true,
              };

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _buildModuleCard(
                s: s,
                label: '24 Competition',
                isRight: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompetitionGeneralScreen(),
                  ),
                ),
                isLocked: false,
              ),
            ),
            SizedBox(height: 12 * s),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildModuleCard(
                s: s,
                label: '24 Private Zone',
                isRight: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivateZoneScreen()),
                ),
                isLocked: locks['private_zone_locked'] ?? true,
              ),
            ),
            SizedBox(height: 12 * s),
            Align(
              alignment: Alignment.centerRight,
              child: _buildModuleCard(
                s: s,
                label: 'AI Challenge Zone',
                isRight: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChallengeScreen()),
                ),
                isLocked: locks['ai_challenge_locked'] ?? true,
              ),
            ),
            SizedBox(height: 12 * s),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildModuleCard(
                s: s,
                label: '24 Adventure\nzone',
                isRight: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdventureChallengeScreen(),
                  ),
                ),
                isLocked: locks['adventure_zone_locked'] ?? true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModuleCard({
    required double s,
    required String label,
    required bool isRight,
    required VoidCallback onTap,
    required bool isLocked,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This zone is currently locked.')),
              );
            }
          : onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 80 * s,
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Stack(
            children: [
              _SlantedCard(
                s: s,
                isRightAligned: isRight,
                label: label,
                labelColor: isLocked ? Colors.grey : themeGreen,
              ),
              if (isLocked)
                Positioned(
                  top: 8 * s,
                  right: isRight ? 16 * s : null,
                  left: isRight ? null : 16 * s,
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.white38,
                    size: 20 * s,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlantedCard extends StatelessWidget {
  final double s;
  final bool isRightAligned;
  final String label;
  final Color labelColor;
  const _SlantedCard({
    required this.s,
    required this.isRightAligned,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SlantedCardPainter(
        isRightAligned: isRightAligned,
        borderColor: const Color(0xFF00FF88),
      ),
      child: ClipPath(
        clipper: _SlantedClipper(isRightAligned: isRightAligned),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF262C31), Color(0xFF13181D)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlantedClipper extends CustomClipper<Path> {
  final bool isRightAligned;
  _SlantedClipper({required this.isRightAligned});

  @override
  Path getClip(Size size) {
    final path = Path();
    final slantOffset = 30.0;
    if (isRightAligned) {
      path.moveTo(slantOffset, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - slantOffset, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SlantedCardPainter extends CustomPainter {
  final bool isRightAligned;
  final Color borderColor;

  _SlantedCardPainter({
    required this.isRightAligned,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final slantOffset = 30.0;

    if (isRightAligned) {
      path.moveTo(slantOffset, 0);
      path.lineTo(size.width - 1, 0); // inset slightly so stroke isn't clipped
      path.lineTo(size.width - 1, size.height - 1);
      path.lineTo(0, size.height - 1);
      path.close();
    } else {
      path.moveTo(1, 1);
      path.lineTo(size.width - 1, 1);
      path.lineTo(size.width - slantOffset - 1, size.height - 1);
      path.lineTo(1, size.height - 1);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

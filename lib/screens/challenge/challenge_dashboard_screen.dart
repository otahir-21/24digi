import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/screens/challenge/adventure_zone_screen.dart';
import 'package:kivi_24/screens/challenge/ai_challenge_screen.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../core/utils/custom_snackbar.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_general_screen.dart';
import 'private_zone_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/challenge_service.dart';
import '../../widgets/challenge_ranking_list.dart';

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
  String selectedFilter = 'All';

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
  // Widget _buildActiveCompetitionHero(double s) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: ChallengeService().getCompetitionsStream(
  //       'ACTIVE',
  //       sportType: selectedSport == 'All' ? null : selectedSport,
  //     ),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const SizedBox.shrink();
  //       }
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         // Show dummy competition if stream is empty as requested
  //         return _buildDummyHero(s);
  //       }
  //       final doc = snapshot.data!.docs.first;
  //       final data = doc.data() as Map<String, dynamic>;
  //       final title = data['title'] ?? 'Active competition';
  //       final subtitle = data['subtitle'] ?? data['description'] ?? '';
  //       final location = data['location'] ?? data['location_name'] ?? 'Location';
  //       final distance = data['distance_km']?.toString() ?? '0';
  //       final bgImage =
  //           data['bg_image'] ?? 'assets/challenge/challenge_24_main_1.png';

  //       final bool isRemote =
  //           bgImage is String && (bgImage.startsWith('http://') || bgImage.startsWith('https://'));

  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (_) => CompetitionGeneralScreen(),
  //             ),
  //           );
  //         },
  //         child: Container(
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20 * s),
  //             image: DecorationImage(
  //               image: isRemote
  //                   ? NetworkImage(bgImage) as ImageProvider
  //                   : AssetImage(bgImage),
  //               fit: BoxFit.cover,
  //               colorFilter: ColorFilter.mode(
  //                 Colors.black.withOpacity(0.35),
  //                 BlendMode.darken,
  //               ),
  //             ),
  //           ),
  //           padding: EdgeInsets.all(16 * s),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'ACTIVE NOW',
  //                 style: GoogleFonts.inter(
  //                   fontSize: 11 * s,
  //                   fontWeight: FontWeight.w700,
  //                   color: themeGreen,
  //                   letterSpacing: 1.2,
  //                 ),
  //               ),
  //               SizedBox(height: 6 * s),
  //               Text(
  //                 title,
  //                 style: GoogleFonts.outfit(
  //                   fontSize: 22 * s,
  //                   fontWeight: FontWeight.w800,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               if (subtitle.toString().isNotEmpty) ...[
  //                 SizedBox(height: 4 * s),
  //                 Text(
  //                   subtitle,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: GoogleFonts.inter(
  //                     fontSize: 12 * s,
  //                     color: Colors.white70,
  //                   ),
  //                 ),
  //               ],
  //               SizedBox(height: 10 * s),
  //               Row(
  //                 children: [
  //                   Icon(Icons.place, size: 14 * s, color: Colors.white70),
  //                   SizedBox(width: 4 * s),
  //                   Text(
  //                     location,
  //                     style: GoogleFonts.inter(
  //                       fontSize: 11 * s,
  //                       color: Colors.white70,
  //                     ),
  //                   ),
  //                   SizedBox(width: 12 * s),
  //                   Icon(Icons.directions_run,
  //                       size: 14 * s, color: Colors.white70),
  //                   SizedBox(width: 4 * s),
  //                   Text(
  //                     '${distance} km',
  //                     style: GoogleFonts.inter(
  //                       fontSize: 11 * s,
  //                       color: Colors.white70,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
            _buildPill(s, 'All'),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Distance'),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Time'),
            SizedBox(width: 12 * s),
            _buildPill(s, 'Pace'),
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

  Widget _buildPill(double s, String text) {
    final isActive = selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: isActive
              ? themeGreen.withOpacity(0.15)
              : const Color(0xFF2E353C),
          borderRadius: BorderRadius.circular(16 * s),
          border: isActive
              ? Border.all(color: themeGreen.withOpacity(0.5))
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            color: isActive ? themeGreen : Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
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
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.profile?.name ?? 'Your Name';

        // As requested: show the dummy ranking, match exact the figma UI design
        final List<Map<String, dynamic>> dummyRankings = [
          {'display_name': 'Maryam', 'avatar_url': 'assets/fonts/female.png'},
          {'display_name': 'Essa', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'Khalfan', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
          {'display_name': 'User Name', 'avatar_url': 'assets/fonts/male.png'},
        ];

        return ChallengeRankingList(
          s: s,
          rankings: dummyRankings,
          currentUserName: userName,
          currentUserRank: 24,
        );
      },
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
              CustomSnackBar.show(context, message: 'This zone is currently locked.', isError: true);
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

  // Widget _buildDummyHero(double s) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => CompetitionGeneralScreen()),
  //       );
  //     },
  //     child: Container(
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20 * s),
  //         image: DecorationImage(
  //           image: const AssetImage('assets/challenge/challenge_24_main_1.png'),
  //           fit: BoxFit.cover,
  //           colorFilter: ColorFilter.mode(
  //             Colors.black.withValues(alpha: .35),
  //             BlendMode.darken,
  //           ),
  //         ),
  //       ),
  //       padding: EdgeInsets.all(16 * s),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'ACTIVE NOW',
  //             style: GoogleFonts.inter(
  //               fontSize: 11 * s,
  //               fontWeight: FontWeight.w700,
  //               color: themeGreen,
  //               letterSpacing: 1.2,
  //             ),
  //           ),
  //           SizedBox(height: 6 * s),
  //           Text(
  //             'CHALLENGE 24',
  //             style: GoogleFonts.outfit(
  //               fontSize: 22 * s,
  //               fontWeight: FontWeight.w800,
  //               color: Colors.white,
  //             ),
  //           ),
  //           SizedBox(height: 4 * s),
  //           Text(
  //             'Experience the ultimate fitness competition and unlock exclusive rewards.',
  //             maxLines: 2,
  //             overflow: TextOverflow.ellipsis,
  //             style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
  //           ),
  //           SizedBox(height: 10 * s),
  //           Row(
  //             children: [
  //               Icon(Icons.place, size: 14 * s, color: Colors.white70),
  //               SizedBox(width: 4 * s),
  //               Text('Dubai, UAE',
  //                   style:
  //                       GoogleFonts.inter(fontSize: 11 * s, color: Colors.white70)),
  //               SizedBox(width: 12 * s),
  //               Icon(Icons.directions_run, size: 14 * s, color: Colors.white70),
  //               SizedBox(width: 4 * s),
  //               Text('5.0 km',
  //                   style:
  //                       GoogleFonts.inter(fontSize: 11 * s, color: Colors.white70)),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
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

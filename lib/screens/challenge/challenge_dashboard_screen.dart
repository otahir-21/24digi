import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/challenge/ai_challenge_screen.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_general_screen.dart';
import 'private_zone_screen.dart';
import 'adventure_challenge_screen.dart';

class ChallengeDashboardScreen extends StatefulWidget {
  const ChallengeDashboardScreen({super.key});

  @override
  State<ChallengeDashboardScreen> createState() =>
      _ChallengeDashboardScreenState();
}

class _ChallengeDashboardScreenState extends State<ChallengeDashboardScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);

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
                      Text(
                        'Top #10',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      _buildPodium(s),
                      SizedBox(height: 24 * s),
                      _buildRankList(s),
                      SizedBox(height: 16 * s),
                      _buildUserRank(s),
                      SizedBox(height: 48 * s),
                      _buildAngledCards(s),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
            Text(
              'Clear all',
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: sports.map((sport) {
              final isActive = sport['active'] as bool;
              final Color bgColor = isActive
                  ? themeGreen
                  : const Color(0xFF262C31);
              final Color iconColor = isActive ? bgDark : Colors.white;
              final Color textColor = isActive ? Colors.white : Colors.white54;

              return Padding(
                padding: EdgeInsets.only(right: 16 * s),
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
                      sport['label'] as String,
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

  Widget _buildPodium(double s) {
    return SizedBox(
      height: 240 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place
          _buildPodiumSpot(
            s: s,
            place: 2,
            height: 140 * s,
            name: 'Essa',
            color: const Color(0xFFC0C0C0), // Silverish
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'nd',
            tag: '#2',
            isLeft: true,
          ),

          // 1st Place
          _buildPodiumSpot(
            s: s,
            place: 1,
            height: 200 * s,
            name: 'Maryam',
            color: const Color(0xFFFFD700), // Gold
            avatarAsset: 'assets/fonts/female.png',
            suffix: 'st',
            tag: 'Maryam',
            isCenter: true,
          ),

          // 3rd Place
          _buildPodiumSpot(
            s: s,
            place: 3,
            height: 120 * s,
            name: 'Khalfan',
            color: const Color(0xFFCD7F32), // Bronze
            avatarAsset: 'assets/fonts/male.png',
            suffix: 'rd',
            tag: '#3',
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

  Widget _buildRankList(double s) {
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

  Widget _buildAngledCards(double s) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompetitionGeneralScreen(),
                ),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80 * s,
              child: _SlantedCard(
                s: s,
                isRightAligned: true,
                label: '24 Competition',
                labelColor: themeGreen,
              ),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivateZoneScreen()),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80 * s,
              child: _SlantedCard(
                s: s,
                isRightAligned: false,
                label: '24 Private Zone',
                labelColor: themeGreen,
              ),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIChallengeScreen()),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80 * s,
              child: _SlantedCard(
                s: s,
                isRightAligned: true,
                label: 'AI Challenge Zone',
                labelColor: themeGreen,
              ),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdventureChallengeScreen()),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80 * s,
              child: _SlantedCard(
                s: s,
                isRightAligned: false,
                label: '24 Adventure\nzone',
                labelColor: themeGreen,
              ),
            ),
          ),
        ),
      ],
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

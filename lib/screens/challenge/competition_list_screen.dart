import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_detail_screen.dart';

class CompetitionListScreen extends StatefulWidget {
  const CompetitionListScreen({super.key});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
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
    return Column(
      children: [
        Text(
          'HI, USER',
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
    String title = '';
    if (_selectedTab == 0) title = 'Active Competitions';
    if (_selectedTab == 1) title = 'Upcoming Competitions';
    if (_selectedTab == 2) title = 'Past Competitions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 24 * s),
        _buildSportsFilter(s),
        SizedBox(height: 24 * s),
        if (_selectedTab == 0) ..._buildActiveCards(s),
        if (_selectedTab == 1) ..._buildUpcomingCards(s),
        if (_selectedTab == 2) ..._buildCompletedCards(s),
      ],
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
                style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
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
                        width: 54 * s, // Slightly larger
                        height: 54 * s,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(18 * s),
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: themeGreen.withOpacity(0.3),
                              blurRadius: 10 * s,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
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

  // BUILD ACTIVE CARDS
  List<Widget> _buildActiveCards(double s) {
    return [
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.upcoming,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_1.png',
        topLeft: _buildPill(
          s,
          '2 h 15M LEFT',
          bg: Colors.white,
          textCol: Colors.black,
        ),
        topRight: _buildDotPill(s, 'Active Now', themeGreen),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        bottomRow: _buildOutlinedButton(
          s,
          'Join Now',
          const Color(0xFF00E5FF),
        ), // Cyan
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CompetitionDetailScreen(status: CompetitionStatus.live),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_2.png',
        topLeft: _buildIconPill(s, Icons.calendar_today, 'OCT 12'),
        topRight: _buildDotPill(s, 'Active Now', themeGreen),
        tag: 'High Intensity',
        title: 'Jabal al Hafeet cycling',
        location: 'Al Ain',
        distance: '20km',
        bottomRow: _buildRankRow(
          s,
          rankStr: '#14',
          total: '20',
          time: '45:20',
          isEye: false,
          outlineArrow: false,
        ),
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CompetitionDetailScreen(status: CompetitionStatus.live),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_3.png',
        borderColor: Colors.redAccent,
        topLeft: _buildPill(
          s,
          'Ending Soon',
          bg: Colors.redAccent,
          textCol: Colors.white,
          noBorder: true,
        ),
        topRight: _buildPill(
          s,
          '4 h 30M LEFT',
          bg: Colors.black54,
          textCol: Colors.white,
          noBorder: true,
        ),
        tag: 'High Intensity',
        title: 'Jabal al Hafeet cycling',
        location: 'Al Ain',
        distance: '20km',
        progressBar: 0.8,
        bottomRow: _buildRankRow(
          s,
          rankStr: '#32',
          total: '45',
          time: '45:20',
          isEye: false,
          outlineArrow: false,
        ),
      ),
    ];
  }

  // BUILD UPCOMING CARDS
  List<Widget> _buildUpcomingCards(double s) {
    final blueCol = const Color(0xFF42A5F5);
    return [
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.upcoming,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_4.png',
        topLeft: _buildPill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white.withOpacity(0.9),
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _buildDotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _buildOutlinedTag(s, '128 interested', Colors.orangeAccent),
        bottomRow: _buildOutlinedButton(s, 'Details', blueCol),
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.upcoming,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_5.png',
        borderColor: blueCol,
        topLeft: _buildPill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white.withOpacity(0.9),
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _buildDotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _buildOutlinedTag(s, '78 interested', Colors.orangeAccent),
        bottomRow: _buildOutlinedButton(s, 'Details', blueCol),
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.upcoming,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_6.png',
        topLeft: _buildPill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white.withOpacity(0.9),
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _buildDotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _buildOutlinedTag(s, '128 interested', Colors.orangeAccent),
        bottomRow: _buildOutlinedButton(s, 'Details', blueCol),
      ),
    ];
  }

  // BUILD COMPLETED CARDS
  List<Widget> _buildCompletedCards(double s) {
    final blueCol = const Color(0xFF42A5F5);
    return [
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.completed,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_7.png',
        topLeft: _buildIconPill(s, Icons.calendar_today, 'OCT 12'),
        topRight: _buildPill(
          s,
          'Completed',
          bg: themeGreen,
          textCol: Colors.black,
          noBorder: true,
        ),
        tag: 'High Intensity',
        title: 'Highland cycle',
        location: 'Umm Al Quwain',
        distance: '20km',
        bottomRow: _buildRankRow(
          s,
          rankStr: '#5',
          total: '45',
          time: '45:20',
          isEye: false,
          outlineArrow: true,
        ),
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.completed,
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_8.png',
        topLeft: _buildIconPill(s, Icons.calendar_today, 'SEP 22'),
        topRight: _buildPill(
          s,
          'Finished',
          bg: blueCol,
          textCol: Colors.white,
          noBorder: true,
        ),
        tag: 'Endurance',
        title: 'Park Run',
        location: 'Ajman',
        distance: '5km',
        bottomRow: _buildRankRow(
          s,
          rankStr: '#--',
          total: '45',
          time: '45:20',
          isEye: true,
          outlineArrow: false,
        ),
      ),
      SizedBox(height: 16 * s),
      _CompetitionCard(
        s: s,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionDetailScreen(
                status: CompetitionStatus.completed,
                hasParticipated: false,
                customTitle: 'Downtown Dash',
                customImage: 'assets/challenge/challenge_24_main_9.png',
              ),
            ),
          );
        },
        bgImage: 'assets/challenge/challenge_24_main_9.png',
        topLeft: _buildIconPill(s, Icons.calendar_today, 'SEP 22'),
        topRight: _buildPill(
          s,
          'Finished',
          bg: blueCol,
          textCol: Colors.white,
          noBorder: true,
        ),
        tag: 'Sprint',
        title: 'Downtown Dash',
        location: 'Umm Al Quwain',
        distance: '100m',
        bottomRow: _buildRankRow(
          s,
          rankStr: '#--',
          total: '45',
          time: '45:20',
          isEye: true,
          outlineArrow: false,
        ),
      ),
    ];
  }

  // UTILITIES

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

  Widget _buildOutlinedButton(double s, String text, Color color) {
    return Container(
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
    );
  }

  Widget _buildRankRow(
    double s, {
    required String rankStr,
    required String total,
    required String time,
    required bool isEye,
    required bool outlineArrow,
  }) {
    final bool isDash = rankStr.contains('-');
    final Color rankColor = isDash ? Colors.white54 : themeGreen;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Rank',
              style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rankStr,
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: rankColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2 * s),
                  child: Text(
                    ' / $total',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(width: 24 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time',
              style: GoogleFonts.inter(fontSize: 9 * s, color: Colors.white54),
            ),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Spacer(),
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
        else if (outlineArrow)
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: themeGreen, width: 2),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: themeGreen,
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
              size: 18 * s,
            ),
          ),
      ],
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
  final Color? borderColor;
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
    this.borderColor,
    this.progressBar,
    this.midRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * s),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2 * s)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24 * s),
          child: Stack(
            children: [
              // BG Image Layer
              Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
              // Dark Gradient Layer Over bg
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
              // Content
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

                    // Under image details
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
                        if (midRight != null) ...[Spacer(), midRight!],
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

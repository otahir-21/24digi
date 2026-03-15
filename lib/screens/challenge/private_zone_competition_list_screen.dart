import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_detail_screen.dart';

/// The Private Zone competition list — Active / Upcoming / Completed tabs.
/// Shared card widget is re-used from competition_list_screen via _PZCard below.
class PrivateZoneCompetitionListScreen extends StatefulWidget {
  const PrivateZoneCompetitionListScreen({super.key});

  @override
  State<PrivateZoneCompetitionListScreen> createState() =>
      _PrivateZoneCompetitionListScreenState();
}

class _PrivateZoneCompetitionListScreenState
    extends State<PrivateZoneCompetitionListScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  int _selectedTab = 0; // 0=Active, 1=Upcoming, 2=Completed

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
                      SizedBox(height: 28 * s),
                      _buildSectionTitle(s),
                      SizedBox(height: 20 * s),
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(double s) {
    return Consumer<AuthProvider>(
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
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────────
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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

  // ── Section title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(double s) {
    final titles = [
      'Active Competitions',
      'Upcoming Competitions',
      'Past Competitions',
    ];
    return Text(
      titles[_selectedTab],
      style: GoogleFonts.inter(
        fontSize: 16 * s,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }

  // ── Tab content ──────────────────────────────────────────────────────────────
  Widget _buildTabContent(double s) {
    if (_selectedTab == 0) return Column(children: _buildActiveCards(s));
    if (_selectedTab == 1) return Column(children: _buildUpcomingCards(s));
    return Column(children: _buildCompletedCards(s));
  }

  // ── ACTIVE cards ─────────────────────────────────────────────────────────────
  List<Widget> _buildActiveCards(double s) {
    return [
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.live),
        bgImage: 'assets/challenge/challenge_24_main_1.png',
        topLeft: _pill(
          s,
          '2 h 15M LEFT',
          bg: Colors.white,
          textCol: Colors.black,
        ),
        topRight: _dotPill(s, 'Active Now', themeGreen),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        bottomRow: _outlinedButton(s, 'Join Now', const Color(0xFF00E5FF)),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.live),
        bgImage: 'assets/challenge/challenge_24_main_2.png',
        topLeft: _iconPill(s, Icons.calendar_today, 'OCT 12'),
        topRight: _dotPill(s, 'Active Now', themeGreen),
        tag: 'High Intensity',
        title: 'Jabal al Hafeet cycling',
        location: 'Al Ain',
        distance: '20km',
        bottomRow: _rankRow(
          s,
          rankStr: '#14',
          total: '20',
          time: '45:20',
          isEye: false,
          outlineArrow: false,
        ),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.live),
        bgImage: 'assets/challenge/challenge_24_main_3.png',
        borderColor: Colors.redAccent,
        topLeft: _pill(
          s,
          'Ending Soon',
          bg: Colors.redAccent,
          textCol: Colors.white,
          noBorder: true,
        ),
        topRight: _pill(
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
        bottomRow: _rankRow(
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

  // ── UPCOMING cards ───────────────────────────────────────────────────────────
  List<Widget> _buildUpcomingCards(double s) {
    const blueCol = Color(0xFF42A5F5);
    return [
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.upcoming),
        bgImage: 'assets/challenge/challenge_24_main_4.png',
        topLeft: _pill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white,
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _dotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _outlinedTag(s, '128 interested', Colors.orangeAccent),
        bottomRow: _outlinedButton(s, 'Details', blueCol),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.upcoming),
        bgImage: 'assets/challenge/challenge_24_main_5.png',
        borderColor: blueCol,
        topLeft: _pill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white,
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _dotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _outlinedTag(s, '78 interested', Colors.orangeAccent),
        bottomRow: _outlinedButton(s, 'Details', blueCol),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.upcoming),
        bgImage: 'assets/challenge/challenge_24_main_6.png',
        topLeft: _pill(
          s,
          'Start in 2 h 15M',
          bg: Colors.white,
          textCol: Colors.black,
          noBorder: true,
        ),
        topRight: _dotPill(s, 'Soon', blueCol),
        tag: 'Endurance',
        title: 'Track Running',
        location: 'Umm Al Quwain',
        distance: '10km',
        midRight: _outlinedTag(s, '128 interested', Colors.orangeAccent),
        bottomRow: _outlinedButton(s, 'Details', blueCol),
      ),
    ];
  }

  // ── COMPLETED cards ──────────────────────────────────────────────────────────
  List<Widget> _buildCompletedCards(double s) {
    const blueCol = Color(0xFF42A5F5);
    return [
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.completed),
        bgImage: 'assets/challenge/challenge_24_main_7.png',
        topLeft: _iconPill(s, Icons.calendar_today, 'OCT 12'),
        topRight: _pill(
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
        bottomRow: _rankRow(
          s,
          rankStr: '#5',
          total: '45',
          time: '45:20',
          isEye: false,
          outlineArrow: true,
        ),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => _pushDetail(CompetitionStatus.completed),
        bgImage: 'assets/challenge/challenge_24_main_8.png',
        topLeft: _iconPill(s, Icons.calendar_today, 'SEP 22'),
        topRight: _pill(
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
        bottomRow: _rankRow(
          s,
          rankStr: '#--',
          total: '45',
          time: '45:20',
          isEye: true,
          outlineArrow: false,
        ),
      ),
      SizedBox(height: 16 * s),
      _PZCard(
        s: s,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CompetitionDetailScreen(
              status: CompetitionStatus.completed,
              hasParticipated: false,
              customTitle: 'Downtown Dash',
              customImage: 'assets/challenge/challenge_24_main_9.png',
            ),
          ),
        ),
        bgImage: 'assets/challenge/challenge_24_main_9.png',
        topLeft: _iconPill(s, Icons.calendar_today, 'SEP 22'),
        topRight: _pill(
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
        bottomRow: _rankRow(
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

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _pushDetail(CompetitionStatus status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailScreen(status: status),
      ),
    );
  }

  Widget _pill(
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

  Widget _dotPill(double s, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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

  Widget _iconPill(double s, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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

  Widget _outlinedTag(double s, String text, Color color) {
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

  Widget _outlinedButton(double s, String text, Color color) {
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

  Widget _rankRow(
    double s, {
    required String rankStr,
    required String total,
    required String time,
    required bool isEye,
    required bool outlineArrow,
  }) {
    final isDash = rankStr.contains('-');
    final rankColor = isDash ? Colors.white54 : themeGreen;

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

// ── Competition card widget (private-zone variant) ────────────────────────────
class _PZCard extends StatelessWidget {
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

  const _PZCard({
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
              // Background image
              Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
              // Dark scrim
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.88),
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
                    // Tag pill
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

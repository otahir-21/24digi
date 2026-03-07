import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'profile_setting_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── TOP HEADER (Logo + Back) ──
            _buildTopHeader(s),

            // ── PROFILE INFO ──
            _buildProfileInfo(s),

            SizedBox(height: 10 * s),

            // ── SETTINGS BUTTON ──
            _buildSettingsButton(s),

            SizedBox(height: 24 * s),

            // ── BIO SECTION ──
            _buildBioSection(s),

            SizedBox(height: 24 * s),

            // ── LEVEL PROGRESS ──
            _buildLevelProgress(s),

            SizedBox(height: 24 * s),

            // ── DIGI POINTS ──
            _buildDigiPoints(s),

            SizedBox(height: 24 * s),

            // ── STATS ROW ──
            _buildStatsRow(s),

            SizedBox(height: 24 * s),

            // ── COMPETITION / TROPHIES ──
            _buildTrophySection(s),

            SizedBox(height: 24 * s),

            // ── RECENT ACTIVITY ──
            _buildRecentActivity(s),

            SizedBox(height: 24 * s),

            // ── BRACELET CONNECTION ──
            _buildBraceletSection(s),

            SizedBox(height: 32 * s),

            // ── QUICK SETTINGS ──
            _buildQuickSettings(s),

            SizedBox(height: 40 * s),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 60 * s, 16 * s, 20 * s),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/circuit.png'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2329),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: const Color(0xFF00F0FF),
                    size: 28 * s,
                  ),
                ),
              ),
              const SizedBox(width: 44), // Placeholder to balance stack
            ],
          ),
          Image.asset(
            'assets/24 logo.png',
            width: 100 * s,
            fit: BoxFit.contain,
            color: Colors.blueAccent.withOpacity(0.8),
            colorBlendMode: BlendMode.srcIn,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(double s) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer glow ring
            Container(
              width: 140 * s,
              height: 140 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00F0FF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Avatar image
            Container(
              width: 120 * s,
              height: 120 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F0FF), width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/fonts/male.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // Online indicator dot
            Positioned(
              right: 15 * s,
              top: 15 * s,
              child: Container(
                width: 14 * s,
                height: 14 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D1217), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Badge at bottom
            Positioned(
              bottom: -10 * s,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2329),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF00F0FF),
                      size: 10,
                    ),
                    SizedBox(width: 4 * s),
                    Text(
                      'ELITE II',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24 * s),
        Text(
          'Khalfan',
          style: GoogleFonts.inter(
            fontSize: 28 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white54,
              size: 14,
            ),
            SizedBox(width: 4 * s),
            Text(
              'Dubai, UAE',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsButton(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSettingScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 16 * s),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings, color: Color(0xFF00F0FF), size: 18),
            SizedBox(width: 8 * s),
            Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withOpacity(0.5),
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
                'Bio',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF00F0FF),
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            'Health & sports enthusiast dedicated to building strength, and continuous self-improvement.',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF00F0FF),
                        size: 16,
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        'Level Progress',
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    '1,250 / 2,500 XP to Level 38',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 50 * s,
                height: 50 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF13181D),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BAFF).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '37',
                  style: GoogleFonts.outfit(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 14 * s,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10 * s),
                ),
              ),
              Container(
                height: 14 * s,
                width: 150 * s, // Adjusted percentage
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFF00BAFF)],
                  ),
                  borderRadius: BorderRadius.circular(10 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 XP',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white38,
                ),
              ),
              Text(
                '2,500 XP',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigiPoints(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 4 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'DIGI POINTS',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00F0FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 12 * s),
                Text(
                  '4,500',
                  style: GoogleFonts.outfit(
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'Top 5% of all players',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/profile/profile_digi_point.png',
            height: 100 * s,
            width: 100 * s,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => SizedBox(
              width: 100 * s,
              height: 100 * s,
              child: const Icon(
                Icons.stars,
                color: Color(0xFF00F0FF),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBox(s, '142', 'Wins', Icons.emoji_events_outlined),
          _buildStatBox(s, '2,380', 'Followers', Icons.group_outlined),
          _buildStatBox(
            s,
            '28d',
            'Streak',
            Icons.local_fire_department_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(double s, String value, String label, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60 * s) / 3,
      padding: EdgeInsets.symmetric(vertical: 20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 24 * s),
          SizedBox(height: 12 * s),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySection(double s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrophyItem(
              s,
              '1',
              const Color(0xFFFFB061),
              'Competition Name',
            ),
            SizedBox(width: 14 * s),
            _buildTrophyItem(
              s,
              '2',
              const Color(0xFF6DE8FF),
              'Competition Name A',
            ),
            SizedBox(width: 14 * s),
            _buildTrophyItem(
              s,
              '3',
              const Color(0xFFFFB161).withOpacity(0.6),
              'Competitor B',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyItem(double s, String rank, Color color, String name) {
    return Column(
      children: [
        Container(
          width: 100 * s,
          height: 130 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2329).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: GoogleFonts.outfit(
                  fontSize: 40 * s,
                  fontWeight: FontWeight.w900,
                  color: color.withOpacity(0.3),
                ),
              ),
              Icon(Icons.military_tech_outlined, size: 50 * s, color: color),
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        SizedBox(
          width: 100 * s,
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white54),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF00F0FF), size: 18),
              SizedBox(width: 10 * s),
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          _activityItem(
            s,
            Icons.workspace_premium,
            'Won Championship 2025',
            '2h ago',
            const Color(0xFFFFB061),
          ),
          _activityItem(
            s,
            Icons.trending_up,
            'Reached Level 37',
            '1d ago',
            const Color(0xFF00F0FF),
          ),
          _activityItem(
            s,
            Icons.groups_3_rounded,
            'Joined Team Nexus',
            '3d ago',
            const Color(0xFFB161FF),
          ),
          _activityItem(
            s,
            Icons.star_outline,
            'Earned Elite II badge',
            '1w ago',
            const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(
    double s,
    IconData icon,
    String title,
    String time,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24 * s),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildBraceletSection(double s) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * s),
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth,
                  color: Color(0xFF00F0FF),
                  size: 24,
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '24DIGI Bracelet',
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4 * s),
                        const Icon(Icons.wifi, color: Colors.white24, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Connected',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          Container(
            padding: EdgeInsets.all(18 * s),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(18 * s),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST SYNC',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        color: Colors.white24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2 mins ago',
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.battery_4_bar_sharp,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '94%',
                          style: GoogleFonts.inter(
                            fontSize: 16 * s,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '5 days',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * s),
          Container(
            width: double.infinity,
            height: 50 * s,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00F0FF).withOpacity(0.1),
                  const Color(0xFF1E7268).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(
                color: const Color(0xFF00F0FF).withOpacity(0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Manage Device',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00F0FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Text(
            'Quick Settings',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 20 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20 * s),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16 * s,
            crossAxisSpacing: 16 * s,
            childAspectRatio: 1.4,
            children: [
              _settingCard(
                s,
                Icons.lock_outline,
                'Security',
                '2FA & passwords',
              ),
              _settingCard(s, Icons.cloud_outlined, 'Data', 'Export & privacy'),
              _settingCard(s, Icons.help_outline, 'Help', 'Support center'),
              _settingCard(
                s,
                Icons.logout,
                'Logout',
                'Sign out safely',
                isAction: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingCard(
    double s,
    IconData icon,
    String title,
    String sub, {
    bool isAction = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAction
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isAction ? Colors.redAccent : const Color(0xFF00F0FF),
              size: 18,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              color: isAction ? Colors.redAccent : Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            sub,
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

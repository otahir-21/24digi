import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'private_zone_competition_list_screen.dart';

/// Standalone "24 Private Zone — Competition General" page.
/// Completely separate from the 24 Challenge flow.
class PrivateZoneGeneralScreen extends StatelessWidget {
  const PrivateZoneGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeGreen = const Color(0xFF00FF88);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16 * s),
                      _buildHeader(s),
                      SizedBox(height: 32 * s),

                      Text(
                        'Want to compete?',
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Join an active sponsored challenge\nbelow.',
                        style: GoogleFonts.inter(
                          fontSize: 13 * s,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 20 * s),

                      // "Join a Competition" → Private Zone competition list
                      _buildJoinButton(context, s, themeGreen),

                      SizedBox(height: 32 * s),
                      Text(
                        'Want to create a challenge?',
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Sponsor a competition and reach thousands of active\nusers.',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 24 * s),
                      _buildInfoCard(context, s, themeGreen),
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

  // ── Header ───────────────────────────────────────────────────────────────────
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
            '24 COMPETITIONS',
            style: GoogleFonts.outfit(
              fontSize: 26 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Join button → PrivateZoneCompetitionListScreen ───────────────────────────
  Widget _buildJoinButton(BuildContext context, double s, Color themeGreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PrivateZoneCompetitionListScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: themeGreen,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          'Join a Competition',
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context, double s, Color themeGreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20 * s),
            child: Text(
              'Sponsored Challenges',
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.all(20 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official, sponsor-backed fitness\ncompetitions with rewards.',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12 * s),
                Text(
                  '24 Competitions are large-scale fitness challenges\ncreated by verified sponsors such as brands, institutions,\nor organizations.\nThese challenges unite thousands of users around a\nshared goal—turning real physical activity into rankings,\nrewards, and recognition.',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20 * s),

                _buildInfoSection(
                  s,
                  'Sponsor-Created',
                  'Challenges are designed and funded by approved\nsponsors, not individual users.',
                ),
                SizedBox(height: 16 * s),

                _buildInfoSection(
                  s,
                  'Mass Participation',
                  'Open to large audiences with unified rules, live\nleaderboards, and global rankings.',
                ),
                SizedBox(height: 16 * s),

                _buildInfoSection(
                  s,
                  'Real Rewards',
                  'Earn points, exclusive medals, and sponsor-backed\nprizes based on verified activity.',
                ),
                SizedBox(height: 16 * s),

                _buildInfoSection(
                  s,
                  '1. Sponsors define the challenge',
                  'Rules, duration, objectives, and rewards are set and\napproved.',
                ),
                SizedBox(height: 16 * s),

                _buildInfoSection(
                  s,
                  '2. Users join and compete',
                  'Your real-world activity is tracked and ranked in real\ntime.',
                ),
                SizedBox(height: 16 * s),

                _buildInfoSection(
                  s,
                  '3. Winners earn recognition',
                  'Top performers receive points, medals, and sponsor\nrewards.',
                ),

                SizedBox(height: 32 * s),

                // "Sponsor a Competition" — same visual, stays within PZ flow
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13181D),
                      borderRadius: BorderRadius.circular(16 * s),
                      border: Border.all(color: themeGreen, width: 1.5 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Sponsor a Competition',
                      style: GoogleFonts.outfit(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(double s, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

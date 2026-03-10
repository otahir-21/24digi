import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

/// Member List: search, Requests (+4), Administrators (OWNER/ADMIN), Members (Sort by level), Loading more.
class AdventureMembersScreen extends StatefulWidget {
  final String roomName;

  const AdventureMembersScreen({
    super.key,
    this.roomName = 'Elite Runners Club',
  });

  @override
  State<AdventureMembersScreen> createState() => _AdventureMembersScreenState();
}

class _AdventureMembersScreenState extends State<AdventureMembersScreen> {
  final Color themeGreen = const Color(0xFFE0A10A);
  final Color bgDark = const Color(0xFF2E251E);
  int? _removeIndex;

  static const _admins = [
    ('Khalfan', 'Level 99', 'Elite class', 'OWNER'),
    ('Khalfan', 'Level 99', 'Elite class', 'ADMIN'),
  ];

  static const _members = [
    ('Khalfan', 'Level 99', 'Elite class'),
    ('Khalfan', 'Level 99', 'Elite class'),
    ('Khalfan', 'Level 99', 'Elite class'),
    ('Khalfan', 'Level 99', 'Elite class'),
    ('Khalfan', 'Level 99', 'Elite class'),
  ];

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
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8 * s),
                    _buildSearchBar(s),
                    SizedBox(height: 20 * s),
                    _buildRequests(s),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle(s, 'Administrators'),
                    SizedBox(height: 12 * s),
                    ..._admins.asMap().entries.map(
                      (e) => _buildAdminRow(
                        s,
                        e.key,
                        e.value.$1,
                        e.value.$2,
                        e.value.$3,
                        e.value.$4,
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    _buildMembersHeader(s),
                    SizedBox(height: 12 * s),
                    ..._members.asMap().entries.map(
                      (e) => _buildMemberRow(
                        s,
                        e.key,
                        e.value.$1,
                        e.value.$2,
                        e.value.$3,
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    Center(
                      child: Text(
                        'Loading more players....',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double s) {
    return Container(
      height: 44 * s,
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4039),
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20 * s, color: Colors.white38),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              'Find a player by name or rank...',
              style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequests(double s) {
    return Row(
      children: [
        SizedBox(
          width: 70 * s,
          height: 36 * s,
          child: Stack(
            children: [
              Positioned(left: 0, child: _avatar(s, 32)),
              Positioned(left: 18 * s, child: _avatar(s, 32)),
              Positioned(left: 36 * s, child: _avatar(s, 32)),
            ],
          ),
        ),
        SizedBox(width: 10 * s),
        Container(
          width: 28 * s,
          height: 28 * s,
          decoration: BoxDecoration(color: themeGreen, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            '+4',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        Text(
          'Requests',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _avatar(double s, double size) {
    return Container(
      width: size * s,
      height: size * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: bgDark, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/fonts/male.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(double s, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14 * s,
        fontWeight: FontWeight.w700,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildAdminRow(
    double s,
    int index,
    String name,
    String level,
    String cls,
    String tag,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        children: [
          _avatar(s, 44),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '$level • $cls',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              color: themeGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: themeGreen, width: 1),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w800,
                color: themeGreen,
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          Icon(Icons.more_vert, color: Colors.white54, size: 22 * s),
        ],
      ),
    );
  }

  Widget _buildMembersHeader(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(s, 'Members'),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Sort by level',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: themeGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberRow(
    double s,
    int index,
    String name,
    String level,
    String cls,
  ) {
    final showRemove = _removeIndex == index;

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        children: [
          _avatar(s, 44),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '$level • $cls',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (showRemove)
            GestureDetector(
              onTap: () => setState(() => _removeIndex = null),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10 * s),
                  border: Border.all(color: const Color(0xFFE53935), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: const Color(0xFFE53935),
                      size: 18 * s,
                    ),
                    SizedBox(width: 4 * s),
                    Text(
                      'Remove',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _removeIndex = index),
              child: Icon(Icons.more_vert, color: Colors.white54, size: 22 * s),
            ),
        ],
      ),
    );
  }
}

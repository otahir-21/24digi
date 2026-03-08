import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeTeal = const Color(0xFF00D186);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * s),
                    _buildTitleSection(s, themeTeal),
                    SizedBox(height: 32 * s),
                    _buildMadeWithLoveCard(s, themeTeal),
                    SizedBox(height: 32 * s),
                    _buildSectionHeader(
                      'THE TEAM',
                      Icons.group,
                      const Color(0xFFFFB061),
                      s,
                    ),
                    SizedBox(height: 16 * s),
                    _buildTeamList(s),
                    SizedBox(height: 32 * s),
                    _buildSectionHeader(
                      'SPECIAL THANKS',
                      Icons.auto_awesome,
                      const Color(0xFFFF61A6),
                      s,
                    ),
                    SizedBox(height: 16 * s),
                    _buildSpecialThanks(s),
                    SizedBox(height: 32 * s),
                    _buildOpenSourceHeader(s, const Color(0xFF00D186)),
                    SizedBox(height: 16 * s),
                    _buildOpenSourceLibraries(s),
                    SizedBox(height: 48 * s),
                    _buildFooter(s),
                    SizedBox(height: 32 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(double s, Color themeTeal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.workspace_premium_outlined, color: themeTeal, size: 28 * s),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Licenses & Credits',
                style: GoogleFonts.inter(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                'Built with amazing open source',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMadeWithLoveCard(double s, Color themeTeal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: themeTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16 * s),
            ),
            child: Icon(Icons.favorite_border, color: themeTeal, size: 28 * s),
          ),
          SizedBox(height: 20 * s),
          Text(
            'Made with Love',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            '24DIGI is built on the shoulders of incredible projects and an amazing contributors.',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    double s,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14 * s),
        SizedBox(width: 8 * s),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenSourceHeader(double s, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.code, color: color, size: 14 * s),
            SizedBox(width: 8 * s),
            Text(
              'OPEN SOURCE LIBRARIES',
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12 * s),
          ),
          child: Text(
            '12 packages',
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamList(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildTeamItem('The 24DIGI Core Team', 'LEAD ENGINEER', s),
          _buildTeamItem('24DIGI Design Studio', 'UI/UX DESIGN', s),
          _buildTeamItem(
            'Certified Health Professionals',
            'FITNESS ADVISORY',
            s,
          ),
          _buildTeamItem(
            'Our amazing users & beta testers',
            'COMMUNITY',
            s,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamItem(
    String name,
    String role,
    double s, {
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            role,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialThanks(double s) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        'To all our beta testers who helped shape 24DIGI from day one. To the open-source community for building the incredible tools that power this app. And to every warrior who uses 24DIGI to push their limits every single day.',
        style: GoogleFonts.inter(
          fontSize: 13 * s,
          color: Colors.white54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildOpenSourceLibraries(double s) {
    final List<Map<String, dynamic>> libs = [
      {
        'name': 'React',
        'version': 'v18.2.0',
        'desc': 'A JavaScript library for building user interfaces',
        'license': 'MIT',
        'author': 'Meta Platforms, Inc.',
      },
      {
        'name': 'Tailwind CSS',
        'version': 'v3.3.6',
        'desc': 'A utility-first CSS framework',
        'license': 'MIT',
        'author': 'Tailwind Labs, Inc.',
      },
      {
        'name': 'Radix UI',
        'version': '1.x',
        'desc': 'Unstyled, accessible UI components',
        'license': 'MIT',
        'author': 'WorkOS',
      },
      {
        'name': 'Lucide Icons',
        'version': '0.301.0',
        'desc': 'Beautiful & consistent icon toolkit',
        'license': 'ISC',
        'author': 'Lucide Contributors',
      },
      {
        'name': 'Motion',
        'version': '10.x',
        'desc': 'Production-ready motion library for React',
        'license': 'MIT',
        'author': 'Matt Perry',
      },
      {
        'name': 'Sonner',
        'version': '0.10.8',
        'desc': 'An opinionated toast component for React',
        'license': 'MIT',
        'author': 'Emil Kowalski',
      },
      {
        'name': 'React Router',
        'version': 'v6.20.0',
        'desc': 'Declarative routing for React',
        'license': 'MIT',
        'author': 'Remix Software',
      },
      {
        'name': 'Recharts',
        'version': '2.10.3',
        'desc': 'Composable charting library for React',
        'license': 'MIT',
        'author': 'Recharts Group',
      },
      {
        'name': 'date-fns',
        'version': '2.30.0',
        'desc': 'Modern JavaScript date utility library',
        'license': 'MIT',
        'author': 'Sasha Koss',
      },
      {
        'name': 'class-variance-authority',
        'version': 'v0.7.0',
        'desc': 'CSS-in-TS class variant management',
        'license': 'Apache-2.0',
        'author': 'Joe Bell',
      },
      {
        'name': 'clsx',
        'version': '2.1.0',
        'desc': 'Utility for constructing className strings',
        'license': 'MIT',
        'author': 'Luke Edwards',
      },
      {
        'name': 'Vite',
        'version': '5.0.0',
        'desc': 'Next generation frontend tooling',
        'license': 'MIT',
        'author': 'Evan You',
      },
    ];

    return Column(
      children: libs.map((lib) => _buildLibraryItem(lib, s)).toList(),
    );
  }

  Widget _buildLibraryItem(Map<String, dynamic> lib, double s) {
    final themeTeal = const Color(0xFF00D186);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.view_in_ar_outlined,
                color: const Color(0xFF00F0FF),
                size: 16 * s,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lib['name'],
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          lib['version'],
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      lib['desc'],
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * s,
                            vertical: 2 * s,
                          ),
                          decoration: BoxDecoration(
                            color: themeTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6 * s),
                            border: Border.all(
                              color: themeTeal.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            lib['license'],
                            style: GoogleFonts.inter(
                              fontSize: 9 * s,
                              fontWeight: FontWeight.w700,
                              color: themeTeal,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          lib['author'],
                          style: GoogleFonts.inter(
                            fontSize: 11 * s,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.white12, size: 14 * s),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double s) {
    return Center(
      child: Column(
        children: [
          Text(
            '24DIGI v1.0.0 (BUILD 450)',
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white24),
          ),
          SizedBox(height: 4 * s),
          Text(
            '© 2026 24DIGI. All rights reserved.',
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

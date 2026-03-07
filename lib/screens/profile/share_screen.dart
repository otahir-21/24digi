import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themePink = const Color(0xFFFF2E93);

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
                    _buildTitleSection(s, themePink),
                    SizedBox(height: 24 * s),
                    _buildReferralCard(s, themePink),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('SHARE VIA', s),
                    SizedBox(height: 16 * s),
                    _buildShareGrid(s),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('REFERRAL REWARDS', s),
                    SizedBox(height: 16 * s),
                    _buildRewardsList(s),
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

  Widget _buildTitleSection(double s, Color themePink) {
    return Row(
      children: [
        Icon(Icons.share_outlined, color: themePink, size: 28 * s),
        SizedBox(width: 16 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share 24DIGI',
              style: GoogleFonts.inter(
                fontSize: 20 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              'Recruit warriors, earn rewards',
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralCard(double s, Color themePink) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32 * s, horizontal: 24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: themePink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20 * s),
            ),
            child: Icon(Icons.card_giftcard, color: themePink, size: 36 * s),
          ),
          SizedBox(height: 24 * s),
          Text(
            'Invite Friends & Earn Rewards',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * s),
          Text(
            'Share your referral link and both you and your friend get bonus XP',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * s),
          // Code Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16 * s, horizontal: 16 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2228),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Column(
              children: [
                Text(
                  'YOUR REFERRAL CODE',
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ALEX-24D-W42',
                      style: GoogleFonts.orbitron(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w700,
                        color: themePink,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    Container(
                      padding: EdgeInsets.all(8 * s),
                      decoration: BoxDecoration(
                        color: themePink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8 * s),
                      ),
                      child: Icon(Icons.copy, color: themePink, size: 16 * s),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, color: Colors.white38, size: 16 * s),
              SizedBox(width: 8 * s),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                  children: [
                    TextSpan(
                      text: '2 ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(text: 'warriors recruited'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text, double s) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10 * s,
        fontWeight: FontWeight.w800,
        color: Colors.white38,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildShareGrid(double s) {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Copy Link',
        'icon': Icons.copy,
        'color': const Color(0xFF00D186),
      },
      {
        'label': 'Message',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF3B82F6),
      },
      {
        'label': 'Twitter / X',
        'icon': Icons.flutter_dash,
        'color': const Color(0xFF00F0FF),
      },
      {
        'label': 'Email',
        'icon': Icons.mail_outline,
        'color': const Color(0xFFFFB000),
      },
      {
        'label': 'QR Code',
        'icon': Icons.qr_code,
        'color': const Color(0xFFB161FF),
      },
      {
        'label': 'More Options',
        'icon': Icons.share_outlined,
        'color': const Color(0xFFFF2E93),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16 * s,
        crossAxisSpacing: 16 * s,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.05),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: item['color'].withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'], color: item['color'], size: 20 * s),
              SizedBox(height: 8 * s),
              Text(
                item['label'],
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w600,
                  color: item['color'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsList(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildRewardItem(
            s,
            title: '500 XP Boost',
            subtitle: 'Invite 1 friend',
            icon: Icons.bolt,
            iconColor: const Color(0xFF00D186),
            trailingWidget: _buildStatusPill(
              s,
              'UNLOCKED',
              const Color(0xFF00D186),
            ),
            showBorder: true,
            isActive: true,
          ),
          _buildRewardItem(
            s,
            title: 'Recruiter Badge',
            subtitle: 'Invite 3 friends',
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.white24,
            trailingWidget: _buildStatusPill(s, '2/3', Colors.white24),
            showBorder: true,
            isActive: false,
          ),
          _buildRewardItem(
            s,
            title: '1 Week Premium',
            subtitle: 'Invite 5 friends',
            icon: Icons.card_giftcard,
            iconColor: Colors.white24,
            trailingWidget: _buildStatusPill(s, '2/5', Colors.white24),
            showBorder: false,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    double s, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget trailingWidget,
    required bool showBorder,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20 * s),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.white54,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          trailingWidget,
        ],
      ),
    );
  }

  Widget _buildStatusPill(double s, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

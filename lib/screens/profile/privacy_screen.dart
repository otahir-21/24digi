import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themePurple = const Color(0xFFB161FF);
    final themeTeal = const Color(0xFF00D186);
    final themeBlue = const Color(0xFF00F0FF);
    final themePink = const Color(0xFFFF2E93);
    final themeOrange = const Color(0xFFFFB061);

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
                    _buildTitleSection(s),
                    SizedBox(height: 24 * s),
                    Center(child: _buildEffectivePill(s)),
                    SizedBox(height: 24 * s),
                    _buildIntroCard(s, themePurple),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Information We Collect',
                      Icons.storage,
                      themeBlue,
                      [
                        'Account information: name, email, date of birth, gender, profile photo',
                        'Health & fitness data: height, weight, blood type, activity metrics, step counts, calories, sleep patterns, hydration logs',
                        'Device data: device model, OS version, unique identifiers, motion sensor data',
                        'Usage data: app interactions, feature usage, session duration, crash reports',
                        'Location data: only when explicitly granted permission for route tracking',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'How We Use Your Data',
                      Icons.visibility_outlined,
                      themePurple,
                      [
                        'Provide and personalize your fitness tracking experience',
                        'Calculate health insights, XP, achievements, and progress analytics',
                        'Send notifications, reminders, and weekly summaries (with your consent)',
                        'Improve our algorithms and app performance through anonymized analytics',
                        'Ensure platform security and prevent fraud or abuse',
                        'Comply with legal obligations and respond to lawful requests',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Data Security',
                      Icons.lock_outline,
                      themeTeal,
                      [
                        'All data is encrypted in transit (TLS 1.3) and at rest (AES-256)',
                        'Health data is stored in isolated, encrypted databases',
                        'We employ SOC 2 Type II certified infrastructure',
                        'Regular penetration testing and security audits by third parties',
                        'Two-factor authentication available for all accounts',
                        'Biometric authentication (Face ID / Touch ID) supported for app access',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Data Sharing',
                      Icons.people_outline,
                      const Color(0xFF3B82F6),
                      [
                        'We never sell your personal health data to third parties',
                        'Data may be shared with service providers who assist in operating the App (under strict confidentiality agreements)',
                        'Aggregated, anonymized data may be used for research and analytics',
                        'Connected third-party apps receive only the data you explicitly authorize',
                        'We may disclose data if required by law or to protect safety',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'International Transfers',
                      Icons.language,
                      themeOrange,
                      [
                        'Your data may be transferred to and processed in countries outside your residence',
                        'We use Standard Contractual Clauses (SCCs) for EU data transfers',
                        'All transfers comply with GDPR, CCPA, and applicable privacy laws',
                        'Data processing locations include EU, US, and selected cloud regions',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Your Rights',
                      Icons.verified_user_outlined,
                      const Color(0xFFFFB000),
                      [
                        'Access: Request a copy of all personal data we hold about you',
                        'Rectification: Correct inaccurate personal data at any time',
                        'Deletion: Request permanent deletion of your account and data',
                        'Portability: Download your data in standard formats (JSON/CSV)',
                        'Restriction: Limit how we process your data',
                        'Objection: Opt out of data processing for marketing purposes',
                        'Withdrawal: Revoke consent at any time without affecting lawfulness of prior processing',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Cookies & Tracking',
                      Icons.cookie_outlined,
                      themePink,
                      [
                        'We use essential cookies for authentication and session management',
                        'Analytics cookies help us understand app usage patterns (anonymized)',
                        'You can manage cookie preferences in your browser settings',
                        'We do not use third-party advertising trackers',
                        'Push notification tokens are stored for delivering alerts you\'ve opted into',
                      ],
                    ),
                    SizedBox(height: 24 * s),
                    _buildPolicySection(
                      s,
                      'Data Retention & Deletion',
                      Icons.delete_outline,
                      Colors.redAccent,
                      [
                        'Active account data is retained for the lifetime of your account',
                        'Deleted accounts are purged within 30 days of deletion request',
                        'Backup copies are removed within 90 days of account deletion',
                        'Anonymized analytics data may be retained indefinitely',
                        'Legal compliance data is retained for required statutory periods',
                      ],
                    ),
                    SizedBox(height: 48 * s),
                    _buildFooter(s, themePurple),
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

  Widget _buildTitleSection(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.privacy_tip_outlined,
          color: const Color(0xFFB161FF),
          size: 28 * s,
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: GoogleFonts.inter(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                'How we protect your data',
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

  Widget _buildEffectivePill(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: const Color(0xFFB161FF),
            size: 14 * s,
          ),
          SizedBox(width: 8 * s),
          Text(
            'Effective: February 1, 2026',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(double s, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: themeColor, size: 18 * s),
              SizedBox(width: 12 * s),
              Text(
                'Your privacy is our mission',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            'At 24DIGI, we believe your health data is sacred. This policy explains what we collect, how we use it, and the powerful controls you have over your information.',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(
    double s,
    String title,
    IconData icon,
    Color themeColor,
    List<String> points,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * s),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeColor, size: 16 * s),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          ...points.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6 * s),
                    width: 4 * s,
                    height: 4 * s,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFooter(double s, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            'Questions about your data or privacy?',
            style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white38),
          ),
          SizedBox(height: 4 * s),
          Text(
            'privacy@24digi.app',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Data Protection Officer: dpo@24digi.app',
            style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

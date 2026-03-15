import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/challenge/share_activity_card_screen.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

enum AlertType { quit, notify, join_success, share }

class CompetitionSystemAlertScreen extends StatelessWidget {
  final AlertType alertType;
  final String? competitionName; // Provide the name for notify logic

  const CompetitionSystemAlertScreen({
    super.key,
    required this.alertType,
    this.competitionName,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            SizedBox(height: 16 * s),
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
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: _buildAlertCard(s, context),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 24 * s),
              child: Text(
                'System Alert',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(double s, BuildContext context) {
    Color color = const Color(0xFF5CE1E6);
    IconData alertIcon = Icons.notifications_none_rounded;
    String mainTitle = 'Notification Set!';

    if (alertType == AlertType.quit) {
      color = const Color(0xFFFF6961);
      alertIcon = Icons.warning_amber_rounded;
      mainTitle = 'Are you sure you\nwant to quit?';
    } else if (alertType == AlertType.join_success) {
      color = const Color(0xFF00FF88);
      alertIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 40 * s),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5 * s),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Icon Circle
          Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2 * s),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 24 * s,
                  spreadRadius: 2 * s,
                ),
              ],
            ),
            child: Icon(alertIcon, color: color, size: 40 * s),
          ),
          SizedBox(height: 32 * s),
          Text(
            mainTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16 * s),
          if (alertType == AlertType.quit) ...[
            Text(
              'You will forfeit your progress, rank,\nand any potential rewards for this\ncompetition.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24 * s),
            Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 32 * s),
            _buildSolidButton(s, 'Confirm Quit', color, () {
              Navigator.pop(context, true);
            }),
            SizedBox(height: 16 * s),
            _buildOutlineButton(s, 'Cancel', color, () {
              Navigator.pop(context);
            }),
          ] else if (alertType == AlertType.join_success) ...[
            Text(
              'Join Successful!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            SizedBox(height: 16 * s),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'You have been successfully added to\n'),
                  TextSpan(
                    text: '"${competitionName ?? 'Competition Name'}"',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48 * s),
            _buildSolidButton(s, 'Continue', color, () {
              Navigator.pop(context);
            }),
          ] else if (alertType == AlertType.share) ...[
            Text(
              'Spread the word and invite your friends to compete with you!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            SizedBox(height: 48 * s),
            _buildSolidButton(s, 'Share with Friends', color, () {
              // Handle actual share logic here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShareActivityCardScreen()),
              );
            }),
            SizedBox(height: 16 * s),
            _buildOutlineButton(s, 'Download Result Image', color, () {
              Navigator.pop(context);
            }),
          ] else ...[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text:
                        'You\'re on the list. we\'ll ping you as\nsoon as registration opens for the\n',
                  ),
                  TextSpan(
                    text: '"${competitionName ?? 'Competition Name'}"',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48 * s),
            _buildSolidButton(s, 'Got It!', color, () {
              Navigator.pop(context);
            }),
            SizedBox(height: 24 * s),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                'View Competition Details',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolidButton(
    double s,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: color == const Color(0xFF5CE1E6)
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
    double s,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

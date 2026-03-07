import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _selectedTopic = '';

  final List<Map<String, dynamic>> _topics = [
    {'label': 'Bug Report', 'icon': Icons.bug_report_outlined},
    {'label': 'Billing', 'icon': Icons.credit_card_outlined},
    {'label': 'General', 'icon': Icons.help_outline},
    {'label': 'Feature Idea', 'icon': Icons.lightbulb_outline},
    {'label': 'Security', 'icon': Icons.shield_outlined},
  ];

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
                    SizedBox(height: 24 * s),
                    _buildQuickTip(s, themeTeal),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('WHAT\'S THIS ABOUT?', s),
                    SizedBox(height: 16 * s),
                    _buildTopicGrid(s, themeTeal),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('YOUR EMAIL', s),
                    SizedBox(height: 12 * s),
                    _buildTextField(
                      s,
                      hintText: 'User@email.com',
                      prefixIcon: Icons.mail_outline,
                    ),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle('SUBJECT', s),
                    SizedBox(height: 12 * s),
                    _buildTextField(
                      s,
                      hintText: 'Brief description of your issue',
                    ),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle('MESSAGE', s),
                    SizedBox(height: 12 * s),
                    _buildTextField(
                      s,
                      hintText:
                          'Describe your issue in detail. Include steps to reproduce if it\'s a bug...',
                      maxLines: 5,
                    ),
                    SizedBox(height: 24 * s),
                    _buildSectionTitle('ATTACHMENTS', s),
                    SizedBox(height: 12 * s),
                    _buildAttachmentButton(s),
                    SizedBox(height: 48 * s),
                    _buildSendButton(s),
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

  Widget _buildTitleSection(double s, Color themeTeal) {
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline, color: themeTeal, size: 28 * s),
        SizedBox(width: 16 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: GoogleFonts.inter(
                fontSize: 20 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              'Our warriors respond within 24h',
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickTip(double s, Color themeTeal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0F181A),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: themeTeal.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.electric_bolt, color: themeTeal, size: 16 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tip',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: themeTeal,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'Check the Help Center first — most questions are answered there instantly!',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
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

  Widget _buildTopicGrid(double s, Color themeTeal) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - 48 * s - 24 * s) / 3;

    return Wrap(
      spacing: 12 * s,
      runSpacing: 12 * s,
      children: _topics.map((topic) {
        bool isSelected = _selectedTopic == topic['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTopic = topic['label']),
          child: Container(
            width: itemWidth,
            padding: EdgeInsets.symmetric(vertical: 16 * s),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeTeal.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(
                color: isSelected ? themeTeal : Colors.white.withOpacity(0.04),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  topic['icon'],
                  color: isSelected ? themeTeal : Colors.white24,
                  size: 20 * s,
                ),
                SizedBox(height: 8 * s),
                Text(
                  topic['label'],
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    color: isSelected ? themeTeal : Colors.white54,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
    double s, {
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * s,
        vertical: maxLines > 1 ? 12 * s : 4 * s,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        maxLines: maxLines,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13 * s),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13 * s),
          icon: prefixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(left: 4 * s, right: 8 * s),
                  child: Icon(prefixIcon, color: Colors.white24, size: 18 * s),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(double s) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file, color: Colors.white54, size: 14 * s),
            SizedBox(width: 8 * s),
            Text(
              'Add file',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(double s) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF036B46), // Deep emerald green from design
          borderRadius: BorderRadius.circular(16 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF036B46).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, color: Colors.black, size: 18 * s),
            SizedBox(width: 8 * s),
            Text(
              'Send Message',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

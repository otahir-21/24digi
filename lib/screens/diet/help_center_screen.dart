import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'support_chat_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  final bool initialIsContactUs;
  const HelpCenterScreen({super.key, this.initialIsContactUs = false});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  late bool _isContactUs;
  String _activeCategory = 'General';

  @override
  void initState() {
    super.initState();
    _isContactUs = widget.initialIsContactUs;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 10 * s,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        _isContactUs ? 'Contact Us' : 'Help Center',
                        style: GoogleFonts.inter(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'How Can We Help You?',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24 * s),
                    // Main Toggle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Container(
                        height: 44 * s,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(22 * s),
                        ),
                        child: Row(
                          children: [
                            _ToggleTab(
                              s: s,
                              label: 'FAQ',
                              isActive: !_isContactUs,
                              onTap: () => setState(() => _isContactUs = false),
                            ),
                            _ToggleTab(
                              s: s,
                              label: 'Contact Us',
                              isActive: _isContactUs,
                              onTap: () => setState(() => _isContactUs = true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: _isContactUs ? _buildContactUs(s) : _buildFAQ(s),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(double s) {
    return Column(
      children: [
        SizedBox(height: 20 * s),
        // Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              _CategoryBtn(
                s: s,
                label: 'General',
                isActive: _activeCategory == 'General',
                onTap: () => setState(() => _activeCategory = 'General'),
              ),
              SizedBox(width: 12 * s),
              _CategoryBtn(
                s: s,
                label: 'Account',
                isActive: _activeCategory == 'Account',
                onTap: () => setState(() => _activeCategory = 'Account'),
              ),
              SizedBox(width: 12 * s),
              _CategoryBtn(
                s: s,
                label: 'Services',
                isActive: _activeCategory == 'Services',
                onTap: () => setState(() => _activeCategory = 'Services'),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * s),
        // Search Box
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Container(
            height: 48 * s,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24 * s),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Search',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 13 * s,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4 * s),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune, color: Colors.white, size: 16 * s),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(24 * s),
            children: [
              _FAQTile(
                s: s,
                question: 'Do you offer takeout or delivery?',
                isExpanded: true,
              ),
              _FAQTile(s: s, question: 'What are your opening hours?'),
              _FAQTile(s: s, question: 'How do I order?'),
              _FAQTile(s: s, question: 'How do I place an order?'),
              _FAQTile(s: s, question: 'Can I track my order?'),
              _FAQTile(s: s, question: 'What payment methods are accepted?'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactUs(double s) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 30 * s),
      children: [
        _ContactTile(
          s: s,
          icon: Icons.headset_mic_outlined,
          label: 'Customer service',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportChatScreen()),
            );
          },
        ),
        _ContactTile(s: s, icon: Icons.public_outlined, label: 'Website'),
        _ContactTile(s: s, icon: Icons.chat_bubble_outline, label: 'Whatsapp'),
        _ContactTile(s: s, icon: Icons.facebook_outlined, label: 'Facebook'),
        _ContactTile(s: s, icon: Icons.camera_alt_outlined, label: 'Instagram'),
      ],
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final double s;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.s,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF6B6B) : Colors.transparent,
            borderRadius: BorderRadius.circular(22 * s),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBtn extends StatelessWidget {
  final double s;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryBtn({
    required this.s,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF6B6B) : Colors.black,
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final double s;
  final String question;
  final bool isExpanded;

  const _FAQTile({
    required this.s,
    required this.question,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFFFF6B6B),
                    size: 24 * s,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 20 * s),
                Text(
                  'Yes, select locations offer takeout and delivery. Availability will be shown during checkout.',
                  style: GoogleFonts.inter(
                    fontSize: 11 * s,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(color: Colors.white10),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.s,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24 * s),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B6B), size: 32 * s),
            SizedBox(width: 20 * s),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: const Color(0xFFFF6B6B),
              size: 24 * s,
            ),
          ],
        ),
      ),
    );
  }
}

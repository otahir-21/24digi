import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _rating = 4;
  Set<String> _selectedLoves = {'Activity Tracking'};

  final List<Map<String, dynamic>> _loveItems = [
    {
      'label': 'Activity Tracking',
      'icon': Icons.local_fire_department_outlined,
    },
    {'label': 'Daily Quests', 'icon': Icons.emoji_events_outlined},
    {'label': 'XP & Leveling', 'icon': Icons.bolt},
    {'label': 'App Design', 'icon': Icons.favorite_border},
    {'label': 'Insights', 'icon': Icons.star_outline},
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final themeYellow = const Color(0xFFFFB000); // Golden yellow

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
                    _buildRatingCard(s, themeYellow),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('WHAT DO YOU LOVE MOST?', s),
                    SizedBox(height: 16 * s),
                    _buildLovePills(s),
                    SizedBox(height: 32 * s),
                    _buildSectionTitle('TELL US MORE (OPTIONAL)', s),
                    SizedBox(height: 16 * s),
                    _buildFeedbackField(s),
                    SizedBox(height: 40 * s),
                    _buildSubmitButton(s, themeYellow),
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
      children: [
        Icon(Icons.star_outline, color: const Color(0xFFFFB000), size: 28 * s),
        SizedBox(width: 16 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate 24DIGI',
              style: GoogleFonts.inter(
                fontSize: 20 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              'Your feedback shapes our future',
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingCard(double s, Color themeYellow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF161B21),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            "How's your warrior experience?",
            style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white54),
          ),
          SizedBox(height: 24 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() => _rating = index + 1);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? themeYellow : Colors.white24,
                    size: 40 * s,
                    shadows: index < _rating
                        ? [
                            Shadow(
                              color: themeYellow.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 24 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔥 ', style: TextStyle(fontSize: 16 * s)),
              Text(
                'Legendary!',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00D186),
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

  Widget _buildLovePills(double s) {
    return Wrap(
      spacing: 12 * s,
      runSpacing: 12 * s,
      children: _loveItems.map((item) {
        bool isSelected = _selectedLoves.contains(item['label']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedLoves.remove(item['label']);
              } else {
                _selectedLoves.add(item['label']);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: isSelected ? Colors.white38 : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'],
                  color: isSelected ? Colors.white : Colors.white54,
                  size: 14 * s,
                ),
                SizedBox(width: 8 * s),
                Text(
                  item['label'],
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackField(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        maxLines: 4,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14 * s),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'What makes 24DIGI special for you? Any suggestions...',
          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13 * s),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double s, Color themeYellow) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: themeYellow,
          borderRadius: BorderRadius.circular(16 * s),
          boxShadow: [
            BoxShadow(
              color: themeYellow.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
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
              'Submit Review',
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

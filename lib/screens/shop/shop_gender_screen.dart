import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_category_screen.dart';

class ShopGenderScreen extends StatefulWidget {
  const ShopGenderScreen({super.key});

  @override
  State<ShopGenderScreen> createState() => _ShopGenderScreenState();
}

class _ShopGenderScreenState extends State<ShopGenderScreen> {
  String? _selectedGender;

  void _onContinue() {
    if (_selectedGender != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShopCategoryScreen(gender: _selectedGender!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF332F2B), // Dark designer brown
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 24 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      'What is your gender?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 48 * s),

                    // Male Card
                    _GenderCard(
                      s: s,
                      label: 'Male',
                      icon: Icons.male_sharp,
                      image: 'assets/fonts/male.png',
                      isSelected: _selectedGender == 'Male',
                      onTap: () => setState(() => _selectedGender = 'Male'),
                      alignImageRight: true,
                    ),

                    SizedBox(height: 24 * s),

                    // Female Card
                    _GenderCard(
                      s: s,
                      label: 'Female',
                      icon: Icons.female_sharp,
                      image: 'assets/fonts/female.png',
                      isSelected: _selectedGender == 'Female',
                      onTap: () => setState(() => _selectedGender = 'Female'),
                      alignImageRight: false,
                    ),

                    const Spacer(),

                    // Continue Button
                    GestureDetector(
                      onTap: _onContinue,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 40 * s),
                        width: 220 * s,
                        padding: EdgeInsets.symmetric(vertical: 20 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(20 * s),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 15 * s,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.outfit(
                                fontSize: 22 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24 * s,
                            ),
                          ],
                        ),
                      ),
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
}

class _GenderCard extends StatelessWidget {
  final double s;
  final String label;
  final IconData icon;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;
  final bool alignImageRight;

  const _GenderCard({
    required this.s,
    required this.label,
    required this.icon,
    required this.image,
    required this.isSelected,
    required this.onTap,
    this.alignImageRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 165 * s,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFEAE0D5), // Accurate light beige
          borderRadius: BorderRadius.circular(28 * s),
          border: isSelected
              ? Border.all(color: const Color(0xFF00F0FF), width: 3 * s)
              : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF00F0FF).withOpacity(0.3),
                blurRadius: 20 * s,
                spreadRadius: 2 * s,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Content Row
            Row(
              children: alignImageRight
                  ? [
                      SizedBox(width: 28 * s),
                      _buildLabelSection(s),
                      const Spacer(),
                      _buildAvatar(s),
                    ]
                  : [
                      _buildAvatar(s),
                      const Spacer(),
                      _buildLabelSection(s),
                      SizedBox(width: 28 * s),
                    ],
            ),
            // Bottom Indicator
            Positioned(
              bottom: 20 * s,
              left: alignImageRight ? 28 * s : null,
              right: !alignImageRight ? 28 * s : null,
              child: _buildIndicator(isSelected, s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isSelected, double s) {
    return Container(
      width: 24 * s,
      height: 24 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.4), width: 2),
        color: isSelected ? Colors.black : Colors.transparent,
      ),
      child: isSelected
          ? Icon(Icons.check, size: 16 * s, color: Colors.white)
          : null,
    );
  }

  Widget _buildLabelSection(double s) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (alignImageRight)
          Icon(icon, size: 30 * s, color: Colors.black.withOpacity(0.7)),
        if (alignImageRight) SizedBox(width: 10 * s),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 34 * s,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -1.0,
          ),
        ),
        if (!alignImageRight) SizedBox(width: 10 * s),
        if (!alignImageRight)
          Icon(icon, size: 30 * s, color: Colors.black.withOpacity(0.7)),
      ],
    );
  }

  Widget _buildAvatar(double s) {
    return Image.asset(
      image,
      height: 165 * s,
      fit: BoxFit.contain,
    );
  }
}

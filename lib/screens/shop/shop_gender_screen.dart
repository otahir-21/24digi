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

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(), // Dark brown/charcoal
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
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      'What is your gender?',
                      style: GoogleFonts.outfit(
                        fontSize: 24 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40 * s),

                    // Male Card
                    _GenderCard(
                      s: s,
                      label: 'Male',
                      icon: Icons.male,
                      image: 'assets/fonts/male.png',
                      isSelected: _selectedGender == 'Male',
                      onTap: () => setState(() => _selectedGender = 'Male'),
                    ),

                    SizedBox(height: 20 * s),

                    // Female Card
                    _GenderCard(
                      s: s,
                      label: 'Female',
                      icon: Icons.female,
                      image: 'assets/fonts/female.png',
                      isSelected: _selectedGender == 'Female',
                      onTap: () => setState(() => _selectedGender = 'Female'),
                      reverse: true,
                    ),

                    const Spacer(),

                    // Continue Button
                    GestureDetector(
                      onTap: () {
                        if (_selectedGender != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ShopCategoryScreen(gender: _selectedGender!),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 40 * s),
                        width: 200 * s,
                        padding: EdgeInsets.symmetric(vertical: 16 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1813),
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(color: Colors.white10, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.outfit(
                                fontSize: 18 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20 * s,
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
  final bool reverse;

  const _GenderCard({
    required this.s,
    required this.label,
    required this.icon,
    required this.image,
    required this.isSelected,
    required this.onTap,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140 * s,
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        decoration: BoxDecoration(
          color: const Color(0xFFEAE0D5), // Light beige
          borderRadius: BorderRadius.circular(24 * s),
          border: isSelected
              ? Border.all(color: const Color(0xFF00F0FF), width: 2)
              : null,
        ),
        child: Row(
          children: reverse
              ? [
                  _buildAvatar(s),
                  const Spacer(),
                  _buildLabel(s),
                  SizedBox(width: 8 * s),
                  _buildRadio(isSelected, s),
                ]
              : [
                  _buildRadio(isSelected, s),
                  SizedBox(width: 8 * s),
                  _buildLabel(s),
                  const Spacer(),
                  _buildAvatar(s),
                ],
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected, double s) {
    return Container(
      width: 18 * s,
      height: 18 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black45, width: 1.5),
        color: isSelected ? Colors.black : Colors.transparent,
      ),
      child: isSelected
          ? Icon(Icons.check, size: 12 * s, color: Colors.white)
          : null,
    );
  }

  Widget _buildLabel(double s) {
    return Row(
      children: [
        if (!reverse) Icon(icon, size: 24 * s, color: Colors.black),
        SizedBox(width: 8 * s),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 26 * s,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 8 * s),
        if (reverse) Icon(icon, size: 24 * s, color: Colors.black),
      ],
    );
  }

  Widget _buildAvatar(double s) {
    return Image.asset(image, height: 130 * s, fit: BoxFit.contain);
  }
}

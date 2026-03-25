import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';
import 'shop_contact_us_screen.dart';

class ShopHelpCenterScreen extends StatelessWidget {
  const ShopHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    Text(
                      'Help Center',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'How Can We Help\nYou?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white38,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Navigation Tabs
                    Row(
                      children: [
                        Expanded(
                          child: _TabButton(label: 'FAQ', isActive: true, s: s),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShopContactUsScreen())),
                            child: _TabButton(label: 'Contact Us', isActive: false, s: s),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16 * s),

                    // Category Tabs
                    Row(
                      children: [
                        _SubTabButton(label: 'General', isActive: true, s: s),
                        SizedBox(width: 8 * s),
                        _SubTabButton(label: 'Account', isActive: false, s: s),
                        SizedBox(width: 8 * s),
                        _SubTabButton(label: 'Services', isActive: false, s: s),
                      ],
                    ),

                    SizedBox(height: 24 * s),

                    // Search Bar
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFDFCF),
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.outfit(color: Colors.black.withOpacity(0.24)),
                                border: InputBorder.none,
                              ),
                              style: GoogleFonts.outfit(color: Colors.black),
                            ),
                          ),
                          Icon(Icons.tune_rounded, color: const Color(0xFFEBC17B), size: 20 * s),
                        ],
                      ),
                    ),

                    SizedBox(height: 32 * s),

                    // FAQ List
                    _FAQItem(
                      question: 'How do I place an order?',
                      answer: 'Browse products, select your item, and proceed to checkout. Orders are completed using your 24DIGI Points balance.',
                      isOpen: true,
                      s: s,
                    ),
                    _FAQItem(question: 'Do I need an account to shop?', s: s),
                    _FAQItem(question: 'What are 24DIGI Points?', s: s),
                    _FAQItem(question: 'How do I pay for orders?', s: s),
                    _FAQItem(question: 'Can I track my order?', s: s),
                    _FAQItem(question: 'What payment methods are accepted?', s: s),
                    
                    SizedBox(height: 48 * s),
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final double s;

  const _TabButton({required this.label, required this.isActive, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44 * s,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFDFCF) : const Color(0xFF1B1813),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isActive ? Colors.transparent : Colors.white12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 14 * s,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.black : Colors.white60,
        ),
      ),
    );
  }
}

class _SubTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final double s;

  const _SubTabButton({required this.label, required this.isActive, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFDFCF) : const Color(0xFF1B1813),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isActive ? Colors.transparent : Colors.white12),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12 * s,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.black : Colors.white60,
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String? answer;
  final bool isOpen;
  final double s;

  const _FAQItem({required this.question, this.answer, this.isOpen = false, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 24 * s),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.outfit(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 20 * s,
                  ),
                ],
              ),
              if (isOpen && answer != null) ...[
                SizedBox(height: 24 * s),
                Text(
                  answer!,
                  style: GoogleFonts.outfit(
                    fontSize: 13 * s,
                    color: Colors.white38,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

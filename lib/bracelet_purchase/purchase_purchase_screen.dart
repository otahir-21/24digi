import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class BraceletPurchaseClass extends StatefulWidget {
  const BraceletPurchaseClass({super.key});

  @override
  State<BraceletPurchaseClass> createState() => _BraceletPurchaseClassState();
}

class _BraceletPurchaseClassState extends State<BraceletPurchaseClass> {
  int _quantity = 1;
  bool _showAccessories = false;
  final Set<int> _expandedFaq = {};

  // Accessories
  final List<_AccessoryItem> _accessories = [
    _AccessoryItem(
      image: 'assets/bracelet/smart_bracelet.png',
      name: 'Premium Strap + Metal Look',
      desc: 'Durable premium strap with metal look for premium comfort.',
      price: 30,
    ),
    _AccessoryItem(
      image: 'assets/bracelet/green_silicon_bracelet.png',
      name: 'Green Silicone Strap',
      desc: 'Lightweight interchangeable straps in multiple colors.',
      price: 25,
    ),
    _AccessoryItem(
      image: 'assets/bracelet/blue_silicon_bracelet.png',
      name: 'Blue Silicone Strap',
      desc: 'Lightweight durable straps in multiple colors.',
      price: 35,
    ),
    _AccessoryItem(
      image: 'assets/bracelet/bracelet_charger.png',
      name: 'Bracelet Charger',
      desc: 'Fast charger compatible with the 24DIGI Smart Bracelet.',
      price: 25,
    ),
  ];

  final List<_FaqItem> _faqs = const [
    _FaqItem(q: 'Do I need the subscription?'),
    _FaqItem(q: 'Can I cancel the subscription?'),
    _FaqItem(q: 'Does the bracelet work without the subscription?'),
    _FaqItem(q: "What's included in the box?"),
    _FaqItem(q: 'Is the bracelet water-resistant?'),
  ];

  static const _surface = Color(0xFF0D1117);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            const DigiPillHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // HI, USER
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 18),
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.75),
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),

                    // ── HERO SECTION ────────────────────────────────────────
                    _HeroSection(),

                    const SizedBox(height: 32),

                    // ── FEATURES SECTION ────────────────────────────────────
                    _FeaturesSection(),

                    const SizedBox(height: 40),

                    // ── PRICING SECTION ─────────────────────────────────────
                    _PricingSection(),

                    const SizedBox(height: 32),

                    // ── ACCESSORIES ─────────────────────────────────────────
                    _AccessoriesSection(accessories: _accessories),

                    const SizedBox(height: 32),

                    // ── PURCHASE CARD ────────────────────────────────────────
                    _PurchaseCard(
                      quantity: _quantity,
                      onDecrement: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                      onIncrement: () => setState(() => _quantity++),
                      showAccessories: _showAccessories,
                      onToggleAccessories: () =>
                          setState(() => _showAccessories = !_showAccessories),
                    ),

                    const SizedBox(height: 40),

                    // ── FAQ ──────────────────────────────────────────────────
                    _FaqSection(
                      faqs: _faqs,
                      expanded: _expandedFaq,
                      onToggle: (i) => setState(() {
                        if (_expandedFaq.contains(i)) {
                          _expandedFaq.remove(i);
                        } else {
                          _expandedFaq.add(i);
                        }
                      }),
                    ),

                    const SizedBox(height: 32),

                    // ── CTA BANNER ───────────────────────────────────────────
                    _CtaBanner(),

                    const SizedBox(height: 24),

                    // Footer
                    Text(
                      '© 2026 24Digi. All rights reserved.',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 24),
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

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  static const _cyan = Color(0xFF00D4F5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // AI-Powered badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cyan.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan,
                    boxShadow: [
                      BoxShadow(color: _cyan.withOpacity(0.8), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'AI-Powered Health Tech',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: _cyan,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bracelet image
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF111827),
              border: Border.all(color: _cyan.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: _cyan.withOpacity(0.08),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/bracelet/smart_bracelet.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          Icons.watch,
                          size: 80,
                          color: _cyan.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  // Heart rate overlay badge
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _cyan.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heart Rate',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '72',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _cyan,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'BPM',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: _cyan.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Title
          Text(
            '24DIGI Smart',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Health Bracelet',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _cyan,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(
            'Advanced AI-powered health monitoring for everyday life.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white.withOpacity(0.55),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Price line
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white.withOpacity(0.45),
              ),
              children: [
                const TextSpan(text: 'Starting at '),
                TextSpan(
                  text: '600 AED',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: _cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' + 120 AED/year'),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Buy button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4F5), Color(0xFF0099CC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Buy Bracelet',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Learn button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF1A2035),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Center(
                child: Text(
                  'Learn How It Works',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  static const _cyan = Color(0xFF00D4F5);
  static const _cardBg = Color(0xFF111827);

  static const _features = [
    _FeatureItem(
      icon: Icons.monitor_heart_outlined,
      iconColor: Color(0xFF00D4F5),
      title: 'AI Health Monitoring',
      desc: 'Continuously analyzes your vitals using advanced AI algorithms.',
    ),
    _FeatureItem(
      icon: Icons.show_chart_rounded,
      iconColor: Color(0xFF00FF85),
      title: 'Real-time Tracking',
      desc: 'Track heart rate, sleep, stress, and activity in real time.',
    ),
    _FeatureItem(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFFB47FFF),
      title: 'AI Insights',
      desc: 'Personalized health recommendations powered by data science.',
    ),
    _FeatureItem(
      icon: Icons.phone_iphone_rounded,
      iconColor: Color(0xFFFF6B6B),
      title: 'App Integration',
      desc: 'Seamless sync with the 24DIGI mobile app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Label
          Text(
            'FEATURES',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: _cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your Health, Elevated',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: f.iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.icon, color: f.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            f.desc,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICING SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PricingSection extends StatelessWidget {
  static const _cyan = Color(0xFF00D4F5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'TRANSPARENT PRICING',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: _cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'How Pricing Works',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Simple, straightforward. No hidden fees.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 22),

          // Step 1 card
          _PricingCard(
            step: '1',
            icon: Icons.storefront_outlined,
            iconColor: _cyan,
            title: 'Buy the Bracelet',
            price: '600',
            priceUnit: 'AED',
            subtitle: null,
            desc:
                'One-time purchase. Includes bracelet, charger, silicone strap & app access.',
          ),

          const SizedBox(height: 8),

          // Arrow
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.25),
            size: 28,
          ),

          const SizedBox(height: 8),

          // Step 2 card
          _PricingCard(
            step: '2',
            icon: Icons.analytics_outlined,
            iconColor: const Color(0xFF00FF85),
            title: 'Activate Health Analytics',
            price: '120',
            priceUnit: 'AED / year',
            subtitle: '+ 10 AED / month',
            desc:
                'Enables advanced AI health insights, alerts & continuous monitoring.',
            subscriptionFunds: const [
              'AI Health Analytics',
              'Platform Operations',
              'Continuous R&D',
            ],
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.price,
    required this.priceUnit,
    required this.subtitle,
    required this.desc,
    this.subscriptionFunds,
  });

  final String step;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String price;
  final String priceUnit;
  final String? subtitle;
  final String desc;
  final List<String>? subscriptionFunds;

  static const _cardBg = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    step,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                priceUnit,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: iconColor.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              height: 1.5,
            ),
          ),
          if (subscriptionFunds != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR SUBSCRIPTION FUNDS',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.35),
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...subscriptionFunds!.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: iconColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCESSORIES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _AccessoriesSection extends StatelessWidget {
  const _AccessoriesSection({required this.accessories});
  final List<_AccessoryItem> accessories;

  static const _cyan = Color(0xFF00D4F5);
  static const _cardBg = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'OPTIONAL ADD-ONE',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: _cyan,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Accessories',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalize your 24DIGI experience.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...accessories.map(
            (acc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.black26,
                        child: Image.asset(
                          acc.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.watch_outlined,
                            color: _cyan.withOpacity(0.4),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc.name,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            acc.desc,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.45),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${acc.price} AED',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 52,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _cyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _cyan.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '+ Add',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _cyan,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessoryItem {
  const _AccessoryItem({
    required this.image,
    required this.name,
    required this.desc,
    required this.price,
  });
  final String image;
  final String name;
  final String desc;
  final int price;
}

// ─────────────────────────────────────────────────────────────────────────────
// PURCHASE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.showAccessories,
    required this.onToggleAccessories,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool showAccessories;
  final VoidCallback onToggleAccessories;

  static const _cyan = Color(0xFF00D4F5);
  static const _cardBg = Color(0xFF111827);

  int get _total => (600 + 120) * quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cyan.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: _cyan.withOpacity(0.07),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Bracelet image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black38,
                    child: Image.asset(
                      'assets/bracelet/health_bracelet.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.watch,
                          size: 80,
                          color: _cyan.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                // Best value badge
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFB800).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Best Value',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: const Color(0xFFFFB800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '24DIGI Smart Bracelet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Complete health monitoring package',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Line items
                  _PriceRow(
                    dot: _cyan,
                    label: 'Bracelet Device',
                    value: '600 AED',
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    dot: const Color(0xFF00FF85),
                    label: 'Health Analytics /yr',
                    value: '120 AED',
                    valueNote: true,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white12),
                  ),

                  // Total
                  Row(
                    children: [
                      Text(
                        'First Year Total',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '720',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AED',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Quantity
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      _QuantityButton(icon: Icons.remove, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$quantity',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _QuantityButton(icon: Icons.add, onTap: onIncrement),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Buy Now button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4F5), Color(0xFF0099CC)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _cyan.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buy Now — ${_total} AED',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Add Accessories toggle
                  GestureDetector(
                    onTap: onToggleAccessories,
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add Accessories',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            showAccessories
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white.withOpacity(0.4),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.dot,
    required this.label,
    required this.value,
    this.valueNote = false,
  });
  final Color dot;
  final String label;
  final String value;
  final bool valueNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.faqs,
    required this.expanded,
    required this.onToggle,
  });

  final List<_FaqItem> faqs;
  final Set<int> expanded;
  final void Function(int) onToggle;

  static const _cyan = Color(0xFF00D4F5);
  static const _cardBg = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'SUPPORT',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: _cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'FAQ',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(faqs.length, (i) {
            final isOpen = expanded.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onToggle(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOpen
                          ? _cyan.withOpacity(0.3)
                          : Colors.white.withOpacity(0.07),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faqs[i].q,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.35),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.q});
  final String q;
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _CtaBanner extends StatelessWidget {
  static const _cyan = Color(0xFF00D4F5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF003D4D), const Color(0xFF001A26)],
          ),
          border: Border.all(color: _cyan.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: _cyan.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _cyan.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _cyan.withOpacity(0.3)),
              ),
              child: Icon(Icons.favorite_rounded, color: _cyan, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Start monitoring your health\ntoday',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Join thousands who trust 24DIGI to keep them\nhealthier every day.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  'Buy the 24DIGI Bracelet',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '600 AED once + 120 AED/year subscription',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

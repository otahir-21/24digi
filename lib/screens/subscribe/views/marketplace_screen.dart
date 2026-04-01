import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/core/app_constants.dart';
import 'package:kivi_24/widgets/digi_background.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';
import 'package:kivi_24/screens/subscribe/views/subscription.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name?.toUpperCase() ?? 'USER';

    return Scaffold(
      backgroundColor: Colors.black,
      body: DigiBackground(
        showLanguageSlider: false,
        circuitOpacity: 0.4,
        logoOpacity: 0.1,
        child: SafeArea(
          child: Column(
            children: [
              const DigiPillHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10 * s),

                      // HI, USER
                      Text(
                        'HI, $name',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 13 * s,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 2.5 * s,
                        ),
                      ),

                      SizedBox(height: 14 * s),

                      // OUR SERVICES badge
                      _OurServicesBadge(s: s),

                      SizedBox(height: 22 * s),

                      // Title block — left aligned
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _MarketplaceTitle(s: s),
                      ),

                      SizedBox(height: 28 * s),

                      // Subscriptions button — centered
                      _SubscriptionsButton(
                        s: s,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Subscription()),
                          );
                        },
                      ),

                      SizedBox(height: 28 * s),

                      // 24DIGI BRACELET card
                      _MarketplaceCard(
                        s: s,
                        title: '24DIGI BRACELET',
                        imagePath:
                            'assets/subscription/subscription_bracelet.png',
                        price: '600',
                        buttonText: 'Buy Now',
                        onTap: () {},
                        topLeftContent: _BraceletTopLeft(s: s),
                        topRightContent: Text(
                          '24DIGI',
                          style: TextStyle(
                            fontFamily: 'LemonMilk',
                            fontSize: 34 * s,
                            color: const Color(0xFF2A7BFF).withOpacity(0.85),
                            letterSpacing: 1 * s,
                          ),
                        ),
                      ),

                      SizedBox(height: 20 * s),

                      // C BY AI card
                      _MarketplaceCard(
                        s: s,
                        title: 'C BY AI',
                        imagePath: 'assets/c_by_ai/background.png',
                        price: '2,900',
                        buttonText: 'Subscribe',
                        isSubscribe: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Subscription()),
                          );
                        },
                      ),

                      SizedBox(height: 20 * s),

                      // 24DIGI POINTS card
                      _MarketplaceCard(
                        s: s,
                        title: '24DIGI POINTS',
                        imagePath: 'assets/subscription/subcription_coin.png',
                        price: '1',
                        unit: '/10 Points',
                        buttonText: 'Buy Points',
                        isPoints: true,
                        onTap: () {},
                      ),

                      SizedBox(height: 40 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── OUR SERVICES badge ───────────────────────────────────────────────────────

class _OurServicesBadge extends StatelessWidget {
  final double s;
  const _OurServicesBadge({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F24),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7 * s,
            height: 7 * s,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF94),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            'OUR SERVICES',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 9 * s,
              color: Colors.white.withOpacity(0.55),
              letterSpacing: 1.5 * s,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Marketplace title ────────────────────────────────────────────────────────

class _MarketplaceTitle extends StatelessWidget {
  final double s;
  const _MarketplaceTitle({required this.s});

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: 'LemonMilk',
      fontWeight: FontWeight.w400,
      height: 1.25,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Welcome to" — white, regular weight
        Text(
          'Welcome to',
          style: baseStyle.copyWith(fontSize: 30 * s, color: Colors.white),
        ),

        // "24" — purple
        Text(
          '24',
          style: baseStyle.copyWith(
            fontSize: 34 * s,
            color: const Color(0xFFB161FF),
          ),
        ),

        // "Market" gold-gradient + "place" cyan — on same line
        ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Color(0xFFFFA800), Color(0xFFFFD600)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Market',
            style: baseStyle.copyWith(fontSize: 34 * s, color: Colors.white),
          ),
        ),

        Text(
          'place',
          style: baseStyle.copyWith(
            fontSize: 34 * s,
            color: const Color(0xFF00F0FF),
          ),
        ),
      ],
    );
  }
}

// ─── Subscriptions button ─────────────────────────────────────────────────────

class _SubscriptionsButton extends StatelessWidget {
  final double s;
  final VoidCallback onTap;
  const _SubscriptionsButton({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * s),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA800), Color(0xFF00F0FF)],
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1519),
            borderRadius: BorderRadius.circular(28 * s),
          ),
          padding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 11 * s),
          child: ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFA800), Color(0xFF00F0FF)],
                ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'Subscriptions',
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 15 * s,
                color: Colors.white,
                letterSpacing: 0.5 * s,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bracelet top-left subtitle widget ───────────────────────────────────────

class _BraceletTopLeft extends StatelessWidget {
  final double s;
  const _BraceletTopLeft({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUTURE',
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 19 * s,
            color: Colors.white.withOpacity(0.92),
            letterSpacing: 1 * s,
            height: 1.2,
          ),
        ),
        Text(
          'READY',
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 19 * s,
            color: Colors.white.withOpacity(0.92),
            letterSpacing: 1 * s,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          'NEXT-GEN WEARABLES',
          style: TextStyle(
            fontFamily: 'LemonMilk',
            fontSize: 9 * s,
            color: const Color(0xFF00F0FF).withOpacity(0.85),
            letterSpacing: 0.8 * s,
          ),
        ),
      ],
    );
  }
}

// ─── Marketplace card ─────────────────────────────────────────────────────────

class _MarketplaceCard extends StatelessWidget {
  final double s;
  final String title;
  final String imagePath;
  final String price;
  final String? unit;
  final String buttonText;
  final VoidCallback onTap;
  final bool isSubscribe;
  final bool isPoints;
  final Widget? topLeftContent;
  final Widget? topRightContent;

  const _MarketplaceCard({
    required this.s,
    required this.title,
    required this.imagePath,
    required this.price,
    this.unit,
    required this.buttonText,
    required this.onTap,
    this.isSubscribe = false,
    this.isPoints = false,
    this.topLeftContent,
    this.topRightContent,
  });

  Color get _buttonColor {
    if (isSubscribe) return const Color(0xFF00FF94);
    if (isPoints) return const Color(0xFFA14DFE);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * s),
        border:
            isPoints
                ? Border.all(
                  color: const Color(0xFF00F0FF).withOpacity(0.55),
                  width: 1.5,
                )
                : Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 18 * s,
            offset: Offset(0, 8 * s),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22 * s),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFF131D24), Colors.grey[900]!],
                      ),
                    ),
                  ),
            ),

            // ── Gradient overlay — heavier toward bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            // ── Top-left content (bracelet subtitle)
            if (topLeftContent != null)
              Positioned(top: 22 * s, left: 18 * s, child: topLeftContent!),

            // ── Top-right content (24DIGI label)
            if (topRightContent != null)
              Positioned(top: 18 * s, right: 14 * s, child: topRightContent!),

            // ── Bottom content row
            Positioned(
              left: 18 * s,
              right: 18 * s,
              bottom: 20 * s,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title + price block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card title
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'LemonMilk',
                            fontSize: 20 * s,
                            color: Colors.white,
                            letterSpacing: 0.8 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        // Price row
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isPoints)
                              Text(
                                'Starting from',
                                style: TextStyle(
                                  fontFamily: 'LemonMilk',
                                  fontSize: 7 * s,
                                  color: Colors.white60,
                                  letterSpacing: 0.3 * s,
                                ),
                              ),
                            SizedBox(height: 2 * s),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  price,
                                  style: TextStyle(
                                    fontFamily: 'LemonMilk',
                                    fontSize: 20 * s,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5 * s,
                                  ),
                                ),
                                SizedBox(width: 6 * s),
                                Image.asset(
                                  'assets/subscription/subcription_coin.png',
                                  height: 20 * s,
                                  width: 20 * s,
                                  errorBuilder:
                                      (_, __, ___) => Icon(
                                        Icons.monetization_on,
                                        color: Colors.amber,
                                        size: 18 * s,
                                      ),
                                ),
                                if (unit != null) ...[
                                  SizedBox(width: 4 * s),
                                  Text(
                                    unit!,
                                    style: TextStyle(
                                      fontFamily: 'LemonMilk',
                                      fontSize: 9 * s,
                                      color: Colors.white60,
                                      letterSpacing: 0.3 * s,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12 * s),

                  // Action button
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * s,
                        vertical: 13 * s,
                      ),
                      decoration: BoxDecoration(
                        color: _buttonColor,
                        borderRadius: BorderRadius.circular(12 * s),
                        boxShadow: [
                          BoxShadow(
                            color: _buttonColor.withOpacity(0.35),
                            blurRadius: 12 * s,
                            spreadRadius: 1 * s,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: TextStyle(
                              fontFamily: 'LemonMilk',
                              fontSize: 11 * s,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3 * s,
                            ),
                          ),
                          SizedBox(width: 8 * s),
                          Icon(
                            isSubscribe
                                ? Icons.bolt
                                : Icons.arrow_forward_rounded,
                            size: 15 * s,
                            color: Colors.black,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_ai_screen.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class _AiCardData {
  const _AiCardData({
    required this.tag,
    required this.tagColor,
    required this.tagBorderColor,
    required this.imagePath,
    required this.description,
    required this.statusLabel,
    required this.statusColor,
    required this.buttonLabel,
    required this.buttonTextColor,
    required this.buttonBorderColor,
    required this.cardGradientColors,
    required this.glowColor,
  });

  final String tag;
  final Color tagColor;
  final Color tagBorderColor;
  final String imagePath;
  final String description;
  final String statusLabel;
  final Color statusColor;
  final String buttonLabel;
  final Color buttonTextColor;
  final Color buttonBorderColor;
  final List<Color> cardGradientColors;
  final Color glowColor;
}

const _cards = [
  _AiCardData(
    tag: 'EMERGENCY AI',
    tagColor: Color(0xFFFF4D6D),
    tagBorderColor: Color(0xFFFF4D6D),
    imagePath: 'assets/ai_model/save_life.png',
    description:
        'Real-time health monitoring and rapid response\nprotocols for critical incidents.',
    statusLabel: 'SYSTEM ACTIVE',
    statusColor: Color(0xFFFF4D6D),
    buttonLabel: 'SaveLife',
    buttonTextColor: Color(0xFFFF4D6D),
    buttonBorderColor: Color(0xFFFF4D6D),
    cardGradientColors: [Color(0xFF1A0A10), Color(0xFF0D0D0D)],
    glowColor: Color(0x33FF4D6D),
  ),
  _AiCardData(
    tag: 'REDENERATION AI',
    tagColor: Color(0xFFB47FFF),
    tagBorderColor: Color(0xFFB47FFF),
    imagePath: 'assets/ai_model/recovery_ai.png',
    description:
        'Optimized sleep patterns and deep muscle recovery\nthrough advanced data analysis.',
    statusLabel: 'SYSTEM ACTIVE',
    statusColor: Color(0xFFB47FFF),
    buttonLabel: 'Recovery AI',
    buttonTextColor: Color(0xFFB47FFF),
    buttonBorderColor: Color(0xFFB47FFF),
    cardGradientColors: [Color(0xFF120A1A), Color(0xFF0D0D0D)],
    glowColor: Color(0x33B47FFF),
  ),
  _AiCardData(
    tag: 'TRAINING AI',
    tagColor: Color(0xFF2FFFCC),
    tagBorderColor: Color(0xFF2FFFCC),
    imagePath: 'assets/ai_model/ai_coach.png',
    description:
        'Intelligent systems that dynamically scale workouts\nand provide real-time movement feedback.',
    statusLabel: 'SYSTEM READY',
    statusColor: Color(0xFF2FFFCC),
    buttonLabel: 'AI Coach',
    buttonTextColor: Color(0xFF2FFFCC),
    buttonBorderColor: Color(0xFF2FFFCC),
    cardGradientColors: [Color(0xFF061410), Color(0xFF0D0D0D)],
    glowColor: Color(0x332FFFCC),
  ),
];

class AiModelDashboard extends StatefulWidget {
  const AiModelDashboard({super.key});

  @override
  State<AiModelDashboard> createState() => _AiModelDashboardState();
}

class _AiModelDashboardState extends State<AiModelDashboard>
    with TickerProviderStateMixin {
  late final List<AnimationController> _fadeControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _fadeControllers = List.generate(
      _cards.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _fadeAnimations = _fadeControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slideAnimations = _fadeControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    // Staggered entrance
    for (int i = 0; i < _fadeControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 120 * i), () {
        if (mounted) _fadeControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _fadeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecoveryAiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            const DigiPillHeader(),

            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 14),
              child: Text(
                'HI, USER',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: .75),
                  letterSpacing: 2.5,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _SearchBar(),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                itemCount: _cards.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  return FadeTransition(
                    opacity: _fadeAnimations[i],
                    child: SlideTransition(
                      position: _slideAnimations[i],
                      child: _AiCard(
                        data: _cards[i],
                        onTap: () => _navigate(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: TextField(
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.35)),
          border: InputBorder.none,
          hintText: 'Search AI engines...',
          hintStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white.withOpacity(0.35),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Card
// ─────────────────────────────────────────────────────────────────────────────
class _AiCard extends StatefulWidget {
  const _AiCard({required this.data, required this.onTap});
  final _AiCardData data;
  final VoidCallback onTap;

  @override
  State<_AiCard> createState() => _AiCardState();
}

class _AiCardState extends State<_AiCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: d.cardGradientColors,
            ),
            border: Border.all(color: d.glowColor.withOpacity(0.45), width: 1),
            boxShadow: [
              BoxShadow(
                color: d.glowColor.withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image with tag overlay ─────────────────────────
                Stack(
                  children: [
                    // Image
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        d.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                d.glowColor.withOpacity(0.25),
                                d.cardGradientColors[0],
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.smart_toy_outlined,
                              size: 64,
                              color: d.tagColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay bottom fade
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              d.cardGradientColors[0],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tag badge — top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: d.tagColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: d.tagBorderColor.withOpacity(0.7),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          d.tag,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: d.tagColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Bottom content ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        d.description,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.82),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Status dot + label
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: d.statusColor,
                              boxShadow: [
                                BoxShadow(
                                  color: d.statusColor.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            d.statusLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: d.statusColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: d.buttonBorderColor.withOpacity(0.6),
                              width: 1.5,
                            ),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Text(
                              d.buttonLabel,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: d.buttonTextColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

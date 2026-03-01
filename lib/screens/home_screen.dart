import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivi_24/screens/bracelet/bracelet_search_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../widgets/digi_background.dart';
import '../widgets/digi_gradient_border.dart';
import 'stub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _go(String title) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => StubScreen(title: title)),
  );

  @override
  Widget build(BuildContext context) {
    // We use MediaQuery here to get the scale factor 's'
    final s = MediaQuery.of(context).size.width / 394;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: DigiBackground(
        showLanguageSlider: false,
        circuitOpacity: 0.5,
        circuitHeightFactor: 0.45,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final name = auth.profile?.name?.toUpperCase() ?? 'USER';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Header ──
                    _HomeHeader(s: s),

                    SizedBox(height: 12 * s),

                    // ── Hi User ──
                    Center(
                      child: Text(
                        'HI, $name',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2 * s,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.5),
                              blurRadius: 10 * s,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24 * s),

                    // ── Top Angled Tiles Section ──
                    _AngledTopSection(s: s, onTileTap: _go),

                    SizedBox(height: 20 * s),

                    // ── Delivery & Diet Section ──
                    _DeliveryDietSection(s: s, onTileTap: _go),

                    SizedBox(height: 20 * s),

                    // ── Grid Section ──
                    _GridSection(s: s, onTileTap: _go),

                    SizedBox(height: 28 * s),

                    // ── Potential Banner ──
                    _PotentialBanner(s: s),

                    SizedBox(height: 28 * s),

                    // ── Bottom Profile/BMI Card ──
                    _ProfileBmiCard(
                      s: s,
                      heightCtrl: _heightCtrl,
                      weightCtrl: _weightCtrl,
                    ),

                    SizedBox(height: 40 * s),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header Component ──────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final double s;
  const _HomeHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 * s,
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * s),
        color: const Color(0xFF1B2329).withOpacity(0.4),
        border: Border.all(color: const Color(0xFF26313A), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF00F0FF),
              size: 22 * s,
            ),
          ),
          // Logo
          Image.asset(
            'assets/24 logo.png',
            height: 38 * s,
            fit: BoxFit.contain,
          ),
          // Avatar
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset('assets/fonts/male.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Angled Section ────────────────────────────────────────────────────────────

class _AngledTopSection extends StatelessWidget {
  final double s;
  final void Function(String) onTileTap;

  const _AngledTopSection({required this.s, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196 * s,
      child: Row(
        children: [
          // Left column: 2 small angled tiles
          Expanded(
            flex: 40,
            child: Column(
              children: [
                _AngledTile(
                  s: s,
                  label: '24\nBRACELET',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BraceletSearchScreen(),
                    ),
                  ),
                  isTopLeft: true,
                ),
                SizedBox(height: 8 * s),
                _AngledTile(
                  s: s,
                  label: 'CHALLENGE\nZONE',
                  onTap: () => onTileTap('Challenge Zone'),
                  isBottomLeft: true,
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          // Right big tile: C BY AI
          Expanded(
            flex: 60,
            child: _CByAiTile(s: s, onTap: () => onTileTap('C By AI')),
          ),
        ],
      ),
    );
  }
}

class _AngledTile extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  final bool isTopLeft;
  final bool isBottomLeft;

  const _AngledTile({
    required this.s,
    required this.label,
    required this.onTap,
    this.isTopLeft = false,
    this.isBottomLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _AngledCardPainter(
            s: s,
            isTopLeft: isTopLeft,
            isBottomLeft: isBottomLeft,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 14 * s,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF00F0FF),
                height: 1.2,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.5),
                    blurRadius: 8 * s,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CByAiTile extends StatelessWidget {
  final double s;
  final VoidCallback onTap;

  const _CByAiTile({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _PentagonCardPainter(s: s),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'C',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 90 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF00F0FF),
                  height: 1,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.6),
                      blurRadius: 20 * s,
                    ),
                  ],
                ),
              ),
              Text(
                'BY AI',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF00F0FF),
                  letterSpacing: 4 * s,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.5),
                      blurRadius: 10 * s,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Delivery & Diet Section ───────────────────────────────────────────────────

class _DeliveryDietSection extends StatelessWidget {
  final double s;
  final void Function(String) onTileTap;

  const _DeliveryDietSection({required this.s, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80 * s,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTileTap('Delivery'),
              child: CustomPaint(
                painter: _TrapezoidLeftPainter(s: s),
                child: Container(
                  padding: EdgeInsets.only(left: 16 * s),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DELIVERY',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF00F0FF),
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.5),
                          blurRadius: 10 * s,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: GestureDetector(
              onTap: () => onTileTap('24 Diet'),
              child: CustomPaint(
                painter: _TrapezoidRightPainter(s: s),
                child: Container(
                  padding: EdgeInsets.only(right: 16 * s),
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '24',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF00F0FF),
                          height: 1,
                        ),
                      ),
                      Text(
                        'DIET',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF00F0FF),
                          height: 1,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.5),
                              blurRadius: 10 * s,
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ── Grid Section ──────────────────────────────────────────────────────────────

class _GridSection extends StatelessWidget {
  final double s;
  final void Function(String) onTileTap;

  const _GridSection({required this.s, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('AI MODELS', 'AI Models'),
      ('24 SHOP', '24 Shop'),
      ('WALLET', 'Wallet'),
      ('24 HEROES', '24 Heroes'),
      ('SUBSCRIBE', 'Subscribe'),
      ('24 DISCOVERY', '24 Discovery'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10 * s,
        mainAxisSpacing: 12 * s,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTileTap(items[index].$2),
          child: CustomPaint(
            painter: DigiGradientBorderPainter(
              radius: 14 * s,
              strokeWidth: 1.5,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14 * s),
                color: const Color(0xFF1B2329).withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  items[index].$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF00F0FF),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Banner Component ──────────────────────────────────────────────────────────

class _PotentialBanner extends StatelessWidget {
  final double s;
  const _PotentialBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * s),
        image: const DecorationImage(
          image: AssetImage('assets/fonts/bannerad.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16 * s,
            left: 16 * s,
            child: Text(
              'UNLOCK YOUR POTENTIAL',
              style: GoogleFonts.inter(
                fontSize: 20 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14 * s,
            left: 16 * s,
            child: Text(
              '24 DIGI',
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00F0FF),
              ),
            ),
          ),
          Positioned(
            bottom: 12 * s,
            right: 12 * s,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * s,
                vertical: 6 * s,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6 * s),
                color: const Color(0xFF00F0FF),
              ),
              child: Text(
                'Learn More',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile/BMI Section ───────────────────────────────────────────────────────

class _ProfileBmiCard extends StatelessWidget {
  final double s;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;

  const _ProfileBmiCard({
    required this.s,
    required this.heightCtrl,
    required this.weightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DigiGradientBorderPainter(radius: 18 * s, strokeWidth: 1.5),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * s),
          color: const Color(0xFF1B2329).withOpacity(0.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _HomeBmiField(
                    s: s,
                    ctrl: heightCtrl,
                    hint: 'enter your height',
                    icon: Icons.height_rounded,
                  ),
                  SizedBox(height: 12 * s),
                  _HomeBmiField(
                    s: s,
                    ctrl: weightCtrl,
                    hint: 'enter your weight',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            // Avatar
            Image.asset(
              'assets/fonts/male.png',
              height: 140 * s,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8 * s),
            // Stat bar
            Container(
              width: 22 * s,
              height: 140 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11 * s),
                color: const Color(0xFF26313A).withOpacity(0.5),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 22 * s,
                height: 100 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11 * s),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFFF3582), Color(0xFFFF7595)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBmiField extends StatelessWidget {
  final double s;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;

  const _HomeBmiField({
    required this.s,
    required this.ctrl,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      height: 40 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * s),
        color: const Color(0xFF26313A).withOpacity(0.4),
        border: Border.all(
          color: const Color(0xFF00F0FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 18 * s),
          SizedBox(width: 8 * s),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: const Color(0xFF4A5A64),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTERS ───────────────────────────────────────────────────────────

class _AngledCardPainter extends CustomPainter {
  final double s;
  final bool isTopLeft;
  final bool isBottomLeft;
  _AngledCardPainter({
    required this.s,
    this.isTopLeft = false,
    this.isBottomLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B2329).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFFB16DFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    if (isTopLeft) {
      path.moveTo(12 * s, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - 25 * s, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 12 * s);
      path.quadraticBezierTo(0, 0, 12 * s, 0);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - 25 * s, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(12 * s, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - 12 * s);
      path.lineTo(0, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PentagonCardPainter extends CustomPainter {
  final double s;
  _PentagonCardPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B2329).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFFB16DFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(25 * s, 0);
    path.lineTo(size.width - 12 * s, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12 * s);
    path.lineTo(size.width, size.height - 12 * s);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 12 * s,
      size.height,
    );
    path.lineTo(25 * s, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrapezoidLeftPainter extends CustomPainter {
  final double s;
  _TrapezoidLeftPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B2329).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFFB16DFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(12 * s, 0);
    path.lineTo(size.width - 25 * s, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 12 * s);
    path.quadraticBezierTo(0, 0, 12 * s, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrapezoidRightPainter extends CustomPainter {
  final double s;
  _TrapezoidRightPainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B2329).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFFB16DFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(25 * s, 0);
    path.lineTo(size.width - 12 * s, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12 * s);
    path.lineTo(size.width, size.height - 12 * s);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 12 * s,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

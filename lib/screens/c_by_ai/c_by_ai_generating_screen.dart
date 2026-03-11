import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'c_by_ai_tracker_screen.dart';

class CByAiGeneratingScreen extends StatefulWidget {
  const CByAiGeneratingScreen({super.key});

  @override
  State<CByAiGeneratingScreen> createState() => _CByAiGeneratingScreenState();
}

class _CByAiGeneratingScreenState extends State<CByAiGeneratingScreen> {
  int _mealsCreated = 0;
  final int _totalMeals = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  void _startGeneration() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_mealsCreated < _totalMeals) {
        setState(() {
          _mealsCreated++;
        });
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CByAiTrackerScreen(initialIsCalendar: true),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    double progress = _mealsCreated / _totalMeals;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 40 * s),
              // Logo
              Center(
                child: Image.asset(
                  'assets/24 logo.png',
                  height: 40 * s,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 60 * s),

              // Robot Circle Progress
              _buildProgressCircle(s, progress),

              SizedBox(height: 40 * s),

              // Title Section
              Text(
                'Generating Your Meal Plan',
                style: GoogleFonts.outfit(
                  fontSize: 28 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12 * s),
              Text(
                'Creating day $_mealsCreated of $_totalMeals...',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 16 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6 * s,
                    height: 6 * s,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00F0FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Text(
                    'AI is working on your personalized meals',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 60 * s),

              // Top Stats Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Container(
                  padding: EdgeInsets.all(16 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E22),
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                  child: Row(
                    children: [
                      _buildStatGridItem(
                        s,
                        '0',
                        'Days Ready',
                        Icons.calendar_today_rounded,
                      ),
                      _buildDivider(s),
                      _buildStatGridItem(
                        s,
                        '${_totalMeals - _mealsCreated}',
                        'Days Left',
                        Icons.access_time_rounded,
                      ),
                      _buildDivider(s),
                      _buildStatGridItem(
                        s,
                        '$_mealsCreated',
                        'Meals Created',
                        Icons.restaurant_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24 * s),

              // Bottom Info Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Container(
                  padding: EdgeInsets.all(16 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E22),
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(
                        s,
                        '71 kg',
                        'Target Weight',
                        Icons.track_changes_rounded,
                      ),
                      _buildDivider(s),
                      _buildInfoItem(
                        s,
                        '3 months',
                        'Duration',
                        Icons.calendar_month_rounded,
                      ),
                      _buildDivider(s),
                      _buildInfoItem(
                        s,
                        '30 Days',
                        'Meal Plan',
                        Icons.flatware_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 60 * s),

              // Placeholder Text
              Text(
                'Your personalized meal plans will appear here',
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  color: Colors.white.withValues(alpha: 0.3),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 60 * s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle(double s, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180 * s,
          height: 180 * s,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10 * s,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
          ),
        ),
        // Inner Content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_rounded,
              color: const Color(0xFF00F0FF),
              size: 32 * s,
            ),
            SizedBox(height: 8 * s),
            Text(
              '$_mealsCreated/$_totalMeals',
              style: GoogleFonts.outfit(
                fontSize: 28 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 16 * s,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatGridItem(
    double s,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 24 * s),
          SizedBox(height: 12 * s),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(double s, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 20 * s),
          SizedBox(height: 8 * s),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double s) {
    return Container(
      width: 1 * s,
      height: 60 * s,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

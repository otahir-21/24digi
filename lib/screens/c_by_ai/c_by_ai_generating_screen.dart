import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import 'providers/c_by_ai_provider.dart';
import 'c_by_ai_tracker_screen.dart';

class CByAiGeneratingScreen extends StatefulWidget {
  const CByAiGeneratingScreen({super.key});

  @override
  State<CByAiGeneratingScreen> createState() => _CByAiGeneratingScreenState();
}

class _CByAiGeneratingScreenState extends State<CByAiGeneratingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CByAiProvider>();
      provider.connectToStream().then((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CByAiTrackerScreen(initialIsCalendar: true),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Consumer<CByAiProvider>(
          builder: (context, provider, child) {
            final progress = (provider.generationProgress / 100).clamp(0.0, 1.0);
            final daysCreated = provider.currentGeneratingDay;
            final totalDays = provider.summary?.totalDays ?? 30; // fallback to 30
            final mealsCreated = provider.mealData.values.fold<int>(0, (prev, meals) => prev + meals.length);
            final targetWeight = provider.fitnessMetrics?.goal.contains('Lose') == true ? 'Target: Lose' : 'Maintain';

            return SingleChildScrollView(
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
                  _buildProgressCircle(s, progress, daysCreated, totalDays),

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
                    provider.progressMessage.isNotEmpty 
                        ? provider.progressMessage 
                        : 'Creating day $daysCreated of $totalDays...',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
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
                            '$daysCreated',
                            'Days Ready',
                            Icons.calendar_today_rounded,
                          ),
                          _buildDivider(s),
                          _buildStatGridItem(
                            s,
                            '${(totalDays - daysCreated).clamp(0, totalDays)}',
                            'Days Left',
                            Icons.access_time_rounded,
                          ),
                          _buildDivider(s),
                          _buildStatGridItem(
                            s,
                            '$mealsCreated',
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
                            targetWeight,
                            'Target Weight',
                            Icons.track_changes_rounded,
                          ),
                          _buildDivider(s),
                          _buildInfoItem(
                            s,
                            '$totalDays Days',
                            'Duration',
                            Icons.calendar_month_rounded,
                          ),
                          _buildDivider(s),
                          _buildInfoItem(
                            s,
                            '${provider.summary?.totalMeals ?? totalDays} Meals',
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCircle(double s, double progress, int daysCreated, int totalDays) {
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
              '$daysCreated/$totalDays',
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

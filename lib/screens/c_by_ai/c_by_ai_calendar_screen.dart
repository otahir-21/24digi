import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'providers/c_by_ai_provider.dart';
import 'c_by_ai_delivery_screen.dart';

class CByAiCalendarScreen extends StatefulWidget {
  const CByAiCalendarScreen({super.key});

  @override
  State<CByAiCalendarScreen> createState() => _CByAiCalendarScreenState();
}

class _CByAiCalendarScreenState extends State<CByAiCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Consumer<CByAiProvider>(
          builder: (context, provider, child) {
            final totalDays = provider.summary?.totalDays ?? 7;
            
            return Column(
              children: [
                const ShopTopBar(),
    
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: Column(
                      children: [
                        Text(
                          'HI, USER',
                          style: GoogleFonts.outfit(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16 * s),
    
                        // Day Selector
                        _buildDaySelector(s, provider),
    
                        SizedBox(height: 24 * s),
    
                        // Average Card
                        _buildAverageStatsCard(s, provider),
    
                        SizedBox(height: 20 * s),
    
                        // Daily Meal Plans List
                        ...List.generate(totalDays, (index) => _buildDailyPlanCard(s, index + 1, provider)),
    
                        SizedBox(height: 20 * s),
    
                        // Total Summary Card
                        _buildTotalSummaryCard(s, provider),
    
                        SizedBox(height: 32 * s),
    
                        // Regenerate Section
                        _buildRegenerateSection(s),
    
                        SizedBox(height: 40 * s),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDaySelector(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 7;
    final startDay = ((provider.selectedDay - 1) ~/ 7) * 7 + 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: provider.selectedDay > 1 ? () => provider.setSelectedDay(provider.selectedDay - 1) : null,
              icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
            Text(
              'Day ${provider.selectedDay}',
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4AC2CD),
              ),
            ),
            IconButton(
              onPressed: provider.selectedDay < totalDays ? () => provider.setSelectedDay(provider.selectedDay + 1) : null,
              icon: Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayIndex = startDay + index;
            if (dayIndex > totalDays) return SizedBox(width: 44 * s);
            bool isSelected = dayIndex == provider.selectedDay;
            return GestureDetector(
              onTap: () => provider.setSelectedDay(dayIndex),
              child: Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4AC2CD) : const Color(0xFF1B2329),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayIndex',
                  style: GoogleFonts.outfit(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.black : Colors.white24,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAverageStatsCard(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 7;
    final avgCal = (provider.summary?.totalCalories ?? 0) / (totalDays == 0 ? 1 : totalDays);
    final avgPro = (provider.summary?.totalProtein ?? 0) / (totalDays == 0 ? 1 : totalDays);
    final avgCar = (provider.summary?.totalCarbs ?? 0) / (totalDays == 0 ? 1 : totalDays);
    final avgFat = (provider.summary?.totalFat ?? 0) / (totalDays == 0 ? 1 : totalDays);

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF4AC2CD).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Column(
        children: [
          Text(
            '$totalDays-Day Average',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(s, avgCal.toInt().toString(), 'Cal/day', Icons.local_fire_department_rounded, Colors.redAccent),
              _statItem(s, '${avgPro.toStringAsFixed(1)}g', 'Protein/d', Icons.fitness_center_rounded, Colors.blue),
              _statItem(s, '${avgCar.toStringAsFixed(1)}g', 'Carbs/day', Icons.egg_rounded, Colors.green),
              _statItem(s, '${avgFat.toStringAsFixed(1)}g', 'Fat/day', Icons.water_drop_rounded, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    double s,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20 * s),
        SizedBox(height: 8 * s),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.outfit(
            fontSize: 9 * s,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyPlanCard(double s, int day, CByAiProvider provider) {
    bool isSelected = day == provider.selectedDay;
    final dailyTotal = provider.dailyTotals[day];
    final mealCount = provider.mealData[day]?.length ?? 0;

    return GestureDetector(
      onTap: () {
        provider.setSelectedDay(day);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * s),
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00F0FF)
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4AC2CD),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day\nDay',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 10 * s,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * s,
                              vertical: 2 * s,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4 * s),
                            ),
                            child: Text(
                              provider.fitnessMetrics?.goal.toUpperCase() ?? 'MAINTAIN',
                              style: GoogleFonts.outfit(
                                fontSize: 10 * s,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * s),
                          Text(
                            '${provider.fitnessMetrics?.tdee.toInt() ?? 2200} cal target',
                            style: GoogleFonts.outfit(
                              fontSize: 13 * s,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        mealCount > 0 ? '$mealCount Meals generated' : 'No meals generated yet',
                        style: GoogleFonts.outfit(
                          fontSize: 10 * s,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF00F0FF),
                  size: 24 * s,
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            const Divider(color: Colors.white10, height: 1),
            SizedBox(height: 16 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(s, '${dailyTotal?.calories.toInt() ?? 0}', 'Cal', Icons.local_fire_department_rounded),
                _miniStat(s, '${dailyTotal?.protein.toStringAsFixed(1) ?? "0.0"}g', 'Protein', Icons.fitness_center_rounded),
                _miniStat(s, '${dailyTotal?.carbs.toStringAsFixed(1) ?? "0.0"}g', 'Carbs', Icons.egg_rounded),
                _miniStat(s, '${dailyTotal?.fat.toStringAsFixed(1) ?? "0.0"}g', 'Fat', Icons.water_drop_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(double s, String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4AC2CD), size: 16 * s),
        SizedBox(height: 4 * s),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 12 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildTotalSummaryCard(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 7;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFF4AC2CD).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Total $totalDays Days',
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFEBC17B),
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalItem(s, '${provider.summary?.totalCalories.toInt() ?? 0}', 'Cal', Icons.local_fire_department_rounded),
              _totalItem(s, '${provider.summary?.totalProtein.toStringAsFixed(1) ?? "0.0"}g', 'Protein', Icons.fitness_center_rounded),
              _totalItem(s, '${provider.summary?.totalCarbs.toStringAsFixed(1) ?? "0.0"}g', 'Carbs', Icons.egg_rounded),
              _totalItem(s, '${provider.summary?.totalFat.toStringAsFixed(1) ?? "0.0"}g', 'Fat', Icons.water_drop_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalItem(double s, String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFEBC17B), size: 18 * s),
        SizedBox(height: 6 * s),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildRegenerateSection(double s) {
    return Container(
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regenerate meal options?',
            style: GoogleFonts.outfit(
              fontSize: 20 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00F0FF),
            ),
          ),
          SizedBox(height: 12 * s),
          Text(
            'This will replace your current\nmeal suggestions for today.',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: 32 * s),
          _btn(s, 'REGENERATE MEALS', const Color(0xFF4AC2CD), Colors.black),
          SizedBox(height: 16 * s),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CByAiDeliveryScreen()),
            ),
            child: _btn(
              s,
              'KEEP CURRENT MEALS',
              const Color(0xFF00F0FF),
              Colors.black,
            ),
          ),
          SizedBox(height: 32 * s),
          _footerNote(s, 'You can regenerate up to 3 times per delivery.'),
          _footerNote(s, 'Meal regeneration closes before dispatch.'),
          _footerNote(
            s,
            'Make sure to confirm your delivery location before dispatch.',
          ),
        ],
      ),
    );
  }

  Widget _btn(double s, String label, Color color, Color textColor) {
    return Container(
      width: double.infinity,
      height: 54 * s,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 16 * s,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  Widget _footerNote(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 11 * s, color: Colors.white24),
      ),
    );
  }
}

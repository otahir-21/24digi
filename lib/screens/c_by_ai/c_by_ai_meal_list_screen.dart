import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'c_by_ai_calendar_screen.dart';
import 'providers/c_by_ai_provider.dart';
import 'models/c_by_ai_models.dart';

class CByAiMealListScreen extends StatefulWidget {
  const CByAiMealListScreen({super.key});

  @override
  State<CByAiMealListScreen> createState() => _CByAiMealListScreenState();
}

class _CByAiMealListScreenState extends State<CByAiMealListScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Consumer<CByAiProvider>(
          builder: (context, provider, child) {
            final selectedDay = provider.selectedDay;
            final meals = provider.mealData[selectedDay] ?? [];
            final dailyTotal = provider.dailyTotals[selectedDay];
            final auth = context.watch<AuthProvider>();
            final rawName = auth.profile?.name?.trim();
            final greetingName =
                (rawName == null || rawName.isEmpty) ? 'USER' : rawName.toUpperCase();

            return Column(
              children: [
                const DigiPillHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: Column(
                      children: [
                        Text(
                          'HI, $greetingName',
                          style: GoogleFonts.outfit(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16 * s),

                        // Toggle Switch
                        _buildToggleSwitch(s),

                        SizedBox(height: 24 * s),

                        // Day Selector
                        _buildDaySelector(s, provider),

                        SizedBox(height: 24 * s),

                        // Average Stats Card
                        _buildAverageStatsCard(s, provider),

                        SizedBox(height: 32 * s),

                        // Detailed Meals List
                        if (meals.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40 * s),
                            child: Text(
                              'No meals for today',
                              style: GoogleFonts.outfit(color: Colors.white38),
                            ),
                          )
                        else
                          ...meals.map((meal) => _buildMealItem(s, meal)),

                        SizedBox(height: 32 * s),

                        // Daily Total Card
                        _buildDailyTotalCard(s, dailyTotal),

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

  Widget _buildToggleSwitch(double s) {
    return Container(
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleItem('Plan', true, s)),
          Expanded(child: _toggleItem('Calender', false, s)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, double s) {
    return GestureDetector(
      onTap: () {
        if (label == 'Calender') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CByAiCalendarScreen()),
          );
        }
      },
      child: Container(
        height: 40 * s,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 7;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: provider.selectedDay > 1
                  ? () => provider.setSelectedDay(provider.selectedDay - 1)
                  : null,
              icon: Icon(
                Icons.chevron_left_rounded,
                color: const Color(0xFF00F0FF),
                size: 28 * s,
              ),
            ),
            Text(
              'Day ${provider.selectedDay}',
              style: GoogleFonts.outfit(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            IconButton(
              onPressed: provider.selectedDay < totalDays
                  ? () => provider.setSelectedDay(provider.selectedDay + 1)
                  : null,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF00F0FF),
                size: 28 * s,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(totalDays, (index) {
              int dayNum = index + 1;
              bool isSelected = dayNum == provider.selectedDay;
              return GestureDetector(
                onTap: () => provider.setSelectedDay(dayNum),
                child: Container(
                  width: 40 * s,
                  height: 40 * s,
                  margin: EdgeInsets.only(right: 12 * s),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4AC2CD)
                        : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAverageStatsCard(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 7;
    final avgCal =
        (provider.summary?.totalCalories ?? 0) /
        (totalDays == 0 ? 1 : totalDays);
    final avgPro =
        (provider.summary?.totalProtein ?? 0) /
        (totalDays == 0 ? 1 : totalDays);
    final avgCar =
        (provider.summary?.totalCarbs ?? 0) / (totalDays == 0 ? 1 : totalDays);
    final avgFat =
        (provider.summary?.totalFat ?? 0) / (totalDays == 0 ? 1 : totalDays);

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$totalDays-Day Average',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                s,
                avgCal.toInt().toString(),
                'Cal/day',
                Icons.local_fire_department_rounded,
                Colors.redAccent,
              ),
              _statItem(
                s,
                '${avgPro.toStringAsFixed(1)}g',
                'Protein/d',
                Icons.fitness_center_rounded,
                Colors.blue,
              ),
              _statItem(
                s,
                '${avgCar.toStringAsFixed(1)}g',
                'Carbs/day',
                Icons.egg_rounded,
                Colors.green,
              ),
              _statItem(
                s,
                '${avgFat.toStringAsFixed(1)}g',
                'Fat/day',
                Icons.water_drop_rounded,
                Colors.orange,
              ),
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

  Widget _buildMealItem(double s, MealModel meal) {
    IconData mealIcon = Icons.restaurant_rounded;
    if (meal.type.toLowerCase().contains('coffee'))
      mealIcon = Icons.coffee_rounded;
    if (meal.type.toLowerCase().contains('snack'))
      mealIcon = Icons.apple_rounded;
    if (meal.type.toLowerCase().contains('dinner'))
      mealIcon = Icons.dinner_dining_rounded;

    return GestureDetector(
      onTap: () => _showMealDetailPopup(context, s, meal),
      child: Container(
        margin: EdgeInsets.only(bottom: 24 * s),
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(mealIcon, color: const Color(0xFF00F0FF), size: 28 * s),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.time,
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          color: Colors.white38,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        meal.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      meal.totalCal.toInt().toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Cal',
                      style: GoogleFonts.outfit(
                        fontSize: 10 * s,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _macroItem(
                  s,
                  '${meal.totalProtein.toStringAsFixed(1)}g',
                  'Protein',
                ),
                _macroItem(
                  s,
                  '${meal.totalCarbs.toStringAsFixed(1)}g',
                  'Carbs',
                ),
                _macroItem(s, '${meal.totalFat.toStringAsFixed(1)}g', 'Fat'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetailPopup(BuildContext context, double s, MealModel meal) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320 * s,
          padding: EdgeInsets.all(24 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2329),
            borderRadius: BorderRadius.circular(24 * s),
            border: Border.all(
              color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meal.name,
                      style: GoogleFonts.outfit(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(4 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18 * s,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24 * s),
              Text(
                'Ingredients',
                style: GoogleFonts.outfit(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(height: 12 * s),
              ...meal.ingredients.map(
                (ing) => Padding(
                  padding: EdgeInsets.only(bottom: 8 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ing.name,
                          style: GoogleFonts.outfit(
                            fontSize: 14 * s,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Text(
                        ing.amount,
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24 * s),
              Text(
                'Nutritional Information',
                style: GoogleFonts.outfit(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(height: 16 * s),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12 * s,
                crossAxisSpacing: 12 * s,
                childAspectRatio: 2.2,
                children: [
                  _nutritionBox(
                    s,
                    meal.totalCal.toInt().toString(),
                    'Calories',
                  ),
                  _nutritionBox(
                    s,
                    '${meal.totalProtein.toStringAsFixed(1)}g',
                    'Protein',
                  ),
                  _nutritionBox(
                    s,
                    '${meal.totalCarbs.toStringAsFixed(1)}g',
                    'Carbs',
                  ),
                  _nutritionBox(
                    s,
                    '${meal.totalFat.toStringAsFixed(1)}g',
                    'Fat',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionBox(double s, String val, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4AC2CD).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 18 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroItem(double s, String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white70,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildDailyTotalCard(double s, DailyTotalModel? dailyTotal) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(
          color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Daily Total',
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00F0FF),
            ),
          ),
          SizedBox(height: 20 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalStat(
                s,
                '${dailyTotal?.calories.toInt() ?? 0}',
                'Cal',
                Icons.local_fire_department_rounded,
                Colors.redAccent,
              ),
              _totalStat(
                s,
                '${dailyTotal?.protein.toStringAsFixed(1) ?? "0.0"}g',
                'Protein',
                Icons.fitness_center_rounded,
                Colors.blue,
              ),
              _totalStat(
                s,
                '${dailyTotal?.carbs.toStringAsFixed(1) ?? "0.0"}g',
                'Carbs',
                Icons.egg_rounded,
                Colors.green,
              ),
              _totalStat(
                s,
                '${dailyTotal?.fat.toStringAsFixed(1) ?? "0.0"}g',
                'Fat',
                Icons.water_drop_rounded,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalStat(
    double s,
    String val,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18 * s),
        SizedBox(height: 8 * s),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w800,
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
}

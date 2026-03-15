import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_delivery_screen.dart';
import 'providers/c_by_ai_provider.dart';
import 'models/c_by_ai_models.dart';

class CByAiTrackerScreen extends StatefulWidget {
  final bool initialIsCalendar;
  const CByAiTrackerScreen({super.key, this.initialIsCalendar = false});

  @override
  State<CByAiTrackerScreen> createState() => _CByAiTrackerScreenState();
}

class _CByAiTrackerScreenState extends State<CByAiTrackerScreen> {
  late bool _isCalendar;

  @override
  void initState() {
    super.initState();
    _isCalendar = widget.initialIsCalendar;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Consumer<CByAiProvider>(
          builder: (context, provider, child) {
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
                        
                        // Toggle Switch
                        _buildToggleSwitch(s),
                        
                        SizedBox(height: 24 * s),
                        
                        if (_isCalendar) _buildCalendarContent(s, provider) else _buildListContent(s, provider),
                        
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
          Expanded(child: _toggleItem('List', !_isCalendar, s)),
          Expanded(child: _toggleItem('Calender', _isCalendar, s)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, double s) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCalendar = (label == 'Calender');
        });
      },
      child: Container(
        height: 44 * s,
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

  // --- List View Content ---
  Widget _buildListContent(double s, CByAiProvider provider) {
    final dayData = provider.mealData[provider.selectedDay] ?? [];
    return Column(
      children: [
        // Week / Day Selector
        _buildWeekDaySelector(s, provider),
        
        SizedBox(height: 24 * s),
        
        // 30-Day Average Card (Teal)
        _buildAverageStatsCard(s, provider, isDark: false),
        
        SizedBox(height: 32 * s),
        
        // Detailed Meals List
        if (dayData.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40 * s),
              child: Text(
                'No meals generated for Day ${provider.selectedDay}',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16 * s),
              ),
            ),
          )
        else
          ...dayData.map((meal) {
            IconData icon = Icons.restaurant_rounded;
            final mType = meal.type.toLowerCase();
            if (mType.contains('breakfast') || mType.contains('morning')) icon = Icons.breakfast_dining_rounded;
            else if (mType.contains('dinner')) icon = Icons.dinner_dining_rounded;
            else if (mType.contains('snack')) icon = Icons.cookie_rounded;
            
            final targetTime = meal.time.isNotEmpty ? meal.time : (
              mType.contains('breakfast') ? '08:00' :
              mType.contains('lunch') ? '12:00' :
              mType.contains('dinner') ? '19:00' : '15:00'
            );

            return _buildMealItem(s, targetTime, meal.name, '${meal.totalCal.toInt()} Cal', icon, meal);
          }),
        
        SizedBox(height: 32 * s),
        
        // Daily Total Card
        _buildDailyTotalCard(s, provider),
      ],
    );
  }

  // --- Calendar View Content ---
  Widget _buildCalendarContent(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 30;
    
    return Column(
      children: [
        // Day Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (provider.selectedDay > 1) {
                  provider.setSelectedDay(provider.selectedDay - 1);
                }
              },
              child: Icon(Icons.chevron_left_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
            Text(
              'Day ${provider.selectedDay}',
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4AC2CD),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (provider.selectedDay < totalDays) {
                  provider.setSelectedDay(provider.selectedDay + 1);
                }
              },
              child: Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        
        // Day selector circles
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(totalDays, (index) {
              final day = index + 1;
              bool isSelected = day == provider.selectedDay;
              return GestureDetector(
                onTap: () => provider.setSelectedDay(day),
                child: Container(
                  width: 50 * s,
                  height: 50 * s,
                  margin: EdgeInsets.only(right: 12 * s),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4AC2CD) : const Color(0xFF1B2329),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: GoogleFonts.outfit(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black : Colors.white24,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        SizedBox(height: 24 * s),
        
        // 30-Day Average Card (Teal)
        _buildAverageStatsCard(s, provider, isDark: false),
        
        SizedBox(height: 24 * s),
        
        // Daily Cards (show for selected day only, or a few based on design)
        _buildDailyPlanCard(s, provider.selectedDay, provider),
        
        SizedBox(height: 20 * s),
        
        // Total Summary Card
        _buildTotalSummaryCard(s, provider),
        
        SizedBox(height: 32 * s),
        
        // Regenerate Section
        _buildRegenerateSection(s),
      ],
    );
  }

  // --- Shared Reusable Widgets ---

  Widget _buildWeekDaySelector(double s, CByAiProvider provider) {
    final startDay = ((provider.selectedDay - 1) ~/ 7) * 7 + 1;
    final totalDays = provider.summary?.totalDays ?? 30;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (startDay > 1) {
                  provider.setSelectedDay(startDay - 1);
                }
              },
              child: Icon(Icons.chevron_left_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
            Text(
              'Week ${(startDay - 1) ~/ 7 + 1}',
              style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
            GestureDetector(
              onTap: () {
                if (startDay + 7 <= totalDays) {
                  provider.setSelectedDay(startDay + 7);
                }
              },
              child: Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = startDay + index;
            if (day > totalDays) return SizedBox(width: 36 * s);

            bool isSelected = day == provider.selectedDay;
            return GestureDetector(
              onTap: () => provider.setSelectedDay(day),
              child: Container(
                width: 36 * s, height: 36 * s,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4AC2CD) : Colors.white10,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('$day', style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: isSelected ? Colors.black : Colors.white70)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAverageStatsCard(double s, CByAiProvider provider, {bool isDark = true}) {
    final avgCal = (provider.summary?.totalCalories ?? 0.0) / (provider.summary?.totalDays == 0 ? 1 : (provider.summary?.totalDays ?? 1));
    final avgPro = (provider.summary?.totalProtein ?? 0.0) / (provider.summary?.totalDays == 0 ? 1 : (provider.summary?.totalDays ?? 1));
    final avgCar = (provider.summary?.totalCarbs ?? 0.0) / (provider.summary?.totalDays == 0 ? 1 : (provider.summary?.totalDays ?? 1));
    final avgFat = (provider.summary?.totalFat ?? 0.0) / (provider.summary?.totalDays == 0 ? 1 : (provider.summary?.totalDays ?? 1));

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2329).withValues(alpha: 0.6) : const Color(0xFF4AC2CD).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20 * s),
        border: isDark ? Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.2)) : null,
      ),
      child: Column(
        children: [
          Text(
            '${provider.summary?.totalDays ?? 30}-Day Average',
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black,
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(s, avgCal.toInt().toString(), 'Cal/day', Icons.local_fire_department_rounded, Colors.redAccent, isDark),
              _statItem(s, '${avgPro.toStringAsFixed(1)}g', 'Protein/d', Icons.fitness_center_rounded, Colors.blue, isDark),
              _statItem(s, '${avgCar.toStringAsFixed(1)}g', 'Carbs/d', Icons.egg_rounded, Colors.green, isDark),
              _statItem(s, '${avgFat.toStringAsFixed(1)}g', 'Fat/day', Icons.water_drop_rounded, Colors.orange, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(double s, String value, String unit, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20 * s),
        SizedBox(height: 8 * s),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black),
        ),
        Text(
          unit,
          style: GoogleFonts.outfit(fontSize: 9 * s, color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildMealItem(double s, String time, String title, String cal, IconData icon, MealModel meal) {
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
                Icon(icon, color: const Color(0xFF00F0FF), size: 28 * s),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38)),
                      SizedBox(height: 4 * s),
                      Text(title, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(cal.split(' ')[0], style: GoogleFonts.outfit(fontSize: 20 * s, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Cal', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _macroItem(s, '${meal.totalProtein.toStringAsFixed(1)}g', 'Protein'),
                _macroItem(s, '${meal.totalCarbs.toStringAsFixed(1)}g', 'Carbs'),
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
            border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.2)),
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
                      meal.name.isNotEmpty ? meal.name : 'Meal Detail',
                      style: GoogleFonts.outfit(fontSize: 22 * s, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(4 * s),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white, size: 18 * s),
                    ),
                  ),
                ],
              ),
              if (meal.instructions.isNotEmpty) ...[
                SizedBox(height: 12 * s),
                Text(
                  meal.instructions.isEmpty ? 'Prepare as directed' : meal.instructions,
                  style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70),
                ),
              ],
              SizedBox(height: 24 * s),
              Text('Ingredients', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
              SizedBox(height: 12 * s),
              if (meal.ingredients.isEmpty)
                Text('No ingredients provided.', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60)),
              ...meal.ingredients.map((ing) => Padding(
                padding: EdgeInsets.only(bottom: 6 * s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(ing.name, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60))),
                    Text(ing.amount, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60)),
                  ],
                ),
              )),
              if (meal.sauces.isNotEmpty) ...[
                SizedBox(height: 16 * s),
                Text('Sauces/Extras', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
                SizedBox(height: 12 * s),
                ...meal.sauces.map((sItem) => Padding(
                  padding: EdgeInsets.only(bottom: 6 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(sItem.name, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60))),
                      Text(sItem.amount, style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60)),
                    ],
                  ),
                )),
              ],
              SizedBox(height: 24 * s),
              Text('Nutritional Information', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
              SizedBox(height: 16 * s),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12 * s,
                crossAxisSpacing: 12 * s,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   _nutritionBox(s, meal.totalCal.toInt().toString(), 'Calories'),
                  _nutritionBox(s, '${meal.totalProtein.toStringAsFixed(1)}g', 'Protein'),
                  _nutritionBox(s, '${meal.totalCarbs.toStringAsFixed(1)}g', 'Carbs'),
                  _nutritionBox(s, '${meal.totalFat.toStringAsFixed(1)}g', 'Fat'),
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
          Text(val, style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _macroItem(double s, String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: Colors.white70)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white24)),
      ],
    );
  }

  Widget _buildDailyTotalCard(double s, CByAiProvider provider) {
    final dailyTotal = provider.dailyTotals[provider.selectedDay];
    
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text('Daily Total', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w800, color: const Color(0xFF00F0FF))),
          SizedBox(height: 20 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalStat(s, '${dailyTotal?.calories.toInt() ?? 0}', 'Cal', Icons.local_fire_department_rounded, Colors.redAccent),
              _totalStat(s, '${dailyTotal?.protein.toStringAsFixed(1) ?? '0.0'}g', 'Protein', Icons.fitness_center_rounded, Colors.blue),
              _totalStat(s, '${dailyTotal?.carbs.toStringAsFixed(1) ?? '0.0'}g', 'Carbs', Icons.egg_rounded, Colors.green),
              _totalStat(s, '${dailyTotal?.fat.toStringAsFixed(1) ?? '0.0'}g', 'Fat', Icons.water_drop_rounded, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalStat(double s, String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18 * s),
        SizedBox(height: 8 * s),
        Text(val, style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38)),
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
        setState(() {
          _isCalendar = false;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * s),
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F0FF) : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44 * s, height: 44 * s,
                  decoration: const BoxDecoration(color: Color(0xFF4AC2CD), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$day\nDay', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.black, fontWeight: FontWeight.w900)),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 2 * s),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4 * s)),
                            child: Text(provider.fitnessMetrics?.goal.contains('Lose') == true ? 'LOSE' : 'MAINTAIN', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(width: 8 * s),
                          Text('${provider.fitnessMetrics?.tdee.toInt() ?? 2400} cal target', style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Text('$mealCount Meals (AI Curated Day $day)', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 24 * s),
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
        Text(val, style: GoogleFonts.outfit(fontSize: 12 * s, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38)),
      ],
    );
  }

  Widget _buildTotalSummaryCard(double s, CByAiProvider provider) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFF4AC2CD).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Total ${provider.summary?.totalDays ?? 30} Days', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w800, color: const Color(0xFFEBC17B))),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalItem(s, '${provider.summary?.totalCalories.toInt() ?? 0}', 'Cal', Icons.local_fire_department_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '${provider.summary?.totalProtein.toStringAsFixed(1) ?? "0.0"}g', 'Protein', Icons.fitness_center_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '${provider.summary?.totalCarbs.toStringAsFixed(1) ?? "0.0"}g', 'Carbs', Icons.egg_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '${provider.summary?.totalFat.toStringAsFixed(1) ?? "0.0"}g', 'Fat', Icons.water_drop_rounded, const Color(0xFFEBC17B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalItem(double s, String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18 * s),
        SizedBox(height: 6 * s),
        Text(val, style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.white38)),
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
          Text('Regenerate meal options?', style: GoogleFonts.outfit(fontSize: 20 * s, fontWeight: FontWeight.w700, color: const Color(0xFF00F0FF))),
          SizedBox(height: 12 * s),
          Text('This will replace your current\nmeal suggestions for today.', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70, height: 1.4)),
          SizedBox(height: 32 * s),
          _btn(s, 'REGENERATE MEALS', const Color(0xFF4AC2CD), Colors.black),
          SizedBox(height: 16 * s),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CByAiDeliveryScreen())),
            child: _btn(s, 'KEEP CURRENT MEALS', const Color(0xFF00F0FF), Colors.black),
          ),
          SizedBox(height: 32 * s),
          _footerNote(s, 'You can regenerate up to 3 times per delivery.'),
          _footerNote(s, 'Meal regeneration closes before dispatch.'),
          _footerNote(s, 'Make sure to confirm your delivery location before dispatch.'),
        ],
      ),
    );
  }

  Widget _btn(double s, String label, Color color, Color textColor) {
    return Container(
      width: double.infinity, height: 54 * s,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16 * s)),
      alignment: Alignment.center,
      child: Text(label, style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w900, color: textColor)),
    );
  }

  Widget _footerNote(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 11 * s, color: Colors.white24)),
    );
  }
}

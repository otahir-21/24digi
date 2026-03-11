import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'c_by_ai_delivery_screen.dart';

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
        child: Column(
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
                    
                    if (_isCalendar) _buildCalendarContent(s) else _buildListContent(s),
                    
                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
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
  Widget _buildListContent(double s) {
    return Column(
      children: [
        // Week / Day Selector
        _buildWeekDaySelector(s),
        
        SizedBox(height: 24 * s),
        
        // 30-Day Average Card (Teal)
        _buildAverageStatsCard(s, isDark: false),
        
        SizedBox(height: 32 * s),
        
        // Detailed Meals List
        _buildMealItem(s, '06:30', 'Morning Coffee', '2 Cal', Icons.coffee_rounded),
        _buildMealItem(s, '07:00', 'Breakfast Meal', '2 Cal', Icons.breakfast_dining_rounded),
        _buildMealItem(s, '10:00', 'Mid of Morning snack', '2 Cal', Icons.apple_rounded),
        _buildMealItem(s, '12:30', 'Lunch Meal', '2 Cal', Icons.restaurant_rounded),
        _buildMealItem(s, '15:30', 'Afternoon Snack', '2 Cal', Icons.cookie_rounded),
        _buildMealItem(s, '19:00', 'Dinner Meal', '2 Cal', Icons.dinner_dining_rounded),
        
        SizedBox(height: 32 * s),
        
        // Daily Total Card
        _buildDailyTotalCard(s),
      ],
    );
  }

  // --- Calendar View Content ---
  Widget _buildCalendarContent(double s) {
    return Column(
      children: [
        // Day Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chevron_left_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            Text(
              'Day 1',
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4AC2CD),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
          ],
        ),
        SizedBox(height: 16 * s),
        
        // Day selector circles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            bool isSelected = index == 0;
            return Container(
              width: 50 * s,
              height: 50 * s,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4AC2CD) : const Color(0xFF1B2329),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.black : Colors.white24,
                ),
              ),
            );
          }),
        ),
        
        SizedBox(height: 24 * s),
        
        // 30-Day Average Card (Teal)
        _buildAverageStatsCard(s, isDark: false),
        
        SizedBox(height: 24 * s),
        
        // Daily Cards
        _buildDailyPlanCard(s, 1),
        _buildDailyPlanCard(s, 2),
        _buildDailyPlanCard(s, 3),
        
        SizedBox(height: 20 * s),
        
        // Total Summary Card
        _buildTotalSummaryCard(s),
        
        SizedBox(height: 32 * s),
        
        // Regenerate Section
        _buildRegenerateSection(s),
      ],
    );
  }

  // --- Shared Reusable Widgets ---

  Widget _buildWeekDaySelector(double s) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chevron_left_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
            Text(
              'Week 1',
              style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            bool isSelected = index == 0;
            return Container(
              width: 36 * s, height: 36 * s,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4AC2CD) : Colors.white10,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}', style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w800, color: isSelected ? Colors.black : Colors.white70)),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAverageStatsCard(double s, {bool isDark = true}) {
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
            '30-Day Average',
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
              _statItem(s, '1604', 'Cal/day', Icons.local_fire_department_rounded, Colors.redAccent, isDark),
              _statItem(s, '112.0g', 'Protein/d', Icons.fitness_center_rounded, Colors.blue, isDark),
              _statItem(s, '173.0g', 'Carbs/d', Icons.egg_rounded, Colors.green, isDark),
              _statItem(s, '54.00g', 'Fat/day', Icons.water_drop_rounded, Colors.orange, isDark),
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

  Widget _buildMealItem(double s, String time, String title, String cal, IconData icon) {
    return GestureDetector(
      onTap: () => _showMealDetailPopup(context, s, title),
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
                _macroItem(s, '0.00g', 'Protein'),
                _macroItem(s, '0.00g', 'Carbs'),
                _macroItem(s, '0.00g', 'Fat'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetailPopup(BuildContext context, double s, String title) {
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
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 22 * s, fontWeight: FontWeight.w700, color: Colors.white),
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
              SizedBox(height: 24 * s),
              Text('Ingredients', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
              SizedBox(height: 12 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Black Coffee', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60)),
                  Text('200 ml', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white60)),
                ],
              ),
              SizedBox(height: 24 * s),
              Text('Nutritional Information', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
              SizedBox(height: 16 * s),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12 * s,
                crossAxisSpacing: 12 * s,
                childAspectRatio: 2.2,
                children: [
                  _nutritionBox(s, '2', 'Calories'),
                  _nutritionBox(s, '0.00g', 'Protein'),
                  _nutritionBox(s, '0.00g', 'Carbs'),
                  _nutritionBox(s, '0.00g', 'Fat'),
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

  Widget _buildDailyTotalCard(double s) {
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
              _totalStat(s, '1604', 'Cal', Icons.local_fire_department_rounded, Colors.redAccent),
              _totalStat(s, '112.0g', 'Protein', Icons.fitness_center_rounded, Colors.blue),
              _totalStat(s, '173.0g', 'Carbs', Icons.egg_rounded, Colors.green),
              _totalStat(s, '54.00g', 'Fat', Icons.water_drop_rounded, Colors.orange),
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

  Widget _buildDailyPlanCard(double s, int day) {
    bool isSelected = day == 2;
    return GestureDetector(
      onTap: () {
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
                            child: Text('LOSE', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(width: 8 * s),
                          Text('2207 cal target', style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Text('7 Meals (coffee, breakfast, snack, lunch, dinner, dessert)', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
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
                _miniStat(s, '1699', 'Cal', Icons.local_fire_department_rounded),
                _miniStat(s, '132.51g', 'Protein', Icons.fitness_center_rounded),
                _miniStat(s, '149.05g', 'Carbs', Icons.egg_rounded),
                _miniStat(s, '62.48g', 'Fat', Icons.water_drop_rounded),
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

  Widget _buildTotalSummaryCard(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2329).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFF4AC2CD).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Total 3 Days', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w800, color: const Color(0xFFEBC17B))),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalItem(s, '4800', 'Cal', Icons.local_fire_department_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '336.00g', 'Protein', Icons.fitness_center_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '489.00g', 'Carbs', Icons.egg_rounded, const Color(0xFFEBC17B)),
              _totalItem(s, '197.00g', 'Fat', Icons.water_drop_rounded, const Color(0xFFEBC17B)),
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

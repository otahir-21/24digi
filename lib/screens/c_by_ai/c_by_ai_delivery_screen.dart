import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'providers/c_by_ai_provider.dart';
import 'c_by_ai_address_selection_screen.dart';
import 'c_by_ai_tracker_screen.dart';
import 'c_by_ai_meal_list_screen.dart';

class CByAiDeliveryScreen extends StatefulWidget {
  const CByAiDeliveryScreen({super.key});

  @override
  State<CByAiDeliveryScreen> createState() => _CByAiDeliveryScreenState();
}

class _CByAiDeliveryScreenState extends State<CByAiDeliveryScreen> {
  double? _frequency;
  bool _useFuture = false;

  @override
  void initState() {
    super.initState();
    _frequency = context.read<CByAiProvider>().deliveryFrequency.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Consumer<CByAiProvider>(
          builder: (context, provider, child) {
            final totalDays = provider.summary?.totalDays ?? 28;
            
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
    
                        // Navigation Toggles (List / Calendar)
                        _buildToggleSwitch(s),
    
                        SizedBox(height: 24 * s),
    
                        // 28-Day Average Card
                        _buildAverageStatsCard(s, provider),
    
                        SizedBox(height: 24 * s),
    
                        Text(
                          '$totalDays-Day Meal Plan',
                          style: GoogleFonts.outfit(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16 * s),
    
                        // Meal Summary Card
                        _buildMealSummaryCard(s, provider),
    
                        SizedBox(height: 24 * s),
    
                        // Delivery Location Section
                        _buildDeliverySection(s, provider),
    
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
          Expanded(child: _toggleItem('List', false, s)),
          Expanded(child: _toggleItem('Calender', false, s)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, double s) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => CByAiTrackerScreen(initialIsCalendar: label == 'Calender'))
        );
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

  Widget _buildAverageStatsCard(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 28;
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

  Widget _statItem(double s, String value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20 * s),
        SizedBox(height: 8 * s),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 15 * s, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        Text(
          unit,
          style: GoogleFonts.outfit(fontSize: 9 * s, color: Colors.black.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildMealSummaryCard(double s, CByAiProvider provider) {
    final totalDays = provider.summary?.totalDays ?? 28;
    final totalMeals = provider.summary?.totalMeals ?? 0;
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CByAiMealListScreen()),
      ),
      child: Container(
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44 * s, height: 44 * s,
                  decoration: const BoxDecoration(color: Color(0xFF4AC2CD), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$totalDays\nDays', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.black, fontWeight: FontWeight.w900)),
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
                            child: Text(provider.fitnessMetrics?.goal.toUpperCase() ?? 'MAINTAIN', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(width: 8 * s),
                          Text('${provider.fitnessMetrics?.tdee.toInt() ?? 2200} cal target', style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 6 * s),
                      Text('$totalMeals Meals personalized for you', style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white38)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
              ],
            ),
            SizedBox(height: 16 * s),
            const Divider(color: Colors.white10, height: 1),
            SizedBox(height: 16 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(s, '${provider.summary?.totalCalories.toInt() ?? 0}', 'Cal', Icons.local_fire_department_rounded),
                _miniStat(s, '${provider.summary?.totalProtein.toStringAsFixed(1) ?? "0.0"}g', 'Protein', Icons.fitness_center_rounded),
                _miniStat(s, '${provider.summary?.totalCarbs.toStringAsFixed(1) ?? "0.0"}g', 'Carbs', Icons.egg_rounded),
                _miniStat(s, '${provider.summary?.totalFat.toStringAsFixed(1) ?? "0.0"}g', 'Fat', Icons.water_drop_rounded),
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

  Widget _buildDeliverySection(double s, CByAiProvider provider) {
    final building = provider.deliveryBuilding ?? 'Building Name';
    final address = provider.deliveryAddress ?? 'Apartment number, Street Number/Name, City Name, Emirate, UAE';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: const Color(0xFF00F0FF), size: 20 * s),
                  SizedBox(width: 8 * s),
                  Text('Delivery location', style: GoogleFonts.outfit(fontSize: 18 * s, fontWeight: FontWeight.w700, color: const Color(0xFF00F0FF))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CByAiAddressSelectionScreen())),
                child: Row(
                  children: [
                    Text('Edit', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
                    SizedBox(width: 4 * s),
                    Icon(Icons.edit_outlined, color: Colors.white70, size: 16 * s),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * s),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building,
                  style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (provider.deliveryFloor != null)
                  Text(
                    'Floor: ${provider.deliveryFloor}',
                    style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white70),
                  ),
                SizedBox(height: 4 * s),
                Text(
                  address,
                  style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white60, height: 1.4),
                ),
                if (provider.deliveryLandmark != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4 * s),
                    child: Text(
                      'Landmark: ${provider.deliveryLandmark}',
                      style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
          Center(
            child: Text(
              'We\'ll deliver here unless you update it.',
              style: GoogleFonts.outfit(fontSize: 11 * s, color: Colors.white24),
            ),
          ),
          SizedBox(height: 32 * s),
          GestureDetector(
            onTap: () => setState(() => _useFuture = !_useFuture),
            child: Row(
              children: [
                Icon(
                  _useFuture ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: const Color(0xFF00F0FF),
                  size: 24 * s,
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Use this location for future deliveries', style: GoogleFonts.outfit(fontSize: 14 * s, color: const Color(0xFF00F0FF))),
                      Text('You can change this anytime.', style: GoogleFonts.outfit(fontSize: 11 * s, color: Colors.white24)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * s),
          Text('Delivery Frequency', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: const Color(0xFF00F0FF))),
          SizedBox(height: 16 * s),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00F0FF),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFF00F0FF),
              overlayColor: const Color(0xFF00F0FF).withValues(alpha: 0.1),
              trackHeight: 4 * s,
            ),
            child: Slider(
              value: _frequency ?? 3.0,
              min: 1,
              max: 4,
              divisions: 3,
              onChanged: (val) => setState(() => _frequency = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3', '4'].map((e) => Text(e, style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38))).toList(),
          ),
          SizedBox(height: 24 * s),
          Center(
            child: Column(
              children: [
                Text('Delivery schedule: Every ${(_frequency ?? 3.0).toInt()} days', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white70)),
                SizedBox(height: 4 * s),
                Text('Next delivery: Tomorrow', style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white38)),
              ],
            ),
          ),
          SizedBox(height: 32 * s),
          GestureDetector(
            onTap: () async {
              await provider.saveDeliveryAddress(
                building: provider.deliveryBuilding ?? building,
                address: provider.deliveryAddress ?? address,
                floor: provider.deliveryFloor,
                landmark: provider.deliveryLandmark,
                fullName: provider.deliveryFullName,
                addressTitle: provider.deliveryAddressTitle,
                frequency: (_frequency ?? 3.0).toInt(),
                useForFuture: _useFuture,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 54 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF00F0FF),
                borderRadius: BorderRadius.circular(16 * s),
              ),
              alignment: Alignment.center,
              child: Text(
                'CONFIRM',
                style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

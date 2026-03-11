import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'c_by_ai_generating_screen.dart';

class CByAiCalculatingScreen extends StatefulWidget {
  const CByAiCalculatingScreen({super.key});

  @override
  State<CByAiCalculatingScreen> createState() => _CByAiCalculatingScreenState();
}

class _CByAiCalculatingScreenState extends State<CByAiCalculatingScreen> {
  int _currentStep = 1;
  final int _totalSteps = 7;
  Timer? _timer;

  final List<String> _stepTitles = [
    "Analyzing Physical Data",
    "Reviewing Activity Levels",
    "Calculating Nutritional Needs",
    "Processing Diet Preferences",
    "Evaluating Health Goals",
    "Optimizing Macronutrients",
    "Finalizing Assessment"
  ];

  final List<String> _stepSubtitles = [
    "Processing height, weight, and age metrics...",
    "Assessing daily calorie expenditure...",
    "Determining your optimal nutrient requirements...",
    "Applying your taste and dietary choices...",
    "Aligning plan with your target weight...",
    "Balancing proteins, fats, and carbs...",
    "Almost ready to generate your plan..."
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStep < _totalSteps) {
        setState(() {
          _currentStep++;
        });
      } else {
        _timer?.cancel();
        _navigateToGenerating();
      }
    });
  }

  void _navigateToGenerating() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CByAiGeneratingScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    double progress = _currentStep / _totalSteps;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                
                const Spacer(),

                // Animated Icon Circle
                _buildAnimatedIcon(s),
                
                SizedBox(height: 40 * s),

                // Text Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40 * s),
                  child: Column(
                    children: [
                      Text(
                        _stepTitles[_currentStep - 1],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      Text(
                        _stepSubtitles[_currentStep - 1],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 32 * s),
                      Text(
                        'Step $_currentStep of $_totalSteps',
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * s),

                // Progress Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40 * s),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 6 * s,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3 * s),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: (MediaQuery.of(context).size.width - 80 * s) * progress,
                        height: 6 * s,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F0FF), Color(0xFF00A3FF)],
                          ),
                          borderRadius: BorderRadius.circular(3 * s),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Footer
                Padding(
                  padding: EdgeInsets.only(bottom: 40 * s),
                  child: Text(
                    'Powered by 24DIGI AI',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            
            // Robot Icon Top Right
            Positioned(
              top: 20 * s,
              right: 20 * s,
              child: Container(
                width: 64 * s,
                height: 64 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A).withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: const Color(0xFF00F0FF),
                  size: 32 * s,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(double s) {
    return Container(
      width: 140 * s,
      height: 140 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF4AC2CD).withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4AC2CD).withValues(alpha: 0.3),
          width: 2 * s,
        ),
      ),
      child: Center(
        child: Container(
          width: 90 * s,
          height: 90 * s,
          decoration: const BoxDecoration(
            color: Color(0xFF4AC2CD),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 40 * s,
                ),
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(2 * s),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4AC2CD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 16 * s,
                    ),
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

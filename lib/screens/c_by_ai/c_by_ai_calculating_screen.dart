import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'c_by_ai_generating_screen.dart';
import 'c_by_ai_tracker_screen.dart';
import 'providers/c_by_ai_provider.dart';

class CByAiCalculatingScreen extends StatefulWidget {
  /// Optional pre-built user info. When provided the calculating screen skips
  /// calling `fetchUserData()` and passes this map directly to `generateMeals()`.
  final Map<String, dynamic>? userInfo;

  const CByAiCalculatingScreen({super.key, this.userInfo});

  @override
  State<CByAiCalculatingScreen> createState() => _CByAiCalculatingScreenState();
}

class _CByAiCalculatingScreenState extends State<CByAiCalculatingScreen> {
  int _currentStep = 1;
  final int _totalSteps = 7;
  Timer? _timer;
  bool _backendReady = false;
  String? _backendError;

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
    // Defer backend until after build so provider.notifyListeners() doesn't run during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runBackend();
    });
  }

  Future<void> _runBackend() async {
    final provider = context.read<CByAiProvider>();
    try {
      // Pre-flight: if a completed plan already exists on the server, load it
      // and send the user directly to the tracker — no new generation needed.
      final alreadyHasPlan = await provider.checkForExistingPlan();
      if (!mounted) return;
      if (alreadyHasPlan) {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CByAiTrackerScreen(initialIsCalendar: true),
          ),
        );
        return;
      }

      // No existing plan – generate a new one.
      final userInfo =
          widget.userInfo ?? await provider.fetchUserData();
      final success = await provider.generateMeals(userInfo);
      if (!mounted) return;
      setState(() {
        _backendReady = success;
        _backendError = success ? null : (provider.error ?? 'Failed to start meal generation');
      });
      if (!success && _backendError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_backendError!),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (success && _currentStep >= _totalSteps) {
        // Steps already finished; navigate now
        _navigateToGenerating();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _backendReady = false;
        _backendError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_backendError'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
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
    if (!_backendReady) {
      // Backend not ready: show error if we have one, or wait
      if (_backendError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_backendError!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }
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
                const DigiPillHeader(),
                
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
                        _stepTitles[(_currentStep - 1) % _stepTitles.length],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      Text(
                        _stepSubtitles[(_currentStep - 1) % _stepSubtitles.length],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/profile_top_bar.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 6;

  final List<_StepData> _steps = [
    _StepData(
      title: 'Set Up Your 24DIGI Profile',
      description:
          'Your profile is your fitness identity. Add your photo, basic info, and health stats to personalize your experience.',
      icon: Icons.person_outline,
      color: const Color(0xFF00D186),
      points: [
        'Add a profile photo to make your account recognizable',
        'Fill in your health stats for accurate tracking',
        'Set your gender and date of birth for personalized insights',
      ],
    ),
    _StepData(
      title: 'Configure Your Daily Quests',
      description:
          'Set your daily fitness goals — steps, calories, active minutes, and hydration. These become your daily missions to conquer.',
      icon: Icons.adjust,
      color: const Color(0xFFFFB061),
      points: [
        'Start with achievable goals and increase gradually',
        'Use preset buttons for quick goal selection',
        'Your goals can be changed anytime from your profile',
      ],
    ),
    _StepData(
      title: 'Track Your Activities',
      description:
          '24DIGI automatically tracks your steps, movement, and exercise. You can also manually log workouts and activities.',
      icon: Icons.directions_walk,
      color: const Color(0xFF00F0FF),
      points: [
        'Keep your phone or wearable with you for accurate tracking',
        'Connect your favorite fitness devices via Connected Apps',
        'Check your progress throughout the day on the home dashboard',
      ],
    ),
    _StepData(
      title: 'Set Up Alerts & Reminders',
      description:
          'Configure notifications to stay on track. Get reminded to move, drink water, sleep on time, and review your weekly progress.',
      icon: Icons.notifications_none_outlined,
      color: const Color(0xFFB161FF),
      points: [
        'Enable push notifications for real-time reminders',
        'Set quiet hours so you\'re not disturbed during rest',
        'Weekly summaries help you track long-term progress',
      ],
    ),
    _StepData(
      title: 'Earn XP & Unlock Badges',
      description:
          'Every action earns XP — completing quests, maintaining streaks, and hitting milestones. Level up and collect achievement badges.',
      icon: Icons.emoji_events_outlined,
      color: const Color(0xFFFFB061),
      points: [
        'Complete all 4 daily quests for maximum XP',
        'Maintain your streak for bonus multipliers',
        'Check the achievements section for hidden badges',
      ],
    ),
    _StepData(
      title: 'You\'re Ready!',
      description:
          'You\'ve completed the training! Your fitness journey begins now. Remember — every step counts, every rep matters, every day is a new quest.',
      icon: Icons.auto_awesome_outlined,
      color: const Color(0xFF00D186),
      points: [
        'Explore the dashboard for real-time fitness insights',
        'Join challenges to compete with other warriors',
        'Customize your app experience in App Arsenal settings',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            _buildTitleSection(s),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  ..._steps.map((step) => _buildStepScreen(s, step)),
                  _buildCompletionScreen(s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(double s) {
    bool isCompletion = _currentPage == _totalSteps;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
            ),
            child: Icon(
              Icons.play_arrow,
              color: const Color(0xFF00F0FF),
              size: 16 * s,
            ),
          ),
          SizedBox(width: 12 * s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tutorial',
                style: GoogleFonts.inter(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                isCompletion
                    ? 'Getting started guide'
                    : 'Step ${_currentPage + 1} of $_totalSteps',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepScreen(double s, _StepData data) {
    int _stepIndex = _steps.indexOf(data);
    double progress = (_stepIndex + 1) / _totalSteps;
    int percentage = (progress * 100).toInt();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        children: [
          SizedBox(height: 10 * s),
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: GoogleFonts.outfit(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00F0FF),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.outfit(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Stack(
            children: [
              Container(
                height: 4 * s,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 4 * s,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF),
                  borderRadius: BorderRadius.circular(2 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              bool isCompleted = index <= _stepIndex;
              return Container(
                width: 6 * s,
                height: 6 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF00F0FF)
                      : Colors.white.withOpacity(0.1),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
              );
            }),
          ),
          SizedBox(height: 30 * s),

          // Main Content Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF161B21),
                borderRadius: BorderRadius.circular(24 * s),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(24 * s),
                        decoration: BoxDecoration(
                          color: data.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: Icon(data.icon, color: data.color, size: 36 * s),
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    Text(
                      data.title,
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Text(
                      data.description,
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    ...List.generate(data.points.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16 * s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20 * s,
                              height: 20 * s,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: data.color.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                color: data.color.withOpacity(0.1),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.outfit(
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w700,
                                  color: data.color,
                                ),
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Expanded(
                              child: Text(
                                data.points[index],
                                style: GoogleFonts.inter(
                                  fontSize: 12 * s,
                                  color: Colors.white54,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24 * s),

          // Bottom Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _stepIndex > 0 ? _prevPage : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16 * s),
                      border: Border.all(
                        color: _stepIndex > 0
                            ? Colors.white12
                            : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_stepIndex > 0)
                          Icon(
                            Icons.chevron_left,
                            color: Colors.white54,
                            size: 16 * s,
                          ),
                        if (_stepIndex > 0) SizedBox(width: 4 * s),
                        Text(
                          _stepIndex > 0 ? 'Back' : '',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F0FF),
                      borderRadius: BorderRadius.circular(16 * s),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _stepIndex == _totalSteps - 1 ? 'Complete' : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4 * s),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                          size: 16 * s,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: EdgeInsets.all(24 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF00D186).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF00D186).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00D186).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D186).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: const Color(0xFF00D186),
                size: 40 * s,
              ),
            ),
          ),
          SizedBox(height: 32 * s),
          Text(
            'Training Complete!',
            style: GoogleFonts.inter(
              fontSize: 24 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * s),
          Text(
            'You\'ve mastered the basics. Time to hit the arena.',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24 * s),
          Text(
            '+250 XP EARNED',
            style: GoogleFonts.outfit(
              fontSize: 12 * s,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00D186),
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16 * s),
                      border: Border.all(color: Colors.white12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 16 * s),
                        SizedBox(width: 8 * s),
                        Text(
                          'Replay',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Profile or pop
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D186),
                      borderRadius: BorderRadius.circular(16 * s),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D186).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to Profile',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4 * s),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                          size: 16 * s,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> points;

  _StepData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
  });
}

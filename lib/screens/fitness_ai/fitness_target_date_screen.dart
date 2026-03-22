import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'fitness_chat_screen.dart';

class FitnessTargetDateScreen extends StatefulWidget {
  final String goalName;
  const FitnessTargetDateScreen({super.key, required this.goalName});

  @override
  State<FitnessTargetDateScreen> createState() =>
      _FitnessTargetDateScreenState();
}

class _FitnessTargetDateScreenState extends State<FitnessTargetDateScreen> {
  DateTime _selectedDate = DateTime(2026, 2, 4);
  DateTime _viewDate = DateTime(2026, 2, 1);
  final DateTime _recommendedDate = DateTime(2026, 2, 4);

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name?.toUpperCase() ?? 'USER';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const DigiPillHeader(showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'HI, $name',
                        style: TextStyle(
                          fontFamily: 'LemonMilk',
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 2.0 * s,
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    Text(
                      'When do you want to\nreach this goal?',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30 * s),
                    // Current Goal Card
                    Container(
                      padding: EdgeInsets.all(12 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1519),
                        borderRadius: BorderRadius.circular(16 * s),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.2 * s,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10 * s),
                            child: Image.asset(
                              'assets/fitness_ai/fitness_swimming.png',
                              width: 80 * s,
                              height: 60 * s,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Goal',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12 * s,
                                    color: const Color(0xFF00F0FF),
                                  ),
                                ),
                                Text(
                                  widget.goalName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.all(6 * s),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: const Color(0xFF2FFFCC),
                                size: 18 * s,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35 * s),
                    // Date Display Section
                    Text(
                      'Date',
                      style: GoogleFonts.outfit(
                        fontSize: 13 * s,
                        color: const Color(0xFF2FFFCC),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(_selectedDate),
                      style: GoogleFonts.outfit(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8 * s),
                      height: 1 * s,
                      width: double.infinity,
                      color: const Color(0xFF2FFFCC).withOpacity(0.4),
                    ),
                    SizedBox(height: 30 * s),
                    // Custom Calendar
                    _CalendarWidget(
                      s: s,
                      viewDate: _viewDate,
                      selectedDate: _selectedDate,
                      recommendedDate: _recommendedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      onMonthChanged: (date) =>
                          setState(() => _viewDate = date),
                    ),
                    SizedBox(height: 20 * s),
                    // AI Recommended legend
                    Row(
                      children: [
                        Container(
                          width: 12 * s,
                          height: 12 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F0FF), Color(0xFFCE6AFF)],
                            ),
                          ),
                        ),
                        SizedBox(width: 10 * s),
                        Text(
                          'AI Recommended date',
                          style: GoogleFonts.outfit(
                            fontSize: 14 * s,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35 * s),
                    _ConfirmButton(
                      s: s,
                      label: 'Confirm Target Date',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FitnessChatScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final double s;
  final DateTime viewDate;
  final DateTime selectedDate;
  final DateTime recommendedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _CalendarWidget({
    required this.s,
    required this.viewDate,
    required this.selectedDate,
    required this.recommendedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1519).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Month Selector
          Row(
            children: [
              Text(
                DateFormat('MMM yyyy').format(viewDate),
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.white, size: 20 * s),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    onMonthChanged(DateTime(viewDate.year, viewDate.month - 1)),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white.withOpacity(0.6),
                  size: 24 * s,
                ),
              ),
              SizedBox(width: 10 * s),
              GestureDetector(
                onTap: () =>
                    onMonthChanged(DateTime(viewDate.year, viewDate.month + 1)),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24 * s,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          // Day Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 15 * s),
          _buildDaysGrid(context),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(viewDate.year, viewDate.month, 1);
    final lastDayOfMonth = DateTime(viewDate.year, viewDate.month + 1, 0);

    // Adjust for Monday-start (DateTime.weekday: 1=Mon, 7=Sun)
    int firstWeekday = firstDayOfMonth.weekday; // 1-7
    int leadingEmptyDays = firstWeekday - 1;

    final days = <Widget>[];

    // Leading empty slots
    for (int i = 0; i < leadingEmptyDays; i++) {
      days.add(const Expanded(child: SizedBox.shrink()));
    }

    // Days of month
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final current = DateTime(viewDate.year, viewDate.month, i);
      final isSelected =
          current.year == selectedDate.year &&
          current.month == selectedDate.month &&
          current.day == selectedDate.day;
      final isRecommended =
          current.year == recommendedDate.year &&
          current.month == recommendedDate.month &&
          current.day == recommendedDate.day;

      days.add(
        _CalendarDay(
          s: s,
          day: i,
          isSelected: isSelected,
          isRecommended: isRecommended,
          onTap: () => onDateSelected(current),
        ),
      );
    }

    // Fill the rest of the last row
    int totalCells = leadingEmptyDays + lastDayOfMonth.day;
    int trailingEmptyDays = (7 - (totalCells % 7)) % 7;
    for (int i = 0; i < trailingEmptyDays; i++) {
      days.add(const Expanded(child: SizedBox.shrink()));
    }

    // Wrap in rows
    final List<Widget> bodyRows = [];
    for (int i = 0; i < days.length; i += 7) {
      if (i > 0) bodyRows.add(SizedBox(height: 15 * s));
      bodyRows.add(Row(children: days.sublist(i, i + 7)));
    }

    return Column(children: bodyRows);
  }
}

class _CalendarDay extends StatelessWidget {
  final double s;
  final int day;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.s,
    required this.day,
    required this.isSelected,
    required this.isRecommended,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF2FFFCC) : Colors.transparent,
              border: isRecommended
                  ? Border.all(color: Colors.white.withOpacity(0.5))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: GoogleFonts.outfit(
                fontSize: 14 * s,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.s,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: const LinearGradient(
            colors: [Color(0xFF2FFFCC), Color(0xFF2FFF9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FFFCC).withOpacity(0.3),
              blurRadius: 20 * s,
              offset: Offset(0, 10 * s),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 22 * s,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0D1519),
          ),
        ),
      ),
    );
  }
}

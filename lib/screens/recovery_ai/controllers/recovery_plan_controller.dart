import 'package:get/get.dart';

class RecoveryPlanController extends GetxController {
  String aiPlanTitle = "Recovery Plan";

  List<RecoveryDayModel> recoveryPlan = [
    RecoveryDayModel(
      dayTitle: "Day 1: Initial relief and rest",
      goal: "Reduce initial soreness",
      benefits: [
        "Improved blood flow",
        "Reduced inflammation",
        "Muscle relaxation",
      ],
    ),
    RecoveryDayModel(
      dayTitle: "Day 2: Mobility focus",
      goal: "Increase range of motion",
      benefits: [
        "Joint lubrication",
        "Flexibility increase",
        "Enhanced tissue repair",
      ],
    ),
    RecoveryDayModel(
      dayTitle: "Day 3: Strengthening",
      goal: "Build stability",
      benefits: [
        "Muscle fiber activation",
        "Improved coordination",
      ],
    ),
  ];

  final List<ChipOption> recoveryCategory = [
    ChipOption(title: "Sport Recovery"),
    ChipOption(title: "Temporary"),
    ChipOption(title: "4 Days"),
  ];

  void selectChip(ChipOption chip) {
    for (var item in recoveryCategory) {
      if (item != chip) item.isSelected.value = false;
    }
    chip.isSelected.toggle();
  }

  String description =
      "This plan focuses on gentle recovery strategies, gradual progression, and safe symptom management. Progressively increase activity while monitoring pain levels.";

  /// Try to map AI response into the existing UI model.
  ///
  /// Expected (based on your backend prompt) keys:
  /// - plan_title
  /// - program_overview (or similar)
  /// - daily_plan (temporary plan) OR phases/weeks (permanent plan)
  void setFromAiResponse(Map<String, dynamic> resp) {
    final planJson = resp['plan_json'];
    final planJsonMap = planJson is Map<String, dynamic> ? planJson : null;

    // Your backend (from Postman screenshots) returns:
    // plan_json.daily_programs: [
    //   { day, day_title, daily_goal, exercises:[{name,..}], practices:[{name,..}], additional_ideas:[{suggestion,..}], ... }
    // ]
    final dynamic dailyProgramsDynamic = resp['daily_programs'] ??
        planJsonMap?['daily_programs'] ??
        resp['daily_plan'] ??
        planJsonMap?['daily_plan'];

    final dailyPrograms =
        dailyProgramsDynamic is List ? dailyProgramsDynamic : const [];

    final hasPlanData = dailyPrograms.isNotEmpty;

    // Title / description
    aiPlanTitle = resp['plan_title']?.toString().trim().isNotEmpty == true
        ? resp['plan_title'].toString()
        : (planJsonMap?['plan_title']?.toString().trim().isNotEmpty == true
            ? planJsonMap!['plan_title'].toString()
            : aiPlanTitle);

    description = resp['program_overview']?.toString().trim().isNotEmpty ==
            true
        ? resp['program_overview'].toString()
        : (planJsonMap?['overall_strategy']?.toString().trim().isNotEmpty ==
                true
            ? planJsonMap!['overall_strategy'].toString()
            : (planJsonMap?['overall_strategies']?.toString().trim().isNotEmpty ==
                    true
                ? planJsonMap!['overall_strategies'].toString()
                : description));

    if (!hasPlanData) {
      // Backend did not return a generated plan, so clear the dummy UI.
      recoveryPlan = [];
      description = resp['detail']?.toString() ??
          resp['message']?.toString() ??
          "Backend returned a response but no generated plan (missing daily_programs/daily_plan).";
      return;
    }

    recoveryPlan = dailyPrograms.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;

      if (item is! Map<String, dynamic>) {
        return RecoveryDayModel(
          dayTitle: "Day ${i + 1}",
          goal: "",
          benefits: const [],
        );
      }

      final dayTitle = item['day_title']?.toString().trim().isNotEmpty == true
          ? item['day_title'].toString()
          : (item['title']?.toString().trim().isNotEmpty == true
              ? item['title'].toString()
              : (item['day']?.toString().trim().isNotEmpty == true
                  ? "Day ${item['day']}"
                  : "Day ${i + 1}"));

      final goal = item['daily_goal']?.toString().trim().isNotEmpty == true
          ? item['daily_goal'].toString().trim()
          : (item['goal']?.toString().trim().isNotEmpty == true
              ? item['goal'].toString().trim()
              : (item['day_goal']?.toString().trim().isNotEmpty == true
                  ? item['day_goal'].toString().trim()
                  : ''));

      final benefits = <String>[];

      // Exercises/practices have the right structure from Postman: {name, description, ...}
      final exercises = item['exercises'];
      if (exercises is List) {
        benefits.addAll(exercises
            .map((e) => e is Map<String, dynamic> ? e['name'] : null)
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList());
      }

      final practices = item['practices'];
      if (practices is List) {
        benefits.addAll(practices
            .map((e) => e is Map<String, dynamic> ? e['name'] : null)
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList());
      }

      final additionalIdeas = item['additional_ideas'];
      if (additionalIdeas is List) {
        for (final e in additionalIdeas) {
          if (e is Map<String, dynamic>) {
            final category = e['category']?.toString().trim();
            final suggestion = e['suggestion']?.toString().trim();
            if (suggestion != null && suggestion.isNotEmpty) {
              benefits.add(
                category != null && category.isNotEmpty
                    ? '$category: $suggestion'
                    : suggestion,
              );
            }
          }
        }
      }

      // Single-value focus fields
      final painFocus = item['pain_management_focus']?.toString().trim();
      if (painFocus != null && painFocus.isNotEmpty) {
        benefits.add(painFocus);
      }

      final avoid = item['what_to_avoid_today'];
      if (avoid is List) {
        benefits.addAll(
          avoid
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .take(3),
        );
      }

      // Fallback for older schema.
      if (benefits.isEmpty) {
        for (final source in [
          item['morning_routine'],
          item['afternoon_activities'],
          item['evening_routine'],
        ]) {
          if (source is List) {
            benefits.addAll(source
                .map((e) => e.toString())
                .where((s) => s.trim().isNotEmpty));
          }
        }
      }

      return RecoveryDayModel(
        dayTitle: dayTitle,
        goal: goal,
        benefits: benefits.take(10).toList(),
      );
    }).toList();
  }
}
class RecoveryDayModel {
  final String dayTitle;
  final String goal;
  final List<String> benefits;

  RecoveryDayModel({
    required this.dayTitle,
    required this.goal,
    required this.benefits,
  });
}


class ChipOption {
  final String title;
  RxBool isSelected;

  ChipOption({required this.title, bool initial = false})
      : isSelected = initial.obs;
}

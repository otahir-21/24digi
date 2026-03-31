import 'activity_storage.dart';

/// Maps UI activity picker labels to [sportName] values from the band (type 30 / [BraceletDataParser.activityModeNames]).
const Map<String, Set<String>> activityUiToDeviceSportNames = {
  'Walking': {'Walk', 'Walking'},
  'Running': {'Run', 'Running'},
  'Cycling': {'Cycling'},
  'Hiking': {'Hiking'},
  'Workout': {'Workout'},
  'Football': {'Football'},
  'Table Tennis': {'Ping Pong', 'Tennis', 'Table Tennis'},
  'Basketball': {'Basketball'},
  'Badminton': {'Badminton'},
  'Yoga': {'Yoga'},
  'Cricket': {'Cricket'},
  'Dance': {'Dance'},
};

/// Which metrics are most relevant for the selected activity (device may still omit some).
enum ActivityMetricProfile {
  /// Steps, distance, pace, duration, calories, HR when present.
  cardio,
  /// Duration, calories, HR; steps/distance only if band sent them.
  studio,
  /// Duration, calories, HR; optional steps & distance if > 0.
  courtAndMixed,
}

ActivityMetricProfile metricProfileForUiLabel(String? label) {
  final k = label?.trim() ?? '';
  switch (k) {
    case 'Yoga':
    case 'Dance':
      return ActivityMetricProfile.studio;
    case 'Football':
    case 'Basketball':
    case 'Badminton':
    case 'Cricket':
    case 'Table Tennis':
    case 'Workout':
      return ActivityMetricProfile.courtAndMixed;
    default:
      return ActivityMetricProfile.cardio;
  }
}

bool sessionMatchesUiLabel(Map<String, dynamic> session, String? uiLabel) {
  if (uiLabel == null || uiLabel.isEmpty) return false;
  final sn = (session['sportName'] as String?)?.trim();
  if (sn == null || sn.isEmpty) return false;
  final set = activityUiToDeviceSportNames[uiLabel];
  if (set != null && set.contains(sn)) return true;
  return sn.toLowerCase() == uiLabel.toLowerCase();
}

double? distanceMetersOrKmToKm(dynamic d) {
  if (d == null) return null;
  final v = d is num ? d.toDouble() : double.tryParse(d.toString());
  if (v == null || v <= 0) return null;
  return v > 100 ? v / 1000.0 : v;
}

/// Aggregated stats for today’s sessions matching [uiLabel].
class ActivitySessionAggregate {
  const ActivitySessionAggregate({
    required this.sessionCount,
    this.totalActiveMinutes = 0,
    this.totalSteps = 0,
    this.totalDistanceKm = 0,
    this.totalCalories = 0,
    this.avgHeartRate,
    this.latestPaceDisplay,
    this.latestStartDate,
  });

  final int sessionCount;
  final int totalActiveMinutes;
  final int totalSteps;
  final double totalDistanceKm;
  final double totalCalories;
  final int? avgHeartRate;
  final String? latestPaceDisplay;
  final String? latestStartDate;

  bool get hasAnyData =>
      sessionCount > 0 &&
      (totalActiveMinutes > 0 ||
          totalSteps > 0 ||
          totalDistanceKm > 0 ||
          totalCalories > 0 ||
          avgHeartRate != null);
}

ActivitySessionAggregate _aggregateList(List<Map<String, dynamic>> list) {
  if (list.isEmpty) {
    return const ActivitySessionAggregate(sessionCount: 0);
  }
  int active = 0, steps = 0, hrSum = 0, hrN = 0;
  double dist = 0, cal = 0;
  String? pace;
  String? latestDate;
  for (final s in list) {
    final m = s['activeMinutes'];
    if (m is int) active += m;
    if (m is num) active += m.toInt();
    final st = s['step'];
    if (st is int) steps += st;
    if (st is num) steps += st.toInt();
    final dk = distanceMetersOrKmToKm(s['distance']);
    if (dk != null) dist += dk;
    final c = s['calories'];
    if (c is num) cal += c.toDouble();
    final hr = s['heartRate'];
    if (hr is int && hr > 0) {
      hrSum += hr;
      hrN++;
    } else if (hr is num && hr > 0) {
      hrSum += hr.toInt();
      hrN++;
    }
    final p = s['pace'];
    if (p != null && p.toString().trim().isNotEmpty) {
      pace = p.toString().trim();
    }
    final d = s['date'] as String?;
    if (d != null && d.isNotEmpty) latestDate = d;
  }
  return ActivitySessionAggregate(
    sessionCount: list.length,
    totalActiveMinutes: active,
    totalSteps: steps,
    totalDistanceKm: dist,
    totalCalories: cal,
    avgHeartRate: hrN > 0 ? (hrSum / hrN).round() : null,
    latestPaceDisplay: pace,
    latestStartDate: latestDate,
  );
}

/// When [uiLabel] is null/empty, aggregates **all** of today’s band sessions (e.g. “View history”).
ActivitySessionAggregate aggregateSessionsForUiLabel(String? uiLabel) {
  final all = ActivityStorage.todaySessions;
  if (uiLabel == null || uiLabel.isEmpty) {
    return _aggregateList(all);
  }
  final list = all.where((s) => sessionMatchesUiLabel(s, uiLabel)).toList();
  return _aggregateList(list);
}

/// One row in the inner activity metrics card (label + formatted value for UI).
class ActivityMetricField {
  const ActivityMetricField({
    required this.label,
    required this.value,
    required this.show,
  });

  final String label;
  final String value;
  final bool show;
}

List<ActivityMetricField> buildMetricFields({
  required ActivityMetricProfile profile,
  required ActivitySessionAggregate stored,
  Map<String, dynamic>? live,
  double? cadenceSpm,
}) {
  int? liveSteps;
  double? liveDistKm;
  double? liveCal;
  int? liveHr;
  int? liveActiveMin;
  if (live != null) {
    final st = live['step'] ?? live['Step'];
    if (st is int) liveSteps = st;
    if (st is num) liveSteps = st.toInt();
    liveDistKm = distanceMetersOrKmToKm(live['distance'] ?? live['Distance']);
    final c = live['calories'] ?? live['Calories'];
    if (c is num) liveCal = c.toDouble();
    final hr = live['heartRate'] ?? live['HeartRate'];
    if (hr is int) liveHr = hr;
    if (hr is num) liveHr = hr.toInt();
    final em = live['exerciseMinutes'] ??
        live['ExerciseMinutes'] ??
        live['activeMinutes'] ??
        live['ActiveMinutes'];
    if (em is int) liveActiveMin = em;
    if (em is num) liveActiveMin = em.toInt();
  }

  final useSteps = (liveSteps != null && liveSteps > 0)
      ? liveSteps
      : (stored.totalSteps > 0 ? stored.totalSteps : null);
  final useDist = (liveDistKm != null && liveDistKm > 0)
      ? liveDistKm
      : (stored.totalDistanceKm > 0 ? stored.totalDistanceKm : null);
  final useCal = (liveCal != null && liveCal > 0)
      ? liveCal
      : (stored.totalCalories > 0 ? stored.totalCalories : null);
  final useHr = (liveHr != null && liveHr > 0)
      ? liveHr
      : stored.avgHeartRate;
  final useMin = (liveActiveMin != null && liveActiveMin > 0)
      ? liveActiveMin
      : (stored.totalActiveMinutes > 0 ? stored.totalActiveMinutes : null);

  String fmtKm(double? v) {
    if (v == null || v <= 0) return '—';
    return v >= 10 ? '${v.toStringAsFixed(1)} km' : '${v.toStringAsFixed(2)} km';
  }

  String fmtInt(int? v) => v != null && v > 0 ? '$v' : '—';
  String fmtCal(double? v) {
    if (v == null || v <= 0) return '—';
    return '${v.round()}';
  }

  final paceStr = cadenceSpm != null && cadenceSpm > 0
      ? '${cadenceSpm.round()} spm'
      : (stored.latestPaceDisplay != null && stored.latestPaceDisplay!.isNotEmpty
          ? stored.latestPaceDisplay!
          : '—');

  final out = <ActivityMetricField>[];

  void add(String label, String value, bool show) {
    out.add(ActivityMetricField(label: label, value: value, show: show));
  }

  switch (profile) {
    case ActivityMetricProfile.cardio:
      add('Duration', useMin != null ? '$useMin min' : '—', true);
      add('Distance', fmtKm(useDist), true);
      add('Cadence / pace', paceStr, true);
      add('Steps', fmtInt(useSteps), true);
      add('Calories', fmtCal(useCal), true);
      add('Heart rate', useHr != null ? '$useHr bpm' : '—', true);
      break;
    case ActivityMetricProfile.studio:
      add('Duration', useMin != null ? '$useMin min' : '—', true);
      add('Calories', fmtCal(useCal), true);
      add('Heart rate', useHr != null ? '$useHr bpm' : '—', true);
      add('Steps', fmtInt(useSteps), useSteps != null && useSteps > 0);
      add('Distance', fmtKm(useDist), useDist != null && useDist > 0);
      add('Sessions today', '${stored.sessionCount}', stored.sessionCount > 0);
      break;
    case ActivityMetricProfile.courtAndMixed:
      add('Duration', useMin != null ? '$useMin min' : '—', true);
      add('Calories', fmtCal(useCal), true);
      add('Heart rate', useHr != null ? '$useHr bpm' : '—', true);
      add('Steps', fmtInt(useSteps), useSteps != null && useSteps > 0);
      add('Distance', fmtKm(useDist), useDist != null && useDist > 0);
      add('Sessions today', '${stored.sessionCount}', stored.sessionCount > 0);
      break;
  }

  return out.where((f) => f.show).toList();
}

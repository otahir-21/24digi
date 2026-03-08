/// Parsed sleep record from device type-27 (DetailSleepData).
/// For a merged nightly session: startTime/endTime = in-bed start/end; totalSleepMinutes = sum of stage minutes; inBedDurationMinutes = end - start.
class SleepSummary {
  const SleepSummary({
    this.startTime,
    this.endTime,
    this.totalSleepMinutes,
    this.inBedDurationMinutes,
    this.sleepUnitLengthMinutes,
    this.deepMinutes,
    this.lightMinutes,
    this.remMinutes,
    this.awakeMinutes,
    this.rawStages,
    this.sourceDate,
    this.isReliable = true,
    this.hasNonWearSignals = false,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final int? totalSleepMinutes;
  /// Time in bed (first record start to last record end) for merged session.
  final int? inBedDurationMinutes;
  final int? sleepUnitLengthMinutes;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? remMinutes;
  final int? awakeMinutes;
  /// Raw stage codes from device (SDK: 1=deep, 2=light, 3=REM, else=awake for unit 1). Null for merged session.
  final List<int>? rawStages;
  /// Date of the sleep record for display/selection.
  final DateTime? sourceDate;
  final bool isReliable;
  final bool hasNonWearSignals;

  /// Map for SleepStorage.lastSleepData and widgets (totalSleepMinutes, deepMinutes, etc.).
  Map<String, dynamic> toMap() {
    final inBed = inBedDurationMinutes ?? (startTime != null && endTime != null ? endTime!.difference(startTime!).inMinutes : null);
    return <String, dynamic>{
      'totalSleepMinutes': totalSleepMinutes,
      'inBedDurationMinutes': inBed,
      'deepMinutes': deepMinutes,
      'lightMinutes': lightMinutes,
      'remMinutes': remMinutes,
      'awakeMinutes': awakeMinutes,
      'startTime': startTime,
      'endTime': endTime,
      'sourceDate': sourceDate,
      'isReliable': isReliable,
      'hasNonWearSignals': hasNonWearSignals,
      if (rawStages != null) 'rawStages': List<int>.from(rawStages!),
    };
  }
}

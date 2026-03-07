/// Domain model for the bracelet dashboard "live" view.
/// All values are from device (realtime + total activity) or derived (e.g. BP from HR, stress from HR).
class LiveHealthMetrics {
  const LiveHealthMetrics({
    this.step,
    this.distance,
    this.calories,
    this.heartRate,
    this.temperature,
    this.hrv,
    this.stress,
    this.spo2,
    this.systolic,
    this.diastolic,
    this.lastUpdated,
  });

  final int? step;
  final double? distance;
  final double? calories;
  final int? heartRate;
  final double? temperature;
  final int? hrv;
  final int? stress;
  final int? spo2;
  final int? systolic;
  final int? diastolic;
  final DateTime? lastUpdated;

  /// Returns a map with normalized keys used by ProgressCard and _HealthGrid.
  /// Preserves existing widget contracts so UI stays unchanged.
  Map<String, dynamic> toDisplayMap() {
    final map = <String, dynamic>{};
    if (step != null) map['step'] = step;
    if (distance != null) map['distance'] = distance;
    if (calories != null) map['calories'] = calories;
    if (heartRate != null) map['heartRate'] = heartRate;
    if (temperature != null) map['temperature'] = temperature;
    if (hrv != null) map['hrv'] = hrv;
    if (stress != null) map['stress'] = stress;
    if (spo2 != null) map['spo2'] = spo2;
    if (systolic != null) map['systolic'] = systolic;
    if (diastolic != null) map['diastolic'] = diastolic;
    return map;
  }
}

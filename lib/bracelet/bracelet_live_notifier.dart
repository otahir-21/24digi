import 'package:flutter/foundation.dart';

/// Singleton ChangeNotifier that BraceletScreen writes to on every type-24/25
/// packet. Any screen (e.g. ProgressScreen) can listen to it to get real-time
/// updates without holding its own channel subscription.
class BraceletLiveNotifier extends ChangeNotifier {
  BraceletLiveNotifier._();
  static final BraceletLiveNotifier instance = BraceletLiveNotifier._();

  Map<String, dynamic>? _liveData;
  List<double> _stepsHistory = [];
  List<double> _distanceHistory = [];
  List<double> _caloriesHistory = [];

  Map<String, dynamic>? get liveData =>
      _liveData != null ? Map<String, dynamic>.from(_liveData!) : null;

  List<double> get stepsHistory => List<double>.unmodifiable(_stepsHistory);
  List<double> get distanceHistory => List<double>.unmodifiable(_distanceHistory);
  List<double> get caloriesHistory => List<double>.unmodifiable(_caloriesHistory);

  /// Called by BraceletScreen on every type 24/25 packet after merging data.
  void update({
    required Map<String, dynamic>? liveData,
    required List<double> stepsHistory,
    required List<double> distanceHistory,
    required List<double> caloriesHistory,
  }) {
    _liveData = liveData != null ? Map<String, dynamic>.from(liveData) : null;
    _stepsHistory = List<double>.from(stepsHistory);
    _distanceHistory = List<double>.from(distanceHistory);
    _caloriesHistory = List<double>.from(caloriesHistory);
    notifyListeners();
  }

  /// Clear on disconnect / logout.
  void clear() {
    _liveData = null;
    _stepsHistory = [];
    _distanceHistory = [];
    _caloriesHistory = [];
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

/// Set to `true` only when tracing BLE / stream issues (very noisy).
const bool kBraceletVerboseLogs = false;

void braceletVerboseLog(String message) {
  if (kBraceletVerboseLogs && kDebugMode) {
    debugPrint(message);
  }
}

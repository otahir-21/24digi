#!/usr/bin/env bash
# When pubspec sets enable-lldb-debugging: false, Flutter drives Xcode via automation.
# - Quit Xcode first if you see CONFIGURATION_BUILD_DIR timeout.
# - Prefer a USB cable: automation's device list often omits wireless iPhones ("Unable to find target device").
set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "Quitting Xcode (if open) so Flutter device debug can sync build settings..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2
exec flutter run "$@"

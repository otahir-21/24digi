import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 2; // Home is default (middle tab)
  bool _isNavBarVisible = true;

  int get selectedIndex => _selectedIndex;
  bool get isNavBarVisible => _isNavBarVisible;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setNavBarVisible(bool visible) {
    if (_isNavBarVisible != visible) {
      _isNavBarVisible = visible;
      notifyListeners();
    }
  }

  // To reset a tab to its root when re-selected
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void resetTab(int index) {
    navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }
}

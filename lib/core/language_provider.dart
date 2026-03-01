import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLanguage(String langCode) {
    _locale = Locale(langCode.toLowerCase());
    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
}

import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  SunGenderMode _genderMode = SunGenderMode.woman;

  ThemeMode get themeMode => _themeMode;
  SunGenderMode get genderMode => _genderMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggleThemeLightDark() {
    setThemeMode(
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setGenderMode(SunGenderMode mode) {
    if (_genderMode == mode) return;
    _genderMode = mode;
    notifyListeners();
  }

  void toggleGender() {
    setGenderMode(_genderMode == SunGenderMode.woman
        ? SunGenderMode.man
        : SunGenderMode.woman);
  }
}

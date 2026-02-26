import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

class AppSettings extends ChangeNotifier {
  static const _kThemeMode = 'settings.themeMode';
  static const _kGenderMode = 'settings.genderMode';
  static const _kLocale = 'settings.locale';

  ThemeMode _themeMode = ThemeMode.system;
  SunGenderMode _genderMode = SunGenderMode.woman;
  Locale _locale = const Locale('cs');

  ThemeMode get themeMode => _themeMode;
  SunGenderMode get genderMode => _genderMode;
  Locale get locale => _locale;

  /// 🔥 Načte uložené nastavení při startu aplikace
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = prefs.getString(_kThemeMode);
    final genderStr = prefs.getString(_kGenderMode);
    final localeStr = prefs.getString(_kLocale);

    _themeMode = _themeModeFromString(themeStr) ?? ThemeMode.system;
    _genderMode = _genderFromString(genderStr) ?? SunGenderMode.woman;
    _locale = Locale(
      (localeStr != null && localeStr.isNotEmpty) ? localeStr : 'cs',
    );
  }

  // -----------------------
  // THEME
  // -----------------------

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode.name);
  }

  Future<void> toggleThemeLightDark() async {
    final next =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  // -----------------------
  // GENDER
  // -----------------------

  Future<void> setGenderMode(SunGenderMode mode) async {
    if (_genderMode == mode) return;

    _genderMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGenderMode, mode.name);
  }

  Future<void> toggleGender() async {
    await setGenderMode(
      _genderMode == SunGenderMode.woman
          ? SunGenderMode.man
          : SunGenderMode.woman,
    );
  }

  // -----------------------
  // LOCALE (Language)
  // -----------------------

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
  }

  // -----------------------
  // Helpers
  // -----------------------

  ThemeMode? _themeModeFromString(String? s) {
    switch (s) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  SunGenderMode? _genderFromString(String? s) {
    switch (s) {
      case 'woman':
        return SunGenderMode.woman;
      case 'man':
        return SunGenderMode.man;
      default:
        return null;
    }
  }
}

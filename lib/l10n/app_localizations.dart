import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// JSON-based localizations
/// Assets:
///   assets/i18n/cs.json
///   assets/i18n/en.json
class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;
  final Map<String, String> _fallback;

  AppLocalizations._(this.locale, this._strings, this._fallback);

  static const supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  static const fallbackLocale = Locale('en');

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(loc != null, 'AppLocalizations not found in context');
    return loc!;
  }

  /// Translate key with optional {param} substitutions.
  /// Example JSON: "hello": "Hello {name}"
  String tr(String key, {Map<String, String>? params}) {
    final raw = _strings[key] ?? _fallback[key] ?? key;

    if (params == null || params.isEmpty) return raw;

    var out = raw;
    params.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }

  static Future<Map<String, String>> _load(Locale l) async {
    final path = 'assets/i18n/${l.languageCode}.json';
    final s = await rootBundle.loadString(path);
    final Map<String, dynamic> m = json.decode(s) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<AppLocalizations> load(Locale locale) async {
    // Always load fallback first (guaranteed base coverage)
    final fallback = await _load(fallbackLocale);

    Map<String, String> strings;
    try {
      strings = await _load(locale);
    } catch (_) {
      // Missing/invalid locale file -> fallback
      strings = fallback;
    }

    return AppLocalizations._(locale, strings, fallback);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// Sugar: context.tr('key')
extension TrContextX on BuildContext {
  String tr(String key, {Map<String, String>? params}) =>
      AppLocalizations.of(this).tr(key, params: params);
}

/// Back-compat helper if your UI uses: t(context, 'key')
String t(BuildContext context, String key, {Map<String, String>? params}) {
  return AppLocalizations.of(context).tr(key, params: params);
}

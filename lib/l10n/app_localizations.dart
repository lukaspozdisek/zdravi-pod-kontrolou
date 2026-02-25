// lib/l10n/app_localizations.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'app_strings.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'AppLocalizations not found in context');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocDelegate();

  static List<Locale> supportedLocales = kSupportedLocales.map((e) => Locale(e)).toList();

  String tr(String key, {Map<String, String> args = const {}}) {
    final lang = locale.languageCode;
    final table = kStrings[lang] ?? kStrings['en']!;
    var text = table[key] ?? kStrings['en']![key] ?? key;

    // simple template replace: {x}
    args.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }
}

class _AppLocDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocDelegate();

  @override
  bool isSupported(Locale locale) => kSupportedLocales.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocDelegate old) => false;
}

/// helper: t(context, 'key', args: {...})
String t(BuildContext context, String key, {Map<String, String> args = const {}}) {
  return AppLocalizations.of(context).tr(key, args: args);
}
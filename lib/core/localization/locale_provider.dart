import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'locale_code';

  Locale _locale = AppLocalizations.supportedLocales.first;

  Locale get locale => _locale;

  LocaleProvider._(this._locale);

  static Future<LocaleProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code != null) {
      final locale = AppLocalizations.supportedLocales.firstWhere(
        (item) => item.languageCode == code,
        orElse: () => AppLocalizations.supportedLocales.first,
      );
      return LocaleProvider._(locale);
    }
    return LocaleProvider._(AppLocalizations.supportedLocales.first);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';

  SettingsProvider({
    required SharedPreferences prefs,
    this.initialLocale = const Locale('az'),
  })  : _prefs = prefs,
        _themeMode = prefs.getBool(_keyDarkMode) == true ? ThemeMode.dark : ThemeMode.system {
    _locale = Locale(prefs.getString(_keyLanguage) ?? initialLocale.languageCode);
  }

  final SharedPreferences _prefs;
  final Locale initialLocale;

  ThemeMode _themeMode;
  Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setBool(_keyDarkMode, mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_keyLanguage, locale.languageCode);
    notifyListeners();
  }
}

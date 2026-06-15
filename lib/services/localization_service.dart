import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._();
  factory LocalizationService() => _instance;
  LocalizationService._();

  static const _prefKey = 'app_language';
  static const supportedLocales = ['de', 'en', 'sq', 'ar'];
  static const defaultLocale = 'de';

  String _currentLocale = defaultLocale;
  Map<String, dynamic> _strings = {};

  String get currentLocale => _currentLocale;
  bool get isRtl => _currentLocale == 'ar';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString(_prefKey) ?? defaultLocale;
    await _loadStrings(_currentLocale);
  }

  Future<void> setLocale(String locale) async {
    if (!supportedLocales.contains(locale)) return;
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale);
    await _loadStrings(locale);
  }

  Future<void> _loadStrings(String locale) async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/l10n/$locale.json');
      _strings = json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      _strings = {};
    }
  }

  String t(String key, [Map<String, String>? args]) {
    String value = _strings[key]?.toString() ?? key;
    args?.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}

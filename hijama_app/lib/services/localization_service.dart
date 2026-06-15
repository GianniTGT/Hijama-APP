import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages with their metadata.
class AppLanguage {
  final String code;
  final String label;
  final String nativeLabel;
  final bool isRTL;

  const AppLanguage({
    required this.code,
    required this.label,
    required this.nativeLabel,
    this.isRTL = false,
  });
}

class LocalizationService {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'de', label: 'Deutsch', nativeLabel: 'DE'),
    AppLanguage(code: 'en', label: 'English', nativeLabel: 'EN'),
    AppLanguage(code: 'sq', label: 'Shqip', nativeLabel: 'ALB'),
    AppLanguage(code: 'ar', label: 'العربية', nativeLabel: 'عر', isRTL: true),
  ];

  static const String _prefKey = 'app_language';
  static const String _defaultLang = 'de';

  Map<String, dynamic> _strings = {};
  String _currentLang = _defaultLang;

  String get currentLanguage => _currentLang;
  bool get isRTL => _currentLang == 'ar';

  AppLanguage get currentLanguageInfo =>
      supportedLanguages.firstWhere((l) => l.code == _currentLang);

  /// Load saved language preference, then load translations.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString(_prefKey) ?? _defaultLang;
    await _loadStrings(_currentLang);
  }

  /// Switch language and persist the choice.
  Future<void> setLanguage(String langCode) async {
    if (_currentLang == langCode) return;
    _currentLang = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, langCode);
    await _loadStrings(langCode);
  }

  Future<void> _loadStrings(String langCode) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/l10n/$langCode.json');
      _strings = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Fallback to German if file not found
      if (langCode != _defaultLang) {
        final fallback =
            await rootBundle.loadString('assets/l10n/$_defaultLang.json');
        _strings = json.decode(fallback) as Map<String, dynamic>;
      }
    }
  }

  /// Get a translated string by key.
  /// Supports {placeholder} substitution.
  String t(String key, {Map<String, String>? args}) {
    final value = _strings[key];
    if (value == null) return key;
    String result = value is String ? value : value.toString();
    if (args != null) {
      args.forEach((k, v) => result = result.replaceAll('{$k}', v));
    }
    return result;
  }

  /// Get a translated list (e.g. guide steps).
  List<Map<String, dynamic>> tList(String key) {
    final value = _strings[key];
    if (value == null || value is! List) return [];
    return List<Map<String, dynamic>>.from(
        value.map((e) => Map<String, dynamic>.from(e as Map)));
  }

  /// Get the hadith list (with Arabic, translation, source, topic).
  List<HadithEntry> getHadiths() {
    return tList('hadiths').map((m) => HadithEntry.fromJson(m)).toList();
  }

  /// Get the cupping points list.
  List<CuppingPoint> getCuppingPoints() {
    return tList('points').map((m) => CuppingPoint.fromJson(m)).toList();
  }
}

/// Single Hadith data model.
class HadithEntry {
  final String id;
  final String arabic;
  final String translation;
  final String source;
  final String topic;

  const HadithEntry({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.source,
    required this.topic,
  });

  factory HadithEntry.fromJson(Map<String, dynamic> j) => HadithEntry(
        id: j['id'] as String,
        arabic: j['arabic'] as String,
        translation: j['translation'] as String,
        source: j['source'] as String,
        topic: j['topic'] as String,
      );
}

/// Cupping point data model.
class CuppingPoint {
  final String id;
  final String name;
  final String arabic;
  final String description;
  final bool isSunnah;

  const CuppingPoint({
    required this.id,
    required this.name,
    required this.arabic,
    required this.description,
    required this.isSunnah,
  });

  factory CuppingPoint.fromJson(Map<String, dynamic> j) => CuppingPoint(
        id: j['id'] as String,
        name: j['name'] as String,
        arabic: j['arabic'] as String,
        description: j['description'] as String,
        isSunnah: (j['is_sunnah'] as bool?) ?? false,
      );
}

/// Shorthand global accessor — set this in main.dart after init.
late LocalizationService localization;

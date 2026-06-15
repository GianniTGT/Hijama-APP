import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_service.dart';

class AppState extends ChangeNotifier {
  final LocalizationService _loc;
  bool _isFirstLaunch = false;

  AppState(this._loc) {
    _checkFirstLaunch();
  }

  String get currentLanguage => _loc.currentLanguage;
  bool get isRTL => _loc.isRTL;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = !(prefs.getBool('onboarding_done') ?? false);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    _isFirstLaunch = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    await _loc.setLanguage(code);
    notifyListeners();
  }
}

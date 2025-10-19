import 'package:flutter/material.dart';

/// 테마 ViewModel
/// 다크/라이트 모드 전환 관리
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// 테마 모드 설정
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// 다크 모드 토글
  void toggleDarkMode() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// 시스템 테마 사용
  void useSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

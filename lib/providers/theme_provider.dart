import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  // Load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode') ?? 'system';
    
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // Save theme preference
  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', theme);
  }

  // Set theme to light mode
  void setLightMode() {
    _themeMode = ThemeMode.light;
    _saveTheme('light');
    notifyListeners();
  }

  // Set theme to dark mode
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    _saveTheme('dark');
    notifyListeners();
  }

  // Set theme to system mode
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    _saveTheme('system');
    notifyListeners();
  }

  // Toggle between light and dark
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }
}
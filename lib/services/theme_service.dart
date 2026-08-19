import 'package:flutter/material.dart';

/// Owns the app's light/dark mode. Dark is the default, matching BLOOM's
/// primary, production-facing look.
class ThemeService extends ChangeNotifier {
  ThemeMode _mode;

  ThemeService({ThemeMode initial = ThemeMode.dark}) : _mode = initial;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

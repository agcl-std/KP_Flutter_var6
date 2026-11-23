import 'package:flutter/material.dart';

import '../storage/local_store.dart';

/// Налаштування інтерфейсу; тема переживає перезапуск застосунку.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._store)
      : _themeMode = ThemeMode.values.asNameMap()[_store.getString(_key)] ?? ThemeMode.light;

  static const _key = 'theme_mode';
  final LocalStore _store;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _store.setString(_key, mode.name);
  }
}

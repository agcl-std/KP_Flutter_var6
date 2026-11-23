import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Тонка обгортка над SharedPreferences: рядки та JSON-списки.
/// Сховище key–value: підходить для налаштувань і невеликих списків (не для великих даних).
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async => LocalStore(await SharedPreferences.getInstance());

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  /// Повертає null, якщо ключа немає або дані пошкоджені (тоді викликач бере початкові дані).
  List<Map<String, dynamic>>? readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));
}

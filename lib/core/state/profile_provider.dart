import 'package:flutter/foundation.dart';

import '../auth/auth_repository.dart';
import '../storage/local_store.dart';

/// Дані профілю: ім’я та фото — у Firebase Auth, група — локально (SharedPreferences).
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repo, this._store);

  final AuthRepository _repo;
  final LocalStore _store;
  bool _busy = false;

  bool get busy => _busy;
  String get email => _repo.currentUser?.email ?? '';
  String? get photoUrl => _repo.currentUser?.photoURL;
  String get name => _repo.currentUser?.displayName ?? '';
  String get group => _store.getString(_groupKey) ?? '';

  String get _groupKey => 'profile_group_${_repo.currentUser?.uid}';

  /// Перезавантажує профіль із Firebase (ім’я/фото, змінені на іншому пристрої).
  Future<void> refresh() async {
    await _repo.currentUser?.reload();
    notifyListeners();
  }

  Future<void> saveGroup(String group) async {
    await _store.setString(_groupKey, group.trim());
    notifyListeners();
  }

  /// Зберігає ім’я та групу; помилку Firebase кидає викликачу для показу користувачу.
  Future<void> save({required String name, required String group}) => _guard(() async {
        await _repo.updateDisplayName(name.trim());
        await saveGroup(group);
      });

  Future<void> setPhoto(String url) => _guard(() => _repo.updatePhotoUrl(url));

  Future<void> changePassword({required String current, required String next}) =>
      _guard(() => _repo.changePassword(current: current, next: next));

  Future<void> _guard(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

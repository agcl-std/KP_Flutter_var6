import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_repository.dart';

/// Стан автентифікації: поточний користувач, індикатор завантаження та текст помилки.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo) {
    // Емітить і при відновленні сеансу після перезапуску (токен зберігає Firebase SDK).
    _sub = _repo.authState.listen((u) {
      _user = u;
      _ready = true;
      notifyListeners();
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<User?> _sub;
  User? _user;
  bool _ready = false;
  bool _busy = false;
  String? _error;

  User? get user => _user;
  bool get ready => _ready;
  bool get busy => _busy;
  String? get error => _error;

  Future<bool> signIn(String email, String password) =>
      _run(() => _repo.signIn(email: email, password: password));

  Future<bool> signUp(String name, String email, String password) =>
      _run(() => _repo.signUp(name: name, email: email, password: password));

  Future<void> signOut() => _repo.signOut();

  /// Виконує дію з індикатором і перетворенням помилки на повідомлення.
  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _error = AuthRepository.message(e);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

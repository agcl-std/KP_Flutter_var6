import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../analytics/analytics.dart';

/// Уся взаємодія з Firebase Auth. Екрани викликають лише ці методи.
class AuthRepository {
  AuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Емітить користувача при вході/виході та відновленні сеансу.
  Stream<User?> get authState => _auth.authStateChanges();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
    _track('sign_up');
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _track('login');
    } on FirebaseAuthException catch (e) {
      // Windows SDK віддає unknown-error замість INVALID_LOGIN_CREDENTIALS від сервера.
      if (e.code == 'unknown-error') throw FirebaseAuthException(code: 'invalid-credential');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    _track('password_reset_requested');
  }

  Future<void> signOut() async {
    _track('logout');
    await _auth.signOut();
  }

  void _track(String event) => Analytics.track(event, userId: _auth.currentUser?.uid);

  /// Повторна автентифікація + зміна пароля. Firebase може вимагати свіжого входу
  /// (requires-recent-login), тому поточний пароль перевіряємо через reauthenticate.
  Future<void> changePassword({required String current, required String next}) async {
    final user = _auth.currentUser!;
    try {
      await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: current));
    } on FirebaseAuthException catch (e) {
      // Windows SDK віддає unknown-error замість невірних даних (див. signIn).
      if (e.code == 'unknown-error') throw FirebaseAuthException(code: 'wrong-password');
      rethrow;
    }
    await user.updatePassword(next);
    _track('password_changed');
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser!.updateDisplayName(name);
    await _auth.currentUser!.reload();
  }

  Future<void> updatePhotoUrl(String url) async {
    await _auth.currentUser!.updatePhotoURL(url);
    await _auth.currentUser!.reload();
  }

  /// Перетворює помилку Firebase на зрозуміле повідомлення для користувача.
  static String message(Object e) {
    debugPrint('Auth error: $e');
    if (e is! FirebaseAuthException) return 'Сталася невідома помилка. Спробуйте ще раз.';
    return switch (e.code) {
      // Вхід
      'invalid-email' => 'Некоректна адреса електронної пошти.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-login-credentials' =>
        'Невірна електронна пошта або пароль.',
      'user-disabled' => 'Обліковий запис заблоковано адміністратором.',
      'user-token-expired' ||
      'invalid-user-token' ||
      'requires-recent-login' =>
        'Сеанс застарів. Вийдіть і увійдіть знову.',
      'too-many-requests' => 'Забагато спроб. Зачекайте кілька хвилин і спробуйте знову.',
      // Реєстрація й пароль
      'email-already-in-use' || 'credential-already-in-use' =>
        'Користувач з такою поштою вже існує. Спробуйте увійти.',
      'weak-password' => 'Пароль надто слабкий (мінімум 6 символів).',
      'operation-not-allowed' => 'Вхід за e-mail і паролем вимкнено в налаштуваннях проєкту.',
      'missing-email' => 'Вкажіть електронну пошту.',
      'missing-password' => 'Вкажіть пароль.',
      // Мережа та сервіс
      'network-request-failed' => 'Немає з’єднання з мережею. Перевірте інтернет.',
      'timeout' => 'Сервер не відповів вчасно. Спробуйте ще раз.',
      'app-not-authorized' ||
      'invalid-api-key' ||
      'api-key-not-valid' =>
        'Застосунок не авторизований у Firebase. Перевірте налаштування проєкту.',
      'quota-exceeded' => 'Перевищено ліміт запитів до сервісу. Спробуйте пізніше.',
      'internal-error' || 'unknown-error' =>
        'Внутрішня помилка сервісу автентифікації. Спробуйте ще раз пізніше.',
      _ => 'Помилка автентифікації (${e.code}).',
    };
  }
}

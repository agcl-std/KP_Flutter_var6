/// Валідатори для TextFormField: повертають текст помилки або null.
class Validators {
  static String? required(String? v, [String field = 'Поле']) =>
      (v == null || v.trim().isEmpty) ? '$field є обов’язковим' : null;

  static String? email(String? v) {
    final r = required(v, 'Електронна пошта');
    if (r != null) return r;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())
        ? null
        : 'Невірний формат e-mail';
  }

  static String? password(String? v) {
    final r = required(v, 'Пароль');
    if (r != null) return r;
    if (v!.length < 8) return 'Мінімум 8 символів';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Пароль має містити літери та цифри';
    }
    return null;
  }

  static String? Function(String?) confirm(String Function() original) =>
      (v) => v != original() ? 'Паролі не збігаються' : null;
}

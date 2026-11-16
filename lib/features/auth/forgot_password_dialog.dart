import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/snack.dart';

/// Модальне вікно відновлення пароля (FR-03): лист надсилає Firebase Auth.
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const ForgotPasswordDialog());

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = context;
    try {
      await AuthRepository().sendPasswordReset(_email.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(messenger, 'Інструкцію надіслано на вказану пошту');
    } catch (e) {
      if (mounted) showSnack(context, AuthRepository.message(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Відновлення пароля'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Введіть e-mail, і ми надішлемо інструкцію для скидання пароля.'),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Електронна пошта (e-mail)',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        FilledButton(
          onPressed: _loading ? null : _send,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Надіслати лінк відновлення'),
        ),
      ],
    );
  }
}

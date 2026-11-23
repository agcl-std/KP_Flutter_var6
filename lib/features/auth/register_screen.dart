import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_provider.dart';
import '../../core/state/profile_provider.dart';
import '../../core/auth/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';

/// Екран реєстрації (FR-01): валідація через Form і реєстрація у Firebase Auth.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _group = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = true;

  @override
  void dispose() {
    for (final c in [_name, _group, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      showSnack(context, 'Потрібно погодитися з умовами використання', error: true);
      return;
    }
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final ok = await auth.signUp(_name.text.trim(), _email.text.trim(), _password.text);
    if (!mounted) return;
    if (!ok) return showSnack(context, auth.error!, error: true);
    await profile.saveGroup(_group.text); // група зберігається локально
    if (!mounted) return;
    // Закриваємо екран реєстрації; головний екран показує Consumer<AuthProvider> у main.dart.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthScaffold(
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Створення облікового запису студента',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            AppTextField(
              label: 'ПІБ',
              hint: 'Петренко Петро Петрович',
              controller: _name,
              validator: (v) => Validators.required(v, 'ПІБ'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Академічна група',
              hint: 'ПЗ-31',
              controller: _group,
              validator: (v) => Validators.required(v, 'Група'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Електронна пошта (e-mail)',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Пароль',
              controller: _password,
              isPassword: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Підтвердження пароля',
              controller: _confirm,
              isPassword: true,
              validator: Validators.confirm(() => _password.text),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              title: const Text('Погоджуюсь з умовами використання локального сховища'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Зареєструватися', loading: context.watch<AuthProvider>().busy, onPressed: _register),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Вже зареєстровані? '),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Увійти'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

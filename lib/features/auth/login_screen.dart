import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_provider.dart';
import '../../core/auth/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import 'forgot_password_dialog.dart';
import 'register_screen.dart';

/// Екран авторизації (FR-02, FR-03). Вхід виконує AuthProvider.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_email.text.trim(), _password.text);
    // Перехід на головний екран виконує Consumer<AuthProvider> у main.dart.
    if (!ok && mounted) showSnack(context, auth.error!, error: true);
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
          Text('Авторизація', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Введіть ваші облікові дані для входу до персонального каталогу',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Електронна пошта (e-mail)',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Пароль',
            controller: _password,
            isPassword: true,
            validator: (v) => Validators.required(v, 'Пароль'),
            labelTrailing: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => ForgotPasswordDialog.show(context),
              child: const Text('Забули пароль?'),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            value: _remember,
            onChanged: (v) => setState(() => _remember = v ?? false),
            title: const Text("Запам'ятати мене на цьому комп'ютері"),
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Увійти в систему', loading: context.watch<AuthProvider>().busy, onPressed: _signIn),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Немає облікового запису? '),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Зареєструватися'),
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

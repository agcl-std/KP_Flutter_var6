import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/auth/auth_repository.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/home/app_shell.dart';
import 'firebase_options.dart';

// DSN Sentry передається через --dart-define=SENTRY_DSN=...; без нього Sentry вимкнено.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SentryFlutter.init(
    (o) => o.dsn = _sentryDsn,
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Каталог навчальних матеріалів',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        // Відновлення сеансу: Firebase зберігає користувача між запусками.
        home: StreamBuilder<User?>(
          stream: AuthRepository().authState,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return snap.data == null ? const LoginScreen() : const AppShell();
          },
        ),
      ),
    );
  }
}

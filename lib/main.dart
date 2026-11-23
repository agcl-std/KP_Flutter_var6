import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/auth/auth_repository.dart';
import 'core/state/auth_provider.dart';
import 'core/state/catalog_provider.dart';
import 'core/state/profile_provider.dart';
import 'core/state/settings_provider.dart';
import 'core/storage/local_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/app_shell.dart';
import 'firebase_options.dart';

// DSN Sentry передається через --dart-define=SENTRY_DSN=...; без нього Sentry вимкнено.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final store = await LocalStore.open();
  await SentryFlutter.init(
    (o) => o.dsn = _sentryDsn,
    appRunner: () => runApp(MyApp(store: store)),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.store});

  final LocalStore store;

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(store)),
        ChangeNotifierProvider(create: (_) => AuthProvider(repo)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(repo, store)),
        ChangeNotifierProvider(create: (_) => CatalogProvider(store)..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Каталог навчальних матеріалів',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          // Відновлення сеансу: Firebase зберігає користувача між запусками.
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (!auth.ready) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return auth.user == null ? const LoginScreen() : const AppShell();
            },
          ),
        ),
      ),
    );
  }
}

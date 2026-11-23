import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_provider.dart';
import '../../core/state/profile_provider.dart';
import '../disciplines/disciplines_screen.dart';
import '../materials/materials_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Основне робоче вікно з адаптивною навігацією:
/// ширина ≥ 900 — розгорнута бічна панель, 600–900 — компактний NavigationRail,
/// < 600 — нижня NavigationBar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Головна'),
    (Icons.folder_outlined, Icons.folder, 'Дисципліни'),
    (Icons.description_outlined, Icons.description, 'Матеріали'),
    (Icons.person_outline, Icons.person, 'Профіль'),
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Завантаження актуальних даних профілю при вході в застосунок.
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProfileProvider>().refresh());
  }

  Widget _page() {
    switch (_index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const DisciplinesScreen();
      case 2:
        return const MaterialsScreen();
      default:
        return ProfileScreen(onSignOut: () => context.read<AuthProvider>().signOut());
    }
  }

  /// Ініціали з імені користувача (до двох літер).
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    return parts.isEmpty ? '?' : parts.map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < 600) {
          return Scaffold(
            body: SafeArea(child: _page()),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
              ],
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: width >= 900,
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CircleAvatar(child: Text(_initials(context.watch<ProfileProvider>().name))),
                ),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                        icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _page()),
            ],
          ),
        );
      },
    );
  }
}

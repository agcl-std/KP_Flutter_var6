import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';

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

  Widget _page() {
    switch (_index) {
      case 0:
        return const HomeScreen();
      case 3:
        return ProfileScreen(
          onSignOut: () => AuthRepository().signOut(),
        );
      default:
        return Center(child: Text('${_destinations[_index].$3} — буде реалізовано пізніше'));
    }
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
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircleAvatar(child: Text('РГ')),
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

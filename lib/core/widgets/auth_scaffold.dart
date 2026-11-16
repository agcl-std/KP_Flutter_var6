import 'package:flutter/material.dart';

/// Каркас екранів авторизації: на широкому вікні — синя брендова панель ліворуч
/// і форма праворуч, на вузькому — лише форма.
class AuthScaffold extends StatelessWidget {
  final Widget form;

  const AuthScaffold({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final formPanel = Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: form),
            ),
          );
          if (!wide) return formPanel;
          return Row(
            children: [
              const Expanded(child: _BrandPanel()),
              Expanded(child: formPanel),
            ],
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    const perks = [
      (Icons.bolt, 'Миттєвий доступ: конспекти, лекції та файли завжди під рукою'),
      (Icons.cloud_sync_outlined, 'Хмарна синхронізація: робота в офлайні з автооновленням'),
      (Icons.search, 'Розумний пошук: фільтрація за темами, курсами та мітками'),
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0067C0), Color(0xFF003E7E)],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/study_catalog_logo.png', width: 56, height: 56),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Study Materials Catalog',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Єдиний академічний простір для збереження конспектів, посилань і файлів за дисциплінами',
              style: TextStyle(color: Colors.white70, fontSize: 15)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Переваги персонального простору:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                for (final p in perks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(p.$1, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(p.$2, style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

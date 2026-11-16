import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/widgets/discipline_card.dart';
import '../../core/widgets/material_tile.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/stat_card.dart';

/// Головний екран / дашборд (FR-05, FR-10). Дані hardcoded у MockData.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 4 : (width >= 500 ? 2 : 1);
        final disciplineColumns = width >= 900 ? 3 : (width >= 600 ? 2 : 1);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: SearchBar(
                    hintText: 'Пошук матеріалів, конспектів, тем...',
                    leading: Icon(Icons.search),
                    elevation: WidgetStatePropertyAll(0),
                  ),
                ),
                if (width >= 700) ...[
                  const SizedBox(width: 16),
                  PrimaryButton(
                      label: 'Новий матеріал', icon: Icons.add, expand: false, onPressed: () {}),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text('Вітаємо, ${MockData.userFirstName}! 👋',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Осінній семестр 2026/2027 • НУ «Львівська політехніка»',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            _grid(columns, [
              for (final s in MockData.stats) StatCard(value: s.value, label: s.label),
            ]),
            const SizedBox(height: 28),
            Text('Закріплені навчальні дисципліни',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _grid(disciplineColumns, [
              for (final d in MockData.pinnedDisciplines)
                DisciplineCard(
                  title: d.title,
                  teacher: d.teacher,
                  info: d.info,
                  topics: d.topics,
                  color: d.color,
                ),
            ]),
            const SizedBox(height: 28),
            Text('Нещодавно додані матеріали',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final m in MockData.recent)
              MaterialTile(
                title: m.title,
                type: m.type,
                discipline: m.discipline,
                date: m.date,
                onOpen: () {},
              ),
          ],
        );
      },
    );
  }

  /// Рівномірна сітка з [columns] колонок без сторонніх пакетів.
  Widget _grid(int columns, List<Widget> children) {
    const gap = 16.0;
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final child in children) SizedBox(width: w, child: child)],
        );
      },
    );
  }
}

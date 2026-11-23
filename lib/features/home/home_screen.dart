import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/study_material.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/state/profile_provider.dart';
import '../../core/widgets/discipline_card.dart';
import '../../core/widgets/material_tile.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/stat_card.dart';
import '../materials/material_detail_screen.dart';
import '../materials/material_form_screen.dart';

/// Головний екран / дашборд (FR-05, FR-10). Дані беруться з CatalogProvider і ProfileProvider.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = context.watch<CatalogProvider>();
    final name = context.watch<ProfileProvider>().name;
    final firstName = name.trim().isEmpty ? '' : ', ${name.trim().split(RegExp(r'\s+')).first}';
    final stats = [
      ('Навчальних дисциплін', catalog.disciplines.length),
      ('Конспектів та нотаток', catalog.materials.where((m) => m.kind == MaterialKind.note).length),
      ('Файлів PDF', catalog.materials.where((m) => m.kind == MaterialKind.pdf).length),
      ('Веб-посилань', catalog.materials.where((m) => m.kind == MaterialKind.link).length),
    ];
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
                      label: 'Новий матеріал',
                      icon: Icons.add,
                      expand: false,
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MaterialFormScreen()))),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text('Вітаємо$firstName! 👋',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Осінній семестр 2026/2027 • НУ «Львівська політехніка»',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            _grid(columns, [
              for (final s in stats) StatCard(value: '${s.$2}', label: s.$1),
            ]),
            const SizedBox(height: 28),
            Text('Закріплені навчальні дисципліни',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _grid(disciplineColumns, [
              for (final d in catalog.disciplines.take(3))
                DisciplineCard(
                  title: d.title,
                  teacher: d.teacher,
                  info: 'Семестр ${d.semester}',
                  topics: catalog.materialsOf(d.id).length,
                  color: Color(d.color),
                  semester: d.semester,
                ),
            ]),
            const SizedBox(height: 28),
            Text('Нещодавно додані матеріали',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final m in catalog.recent)
              MaterialTile(
                title: m.title,
                type: m.kind.label,
                discipline: catalog.disciplineById(m.disciplineId)?.title ?? '—',
                date: formatDate(m.createdAt),
                onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: m.id))),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/study_material.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/material_tile.dart';
import '../materials/material_detail_screen.dart';
import '../materials/material_form_screen.dart';
import 'discipline_form_screen.dart';

/// Перегляд дисципліни: CustomScrollView зі SliverAppBar, SliverToBoxAdapter та SliverList.
class DisciplineDetailScreen extends StatelessWidget {
  final String disciplineId;

  const DisciplineDetailScreen({super.key, required this.disciplineId});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final d = catalog.disciplineById(disciplineId);
    if (d == null) return const Scaffold(body: Center(child: Text('Дисципліну видалено')));
    final items = catalog.materialsOf(d.id);
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MaterialFormScreen(disciplineId: d.id))),
        icon: const Icon(Icons.add),
        label: const Text('Додати матеріал'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Color(d.color),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(title: Text(d.title)),
            actions: [
              IconButton(
                tooltip: 'Редагувати',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DisciplineFormScreen(initial: d))),
              ),
              IconButton(
                tooltip: 'Видалити',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (!await confirmDelete(context, d.title) || !context.mounted) return;
                  final nav = Navigator.of(context);
                  await context.read<CatalogProvider>().deleteDiscipline(d.id);
                  nav.pop();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.teacher, style: theme.textTheme.titleMedium),
                  Text('${d.semester} семестр • матеріалів: ${items.length}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Матеріалів ще немає'))))
          else
            SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                return MaterialTile(
                  title: m.title,
                  type: m.kind.label,
                  discipline: d.title,
                  date: formatDate(m.createdAt),
                  onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: m.id))),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}

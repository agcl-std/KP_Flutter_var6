import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/study_material.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/widgets/material_tile.dart';
import 'material_detail_screen.dart';
import 'material_form_screen.dart';

const _sortLabels = {
  SortMode.newest: 'Спочатку нові',
  SortMode.oldest: 'Спочатку старі',
  SortMode.title: 'За назвою',
};

/// Вкладка «Матеріали»: пошук, фільтри за типом і дисципліною, сортування, ListView.separated.
class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.visibleMaterials;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MaterialFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Новий матеріал'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  hintText: 'Пошук за назвою...',
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  onChanged: context.read<CatalogProvider>().setQuery,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      label: const Text('Усі типи'),
                      selected: catalog.kindFilter == null,
                      onSelected: (_) => catalog.setKindFilter(null),
                    ),
                    for (final k in MaterialKind.values)
                      FilterChip(
                        label: Text(k.label),
                        selected: catalog.kindFilter == k,
                        onSelected: (_) => catalog.setKindFilter(k),
                      ),
                    DropdownButton<String?>(
                      value: catalog.disciplineFilter,
                      hint: const Text('Дисципліна'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Усі дисципліни')),
                        for (final d in catalog.disciplines)
                          DropdownMenuItem(value: d.id, child: Text(d.title)),
                      ],
                      onChanged: catalog.setDisciplineFilter,
                    ),
                    DropdownButton<SortMode>(
                      value: catalog.sort,
                      items: [
                        for (final e in _sortLabels.entries)
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                      onChanged: (v) => catalog.setSort(v ?? catalog.sort),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: catalog.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(child: Text('Нічого не знайдено'))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final m = items[i];
                          return MaterialTile(
                            title: m.title,
                            type: m.kind.label,
                            discipline: catalog.disciplineById(m.disciplineId)?.title ?? '—',
                            date: formatDate(m.createdAt),
                            onOpen: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => MaterialDetailScreen(materialId: m.id))),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

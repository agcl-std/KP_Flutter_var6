import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/catalog_provider.dart';
import '../../core/widgets/discipline_card.dart';
import 'discipline_detail_screen.dart';
import 'discipline_form_screen.dart';

/// Вкладка «Дисципліни»: адаптивна сітка карток (GridView.builder).
class DisciplinesScreen extends StatelessWidget {
  const DisciplinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const DisciplineFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Нова дисципліна'),
      ),
      body: catalog.loading
          ? const Center(child: CircularProgressIndicator())
          : catalog.disciplines.isEmpty
              ? const Center(child: Text('Дисциплін ще немає. Додайте першу.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  // Кількість колонок залежить від ширини вікна.
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 170,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: catalog.disciplines.length,
                  itemBuilder: (context, i) {
                    final d = catalog.disciplines[i];
                    final items = catalog.materialsOf(d.id);
                    return DisciplineCard(
                      title: d.title,
                      teacher: d.teacher,
                      info: items.isEmpty ? 'Матеріалів ще немає' : items.first.title,
                      topics: items.length,
                      color: Color(d.color),
                      semester: d.semester,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => DisciplineDetailScreen(disciplineId: d.id))),
                    );
                  },
                ),
    );
  }
}

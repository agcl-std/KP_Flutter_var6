import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/discipline.dart';
import '../models/study_material.dart';
import '../storage/local_store.dart';

enum SortMode { newest, oldest, title }

/// Стан каталогу: дисципліни та матеріали (CRUD), пошук, фільтри, сортування.
/// Дані зберігаються у SharedPreferences; при першому запуску беруться початкові (seed).
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._store);

  // v2: матеріали отримали вкладення, тож старі дані перезавантажуються із seed.
  static const _dKey = 'disciplines_v2';
  static const _mKey = 'materials_v2';
  final LocalStore _store;

  bool loading = true;
  List<Discipline> disciplines = [];
  List<StudyMaterial> materials = [];

  String query = '';
  MaterialKind? kindFilter;
  String? disciplineFilter;
  SortMode sort = SortMode.newest;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final d = _store.readList(_dKey);
      final m = _store.readList(_mKey);
      disciplines = d == null ? MockData.seedDisciplines() : d.map(Discipline.fromJson).toList();
      materials = m == null ? MockData.seedMaterials() : m.map(StudyMaterial.fromJson).toList();
    } catch (_) {
      // Пошкоджені дані — повертаємося до початкових.
      disciplines = MockData.seedDisciplines();
      materials = MockData.seedMaterials();
    }
    loading = false;
    notifyListeners();
  }

  // ---------- Вибірки ----------

  Discipline? disciplineById(String id) {
    for (final d in disciplines) {
      if (d.id == id) return d;
    }
    return null;
  }

  StudyMaterial? materialById(String id) {
    for (final m in materials) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<StudyMaterial> materialsOf(String disciplineId) =>
      materials.where((m) => m.disciplineId == disciplineId).toList();

  List<StudyMaterial> get recent => (List.of(materials)..sort(_byNewest)).take(3).toList();

  /// Матеріали після пошуку, фільтрації за типом/дисципліною та сортування.
  List<StudyMaterial> get visibleMaterials {
    final q = query.trim().toLowerCase();
    final list = materials.where((m) {
      if (kindFilter != null && m.kind != kindFilter) return false;
      if (disciplineFilter != null && m.disciplineId != disciplineFilter) return false;
      return q.isEmpty || m.title.toLowerCase().contains(q);
    }).toList();
    switch (sort) {
      case SortMode.newest:
        list.sort(_byNewest);
      case SortMode.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortMode.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  }

  static int _byNewest(StudyMaterial a, StudyMaterial b) => b.createdAt.compareTo(a.createdAt);

  // ---------- Фільтри ----------

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setKindFilter(MaterialKind? v) {
    kindFilter = v;
    notifyListeners();
  }

  void setDisciplineFilter(String? v) {
    disciplineFilter = v;
    notifyListeners();
  }

  void setSort(SortMode v) {
    sort = v;
    notifyListeners();
  }

  // ---------- CRUD: дисципліни ----------

  Future<void> saveDiscipline(Discipline d) async {
    final i = disciplines.indexWhere((x) => x.id == d.id);
    i < 0 ? disciplines.add(d) : disciplines[i] = d;
    await _persist();
  }

  /// Видаляє дисципліну разом з її матеріалами.
  Future<void> deleteDiscipline(String id) async {
    disciplines.removeWhere((d) => d.id == id);
    materials.removeWhere((m) => m.disciplineId == id);
    if (disciplineFilter == id) disciplineFilter = null;
    await _persist();
  }

  // ---------- CRUD: матеріали ----------

  Future<void> saveMaterial(StudyMaterial m) async {
    final i = materials.indexWhere((x) => x.id == m.id);
    i < 0 ? materials.add(m) : materials[i] = m;
    await _persist();
  }

  Future<void> deleteMaterial(String id) async {
    materials.removeWhere((m) => m.id == id);
    await _persist();
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _persist() async {
    notifyListeners(); // UI оновлюється одразу, запис на диск — після
    await _store.writeList(_dKey, disciplines.map((d) => d.toJson()).toList());
    await _store.writeList(_mKey, materials.map((m) => m.toJson()).toList());
  }
}

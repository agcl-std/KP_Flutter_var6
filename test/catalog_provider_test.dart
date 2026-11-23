import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_materials_catalog/core/models/attachment.dart';
import 'package:study_materials_catalog/core/models/study_material.dart';
import 'package:study_materials_catalog/core/state/catalog_provider.dart';
import 'package:study_materials_catalog/core/storage/local_store.dart';

Future<CatalogProvider> _open() async {
  final p = CatalogProvider(await LocalStore.open());
  await p.load();
  return p;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('перший запуск завантажує початкові дані', () async {
    final p = await _open();
    expect(p.loading, isFalse);
    expect(p.disciplines, isNotEmpty);
    expect(p.materials, isNotEmpty);
  });

  test('створення, редагування і видалення матеріалу зберігаються між запусками', () async {
    var p = await _open();
    final m = StudyMaterial(
        id: 'x1',
        title: 'Новий',
        kind: MaterialKind.note,
        disciplineId: p.disciplines.first.id,
        content: 'текст',
        createdAt: DateTime(2026));
    await p.saveMaterial(m);
    expect((await _open()).materialById('x1')?.title, 'Новий');

    await p.saveMaterial(StudyMaterial(
        id: 'x1',
        title: 'Змінений',
        kind: m.kind,
        disciplineId: m.disciplineId,
        content: m.content,
        createdAt: m.createdAt));
    p = await _open();
    expect(p.materialById('x1')?.title, 'Змінений');

    await p.deleteMaterial('x1');
    expect((await _open()).materialById('x1'), isNull);
  });

  test('видалення дисципліни видаляє її матеріали', () async {
    final p = await _open();
    final id = p.disciplines.first.id;
    await p.deleteDiscipline(id);
    expect(p.materialsOf(id), isEmpty);
    expect(p.disciplineById(id), isNull);
  });

  test('вкладення зберігаються, а старі дані без вкладень читаються', () {
    final m = StudyMaterial.fromJson(StudyMaterial(
            id: 'a',
            title: 't',
            kind: MaterialKind.pdf,
            disciplineId: 'd1',
            content: '',
            createdAt: DateTime(2026),
            attachments: const [Attachment(name: 'x.pdf', path: '/p/x.pdf', size: 5)])
        .toJson());
    expect(m.attachments.single.name, 'x.pdf');
    expect(m.attachments.single.ext, 'pdf');

    final old = Map<String, dynamic>.from(m.toJson())..remove('attachments');
    expect(StudyMaterial.fromJson(old).attachments, isEmpty);
  });

  test('пошук, фільтр і сортування', () async {
    final p = await _open();
    p.setQuery('sql');
    expect(p.visibleMaterials.map((m) => m.id), ['m5']);
    p.setQuery('');
    p.setKindFilter(MaterialKind.link);
    expect(p.visibleMaterials.every((m) => m.kind == MaterialKind.link), isTrue);
    p.setKindFilter(null);
    p.setSort(SortMode.title);
    final titles = p.visibleMaterials.map((m) => m.title.toLowerCase()).toList();
    expect(titles, [...titles]..sort());
  });
}

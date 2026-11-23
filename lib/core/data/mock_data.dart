import '../models/attachment.dart';
import '../models/discipline.dart';
import '../models/study_material.dart';

/// Початкові (hardcoded) дані каталогу для першого запуску. Далі дані живуть у CatalogProvider.
class MockData {
  static List<Discipline> seedDisciplines() => [
        const Discipline(
            id: 'd1',
            title: 'Кросплатформне програмування',
            teacher: 'ст. викл. Угриновський Б. В.',
            semester: 5,
            color: 0xFF0067C0),
        const Discipline(
            id: 'd2',
            title: 'Бази даних та знань',
            teacher: 'проф. Шаховська Н. Б.',
            semester: 5,
            color: 0xFF2E7D32),
        const Discipline(
            id: 'd3',
            title: 'Архітектура ПЗ (ЯТПЗ)',
            teacher: 'доц. Федасюк Д. В.',
            semester: 5,
            color: 0xFF6A1B9A),
      ];

  static List<StudyMaterial> seedMaterials() => [
        StudyMaterial(
            id: 'm1',
            title: 'Методичні вказівки до Лабораторної роботи №5',
            kind: MaterialKind.pdf,
            disciplineId: 'd1',
            content: '',
            attachments: const [
              Attachment(
                  name: 'lab5_methodical.pdf',
                  path: 'assets/files/lab5_methodical.pdf',
                  isAsset: true,
                  size: 1126),
            ],
            createdAt: DateTime(2026, 11, 20, 20, 45)),
        StudyMaterial(
            id: 'm2',
            title: 'Конспект: Provider та BLoC',
            kind: MaterialKind.note,
            disciplineId: 'd1',
            content: 'ChangeNotifier сповіщає слухачів про зміну стану; Consumer перебудовує лише свою частину дерева.',
            createdAt: DateTime(2026, 11, 19, 18, 20)),
        StudyMaterial(
            id: 'm3',
            title: 'Документація Flutter: State management',
            kind: MaterialKind.link,
            disciplineId: 'd1',
            content: 'https://docs.flutter.dev/data-and-backend/state-mgmt',
            createdAt: DateTime(2026, 10, 21, 12, 0)),
        StudyMaterial(
            id: 'm4',
            title: 'Нормальні форми: 1НФ–3НФ',
            kind: MaterialKind.note,
            disciplineId: 'd2',
            content: '1НФ — атомарні значення; 2НФ — немає часткових залежностей; 3НФ — немає транзитивних.',
            createdAt: DateTime(2026, 11, 10, 9, 30)),
        StudyMaterial(
            id: 'm5',
            title: 'SQL-шпаргалка (JOIN, GROUP BY)',
            kind: MaterialKind.pdf,
            disciplineId: 'd2',
            content: '',
            attachments: const [
              Attachment(
                  name: 'sql_cheatsheet.pdf',
                  path: 'assets/files/sql_cheatsheet.pdf',
                  isAsset: true,
                  size: 1056),
            ],
            createdAt: DateTime(2026, 11, 5, 14, 10)),
        StudyMaterial(
            id: 'm6',
            title: 'UML: діаграми класів і послідовностей',
            kind: MaterialKind.link,
            disciplineId: 'd3',
            content: 'https://www.uml-diagrams.org',
            createdAt: DateTime(2026, 11, 1, 16, 0)),
      ];
}

import 'attachment.dart';

enum MaterialKind {
  note('Конспект'),
  pdf('PDF'),
  link('Веб-лінк');

  const MaterialKind(this.label);
  final String label;
}

/// Навчальний матеріал: конспект, PDF-файл або посилання. [content] — текст нотатки чи URL.
class StudyMaterial {
  final String id;
  final String title;
  final MaterialKind kind;
  final String disciplineId;
  final String content;
  final DateTime createdAt;
  final List<Attachment> attachments;

  const StudyMaterial({
    required this.id,
    required this.title,
    required this.kind,
    required this.disciplineId,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind.name,
        'disciplineId': disciplineId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachments': [for (final a in attachments) a.toJson()],
      };

  factory StudyMaterial.fromJson(Map<String, dynamic> j) => StudyMaterial(
        id: j['id'] as String,
        title: j['title'] as String,
        kind: MaterialKind.values.byName(j['kind'] as String),
        disciplineId: j['disciplineId'] as String,
        content: j['content'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        // Старі збережені дані не мали вкладень.
        attachments: [
          for (final a in (j['attachments'] as List? ?? const []))
            Attachment.fromJson(Map<String, dynamic>.from(a as Map)),
        ],
      );
}

/// dd.MM.yyyy HH:mm без залежності від intl.
String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Навчальна дисципліна. Колір зберігається як ARGB-число для JSON.
class Discipline {
  final String id;
  final String title;
  final String teacher;
  final int semester;
  final int color;

  const Discipline({
    required this.id,
    required this.title,
    required this.teacher,
    required this.semester,
    required this.color,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'teacher': teacher, 'semester': semester, 'color': color};

  factory Discipline.fromJson(Map<String, dynamic> j) => Discipline(
        id: j['id'] as String,
        title: j['title'] as String,
        teacher: j['teacher'] as String,
        semester: j['semester'] as int,
        color: j['color'] as int,
      );
}

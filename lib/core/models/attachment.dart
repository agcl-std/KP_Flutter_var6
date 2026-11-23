/// Файл-вкладення матеріалу: або asset із застосунку, або копія у папці документів.
class Attachment {
  final String name;
  final String path;
  final bool isAsset;
  final int size;

  const Attachment({required this.name, required this.path, this.isAsset = false, this.size = 0});

  String get ext => name.contains('.') ? name.split('.').last.toLowerCase() : '';

  Map<String, dynamic> toJson() => {'name': name, 'path': path, 'isAsset': isAsset, 'size': size};

  factory Attachment.fromJson(Map<String, dynamic> j) => Attachment(
        name: j['name'] as String,
        path: j['path'] as String,
        isAsset: j['isAsset'] as bool? ?? false,
        size: j['size'] as int? ?? 0,
      );
}

/// Розмір файлу для списку: «1,1 КБ».
String formatSize(int bytes) {
  if (bytes < 1024) return '$bytes Б';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1).replaceAll('.', ',')} КБ';
  return '${(kb / 1024).toStringAsFixed(1).replaceAll('.', ',')} МБ';
}

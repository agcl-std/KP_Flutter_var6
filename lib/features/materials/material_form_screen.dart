import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/auth/validators.dart';
import '../../core/models/attachment.dart';
import '../../core/models/study_material.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'attachment_view.dart';

/// Створення (initial == null) або редагування матеріалу.
/// [disciplineId] — попередньо вибрана дисципліна при створенні з екрана дисципліни.
class MaterialFormScreen extends StatefulWidget {
  final StudyMaterial? initial;
  final String? disciplineId;

  const MaterialFormScreen({super.key, this.initial, this.disciplineId});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _content = TextEditingController(text: widget.initial?.content);
  late MaterialKind _kind = widget.initial?.kind ?? MaterialKind.note;
  late String? _disciplineId = widget.initial?.disciplineId ?? widget.disciplineId;
  late final List<Attachment> _files = [...?widget.initial?.attachments];
  bool _filesMissing = false;

  /// Копіюємо вибраний файл у папку застосунку, щоб він не зник після переміщення оригіналу.
  Future<void> _addFiles() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'webp', 'txt', 'md'],
    );
    if (picked.isEmpty) return;
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/attachments');
    await dir.create(recursive: true);
    final added = <Attachment>[];
    for (final f in picked) {
      if (f.path == null) continue;
      final dest = '${dir.path}/${DateTime.now().microsecondsSinceEpoch}_${f.name}';
      final copy = await File(f.path!).copy(dest);
      added.add(Attachment(name: f.name, path: dest, size: await copy.length()));
    }
    if (!mounted) return;
    setState(() {
      _files.addAll(added);
      _filesMissing = false;
    });
  }

  Widget _filesEditor() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in _files)
            Card(
              child: ListTile(
                leading: Icon(attachmentIcon(a)),
                title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(formatSize(a.size)),
                trailing: IconButton(
                  tooltip: 'Прибрати',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _files.remove(a)),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addFiles,
            icon: const Icon(Icons.attach_file),
            label: const Text('Додати файл'),
          ),
          if (_filesMissing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Додайте хоча б один файл',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
        ],
      );

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  String? _validateContent(String? v) {
    final r = Validators.required(v, _kind == MaterialKind.note ? 'Текст' : 'Посилання');
    if (r != null) return r;
    if (_kind == MaterialKind.link && Uri.tryParse(v!.trim())?.scheme != 'https') {
      return 'Посилання має починатися з https://';
    }
    return null;
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    final isFiles = _kind == MaterialKind.pdf;
    setState(() => _filesMissing = isFiles && _files.isEmpty);
    if (!valid || _filesMissing) return;
    final m = StudyMaterial(
      id: widget.initial?.id ?? CatalogProvider.newId(),
      title: _title.text.trim(),
      kind: _kind,
      disciplineId: _disciplineId!,
      content: isFiles ? '' : _content.text.trim(),
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      attachments: isFiles ? _files : const [],
    );
    await context.read<CatalogProvider>().saveMaterial(m);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final disciplines = context.watch<CatalogProvider>().disciplines;
    final editing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Редагування матеріалу' : 'Новий матеріал')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppTextField(
                    label: 'Назва',
                    controller: _title,
                    validator: (v) => Validators.required(v, 'Назва')),
                const SizedBox(height: 16),
                const Text('Дисципліна',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _disciplineId,
                  hint: const Text('Оберіть дисципліну'),
                  items: [
                    for (final d in disciplines) DropdownMenuItem(value: d.id, child: Text(d.title)),
                  ],
                  validator: (v) => v == null ? 'Оберіть дисципліну' : null,
                  onChanged: (v) => setState(() => _disciplineId = v),
                ),
                const SizedBox(height: 16),
                const Text('Тип', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                SegmentedButton<MaterialKind>(
                  segments: [
                    for (final k in MaterialKind.values)
                      ButtonSegment(value: k, label: Text(k.label)),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
                const SizedBox(height: 16),
                if (_kind == MaterialKind.pdf)
                  _filesEditor()
                else
                  // Ключ змушує поле перебудуватися при зміні типу (інші підпис і валідатор).
                  AppTextField(
                    key: ValueKey(_kind),
                    label: _kind == MaterialKind.note ? 'Текст конспекту' : 'Посилання (https://)',
                    controller: _content,
                    validator: _validateContent,
                  ),
                const SizedBox(height: 28),
                PrimaryButton(label: editing ? 'Зберегти зміни' : 'Створити', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

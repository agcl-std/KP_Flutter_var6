import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/attachment.dart';
import '../../core/models/study_material.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'attachment_view.dart';
import 'material_form_screen.dart';

/// Перегляд одного матеріалу з діями «Редагувати» та «Видалити».
/// Для файлів: у широкому вікні — список ліворуч і перегляд праворуч, у вузькому — окремий екран.
class MaterialDetailScreen extends StatefulWidget {
  final String materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  static const _wide = 900.0;
  String? _selectedPath;

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    final ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Не вдалося відкрити посилання')));
    }
  }

  Widget _header(StudyMaterial m, String disciplineTitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(m.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(m.kind.label)),
            Chip(label: Text(disciplineTitle)),
            Chip(label: Text(formatDate(m.createdAt))),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _noteOrLink(StudyMaterial m) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: m.kind == MaterialKind.note
            ? SelectableText(m.content, style: theme.textTheme.bodyLarge)
            : Row(
                children: [
                  const Icon(Icons.link, size: 40),
                  const SizedBox(width: 16),
                  Expanded(child: SelectableText(m.content, style: theme.textTheme.bodyLarge)),
                  IconButton(
                    tooltip: 'Копіювати',
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: m.content));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Скопійовано')));
                    },
                  ),
                  FilledButton.icon(
                    onPressed: () => _openLink(m.content),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Відкрити'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _files(StudyMaterial m, {required bool split, Attachment? selected}) {
    if (m.attachments.isEmpty) return const Text('Файлів немає. Додайте їх у режимі редагування.');
    return Column(
      children: [
        for (final a in m.attachments)
          Card(
            child: ListTile(
              leading: Icon(attachmentIcon(a)),
              title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(formatSize(a.size)),
              selected: split && a.path == selected?.path,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (split) {
                  setState(() => _selectedPath = a.path);
                } else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AttachmentViewerScreen(attachment: a)));
                }
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final m = catalog.materialById(widget.materialId);
    if (m == null) return const Scaffold(body: Center(child: Text('Матеріал видалено')));
    final disciplineTitle = catalog.disciplineById(m.disciplineId)?.title ?? '—';
    final hasFiles = m.kind == MaterialKind.pdf;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Матеріал'),
        actions: [
          IconButton(
            tooltip: 'Редагувати',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MaterialFormScreen(initial: m))),
          ),
          IconButton(
            tooltip: 'Видалити',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (!await confirmDelete(context, m.title) || !context.mounted) return;
              final nav = Navigator.of(context);
              await context.read<CatalogProvider>().deleteMaterial(m.id);
              nav.pop();
            },
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, c) {
        final split = hasFiles && c.maxWidth >= _wide;
        Attachment? selected;
        if (split && m.attachments.isNotEmpty) {
          selected = m.attachments.firstWhere((a) => a.path == _selectedPath,
              orElse: () => m.attachments.first);
        }
        if (split) {
          return Row(
            children: [
              SizedBox(
                width: 380,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _header(m, disciplineTitle),
                    _files(m, split: true, selected: selected),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selected == null
                    ? const Center(child: Text('Оберіть файл'))
                    : AttachmentView(key: ValueKey(selected.path), attachment: selected),
              ),
            ],
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _header(m, disciplineTitle),
                hasFiles ? _files(m, split: false) : _noteOrLink(m),
              ],
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';

/// Елемент списку навчальних матеріалів (назва, тип, дисципліна, дата, кнопка).
class MaterialTile extends StatelessWidget {
  final String title;
  final String type;
  final String discipline;
  final String date;
  final VoidCallback? onOpen;

  const MaterialTile({
    super.key,
    required this.title,
    required this.type,
    required this.discipline,
    required this.date,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        type.startsWith('PDF')
            ? Icons.picture_as_pdf_outlined
            : type.startsWith('Веб')
                ? Icons.link
                : Icons.description_outlined,
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$type • $discipline • $date',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
      trailing: OutlinedButton(onPressed: onOpen, child: const Text('Відкрити')),
    );
  }
}

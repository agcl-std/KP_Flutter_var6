import 'package:flutter/material.dart';

/// Картка дисципліни з кольоровим акцентом зверху.
class DisciplineCard extends StatelessWidget {
  final String title;
  final String teacher;
  final String info;
  final int topics;
  final Color color;
  final int semester;
  final VoidCallback? onTap;

  const DisciplineCard({
    super.key,
    required this.title,
    required this.teacher,
    required this.info,
    required this.topics,
    required this.color,
    this.semester = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: 4))),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text('$semester семестр'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                Text('$topics матеріалів', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(teacher, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(info, style: theme.textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
      ),
    );
  }
}

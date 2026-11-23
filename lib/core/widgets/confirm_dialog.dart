import 'package:flutter/material.dart';

/// Діалог підтвердження небезпечної дії (видалення). Повертає true, якщо користувач погодився.
Future<bool> confirmDelete(BuildContext context, String what) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Видалити?'),
      content: Text('«$what» буде видалено без можливості відновлення.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Скасувати')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Видалити')),
      ],
    ),
  );
  return ok ?? false;
}

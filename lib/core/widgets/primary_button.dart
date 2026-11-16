import 'package:flutter/material.dart';

/// Кнопка основної дії (Accent). За замовчуванням розтягується на всю ширину батька.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
    final onTap = loading ? null : onPressed; // блокування повторного надсилання
    final button = icon == null
        ? FilledButton(
            onPressed: onTap,
            style: style,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(label))
        : FilledButton.icon(
            onPressed: onTap, style: style, icon: Icon(icon, size: 18), label: Text(label));
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

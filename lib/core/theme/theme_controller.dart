import 'package:flutter/material.dart';

/// Поточний режим теми (системна / світла / темна). Простий глобальний notifier без бібліотек.
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

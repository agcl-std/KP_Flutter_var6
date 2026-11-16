import 'package:flutter/material.dart';

/// Hardcoded-дані (без бізнес-логіки та бекенду).
class MockData {
  static const String userName = 'Голець Роман Ігорович';
  static const String userFirstName = 'Роман';
  static const String userGroup = 'ПЗ-31';
  static const String userEmail = 'roman.holets.pz31@lpnu.ua';

  static const List<({String label, String value})> stats = [
    (label: 'Навчальних дисциплін', value: '6'),
    (label: 'Тематичні модулі', value: '42'),
    (label: 'Конспектів та нотаток', value: '28'),
    (label: 'Вкладених файлів (142 МБ)', value: '26'),
  ];

  static const List<({String title, String teacher, String info, int topics, Color color})>
      pinnedDisciplines = [
    (
      title: 'Кросплатформне програмування',
      teacher: 'ст. викл. Угриновський Б. В.',
      info: '8 матеріалів (Лаб 1, Лаб 2)',
      topics: 4,
      color: Color(0xFF0067C0),
    ),
    (
      title: 'Бази даних та знань',
      teacher: 'проф. Шаховська Н. Б.',
      info: '12 матеріалів (SQL, ER)',
      topics: 6,
      color: Color(0xFF2E7D32),
    ),
    (
      title: 'Архітектура ПЗ (ЯТПЗ)',
      teacher: 'доц. Федасюк Д. В.',
      info: '9 матеріалів (UML, B2B)',
      topics: 5,
      color: Color(0xFF6A1B9A),
    ),
  ];

  static const List<({String title, String type, String discipline, String date})> recent = [
    (
      title: 'Методичні вказівки до Лабораторної роботи №2.pdf',
      type: 'PDF (1.4 МБ)',
      discipline: 'Кросплатформне програмування',
      date: 'Сьогодні, 20:45',
    ),
    (
      title: 'Конспект лекції: Патерни навігації HIG vs Material',
      type: 'Конспект (MD)',
      discipline: 'Кросплатформне програмування',
      date: 'Вчора, 18:20',
    ),
    (
      title: 'Документація Flutter Material 3 Guide',
      type: 'Веб-лінк',
      discipline: 'Кросплатформне програмування',
      date: '21.10.2026',
    ),
  ];
}

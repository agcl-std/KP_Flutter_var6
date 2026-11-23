import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/models/attachment.dart';

/// Вміст файлу залежно від розширення: PDF, зображення, текст.
/// Використовується і в розділеному вигляді, і на повноекранному [AttachmentViewerScreen].
class AttachmentView extends StatelessWidget {
  final Attachment attachment;

  const AttachmentView({super.key, required this.attachment});

  static const _images = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'};
  static const _texts = {'txt', 'md', 'log', 'csv'};

  @override
  Widget build(BuildContext context) {
    final a = attachment;
    if (!a.isAsset && !File(a.path).existsSync()) {
      return const Center(child: Text('Файл не знайдено на пристрої'));
    }
    if (a.ext == 'pdf') {
      return a.isAsset ? PdfViewer.asset(a.path) : PdfViewer.file(a.path);
    }
    if (_images.contains(a.ext)) {
      return InteractiveViewer(
        maxScale: 6,
        child: Center(child: a.isAsset ? Image.asset(a.path) : Image.file(File(a.path))),
      );
    }
    if (_texts.contains(a.ext)) {
      return FutureBuilder<String>(
        future: a.isAsset ? rootBundle.loadString(a.path) : File(a.path).readAsString(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Не вдалося прочитати файл'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SelectableText(snap.data!),
          );
        },
      );
    }
    return Center(child: Text('Перегляд .${a.ext} не підтримується'));
  }
}

/// Повноекранний перегляд файлу (вузьке вікно / телефон).
class AttachmentViewerScreen extends StatelessWidget {
  final Attachment attachment;

  const AttachmentViewerScreen({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(attachment.name)),
        body: AttachmentView(key: ValueKey(attachment.path), attachment: attachment),
      );
}

IconData attachmentIcon(Attachment a) => switch (a.ext) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'bmp' => Icons.image_outlined,
      'txt' || 'md' || 'log' || 'csv' => Icons.description_outlined,
      _ => Icons.insert_drive_file_outlined,
    };

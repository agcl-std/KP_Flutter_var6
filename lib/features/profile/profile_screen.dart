import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/validators.dart';
import '../../core/state/profile_provider.dart';
import '../../core/state/settings_provider.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';

/// Готові аватари з HTTPS-посиланнями (завантаження власних файлів — лаб. 6).
const _avatars = [
  'https://i.pravatar.cc/150?img=12',
  'https://i.pravatar.cc/150?img=32',
  'https://i.pravatar.cc/150?img=47',
  'https://i.pravatar.cc/150?img=5',
];

/// Профіль користувача та безпека (FR-04): дані й зміна пароля через Firebase Auth.
class ProfileScreen extends StatefulWidget {
  final VoidCallback onSignOut;

  const ProfileScreen({super.key, required this.onSignOut});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileKey = GlobalKey<FormState>();
  late final _nameCtl = TextEditingController(text: context.read<ProfileProvider>().name);
  late final _groupCtl = TextEditingController(text: context.read<ProfileProvider>().group);
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nameCtl, _groupCtl, _current, _new, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<ProfileProvider>().changePassword(current: _current.text, next: _new.text);
      if (!mounted) return;
      _formKey.currentState!.reset();
      for (final c in [_current, _new, _repeat]) {
        c.clear();
      }
      showSnack(context, 'Пароль успішно змінено');
    } catch (e) {
      if (mounted) showSnack(context, AuthRepository.message(e), error: true);
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileKey.currentState!.validate()) return;
    try {
      await context.read<ProfileProvider>().save(name: _nameCtl.text, group: _groupCtl.text);
      if (mounted) showSnack(context, 'Профіль збережено');
    } catch (e) {
      if (mounted) showSnack(context, AuthRepository.message(e), error: true);
    }
  }

  Future<void> _pickAvatar() async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => const _AvatarPickerDialog(),
    );
    if (url == null) return;
    try {
      await context.read<ProfileProvider>().setPhoto(url);
    } catch (e) {
      if (mounted) showSnack(context, AuthRepository.message(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>();
    final name = profile.name;
    final photo = profile.photoUrl;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Профіль та безпека',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: photo == null ? null : NetworkImage(photo),
                      child: photo == null
                          ? Text(name.isEmpty ? '?' : name[0], style: const TextStyle(fontSize: 24))
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Без імені' : name, style: theme.textTheme.titleLarge),
                      if (profile.group.isNotEmpty) Text('Група ${profile.group}'),
                      Text(profile.email, style: theme.textTheme.bodySmall),
                      TextButton(onPressed: _pickAvatar, child: const Text('Змінити фотографію')),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            Text('Дані профілю', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _profileKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Ім’я та прізвище',
                    controller: _nameCtl,
                    validator: (v) => Validators.required(v, 'Ім’я'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Група', controller: _groupCtl),
                  const SizedBox(height: 16),
                  PrimaryButton(
                      label: 'Зберегти профіль',
                      expand: false,
                      loading: profile.busy,
                      onPressed: _saveProfile),
                ],
              ),
            ),
            const Divider(height: 40),
            Text('Зміна пароля', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Поточний пароль',
                    controller: _current,
                    isPassword: true,
                    validator: (v) => Validators.required(v, 'Поточний пароль'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Новий пароль',
                    controller: _new,
                    isPassword: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Повторіть новий пароль',
                    controller: _repeat,
                    isPassword: true,
                    validator: Validators.confirm(() => _new.text),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                      label: 'Оновити пароль',
                      expand: false,
                      loading: profile.busy,
                      onPressed: _changePassword),
                ],
              ),
            ),
            const Divider(height: 40),
            Text('Синхронізація та сховище', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cloud_done_outlined),
              title: Text('Зв\'язок з хмарою встановлено'),
              subtitle: Text('Зайнято 142 МБ із 5 ГБ'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync),
                  label: const Text('Примусова синхронізація')),
            ),
            const Divider(height: 40),
            Text('Налаштування інтерфейсу', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('Мова'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'uk', label: Text('Українська')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: const {'uk'},
              onSelectionChanged: (_) {},
            ),
            const SizedBox(height: 16),
            const Text('Тема'),
            const SizedBox(height: 8),
            Consumer<SettingsProvider>(
              builder: (context, settings, _) => SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Світла')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Темна')),
                  ButtonSegment(value: ThemeMode.system, label: Text('Системна')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => settings.setThemeMode(s.first),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                // Тестова помилка для перевірки інтеграції Sentry.
                onPressed: () async {
                  await Sentry.captureException(
                      StateError('Тестова помилка Lab4'), stackTrace: StackTrace.current);
                  if (context.mounted) showSnack(context, 'Тестову помилку надіслано в Sentry');
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Згенерувати тестову помилку'),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  minimumSize: const Size(0, 44),
                ),
                onPressed: widget.onSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Вийти з облікового запису'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вибір фото: готові HTTPS-аватари або власне HTTPS-посилання з попереднім переглядом.
class _AvatarPickerDialog extends StatefulWidget {
  const _AvatarPickerDialog();

  @override
  State<_AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<_AvatarPickerDialog> {
  final _url = TextEditingController();
  String? _preview;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  bool get _valid => Uri.tryParse(_url.text.trim())?.scheme == 'https';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Оберіть фотографію'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final u in _avatars)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context, u),
                    child: CircleAvatar(radius: 32, backgroundImage: NetworkImage(u)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Або вставте власне HTTPS-посилання на зображення'),
            const SizedBox(height: 8),
            TextField(
              controller: _url,
              decoration: const InputDecoration(hintText: 'https://example.com/photo.jpg'),
              onChanged: (_) => setState(() => _preview = null),
              onSubmitted: (_) => setState(() => _preview = _valid ? _url.text.trim() : null),
            ),
            if (_url.text.isNotEmpty && !_valid)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Посилання має починатися з https://',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (_valid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => setState(() => _preview = _url.text.trim()),
                  child: const Text('Переглянути'),
                ),
              ),
            if (_preview != null)
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(_preview!),
                  onBackgroundImageError: (_, _) {},
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        FilledButton(
          onPressed: _preview == null ? null : () => Navigator.pop(context, _preview),
          child: const Text('Застосувати'),
        ),
      ],
    );
  }
}

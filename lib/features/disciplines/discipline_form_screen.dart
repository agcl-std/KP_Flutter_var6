import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/validators.dart';
import '../../core/models/discipline.dart';
import '../../core/state/catalog_provider.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

const _palette = [0xFF0067C0, 0xFF2E7D32, 0xFF6A1B9A, 0xFFE65100, 0xFFC62828, 0xFF00838F];

/// Створення (initial == null) або редагування дисципліни.
class DisciplineFormScreen extends StatefulWidget {
  final Discipline? initial;

  const DisciplineFormScreen({super.key, this.initial});

  @override
  State<DisciplineFormScreen> createState() => _DisciplineFormScreenState();
}

class _DisciplineFormScreenState extends State<DisciplineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _teacher = TextEditingController(text: widget.initial?.teacher);
  late int _semester = widget.initial?.semester ?? 5;
  late int _color = widget.initial?.color ?? _palette.first;

  @override
  void dispose() {
    _title.dispose();
    _teacher.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final d = Discipline(
      id: widget.initial?.id ?? CatalogProvider.newId(),
      title: _title.text.trim(),
      teacher: _teacher.text.trim(),
      semester: _semester,
      color: _color,
    );
    await context.read<CatalogProvider>().saveDiscipline(d);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Редагування дисципліни' : 'Нова дисципліна')),
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
                AppTextField(
                    label: 'Викладач',
                    controller: _teacher,
                    validator: (v) => Validators.required(v, 'Викладач')),
                const SizedBox(height: 16),
                const Text('Семестр', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: _semester,
                  items: [for (var i = 1; i <= 8; i++) DropdownMenuItem(value: i, child: Text('$i')) ],
                  onChanged: (v) => setState(() => _semester = v ?? _semester),
                ),
                const SizedBox(height: 16),
                const Text('Колір', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    for (final c in _palette)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _color = c),
                        child: CircleAvatar(
                          backgroundColor: Color(c),
                          child: _color == c ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      ),
                  ],
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

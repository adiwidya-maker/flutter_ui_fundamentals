import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'home_page.dart' show studentName, studentId;

/// Form untuk Tambah (course == null) dan Edit (course != null).
class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key, this.course});

  final Course? course;

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  static const List<String> _defaultStatuses = ['planned', 'active', 'done'];
  late List<String> _statusOptions;
  late String _status;

  bool get _isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _codeController = TextEditingController(text: c?.code ?? '');
    _titleController = TextEditingController(text: c?.title ?? '');
    _creditsController =
        TextEditingController(text: c != null ? c.credits.toString() : '');

    _status = c?.status ?? 'planned';
    // Jaga-jaga jika status dari server di luar tiga pilihan standar
    _statusOptions = [..._defaultStatuses];
    if (!_statusOptions.contains(_status)) {
      _statusOptions.add(_status);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CourseProvider>();

    final course = Course(
      id: widget.course?.id,
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    final bool success;
    if (_isEdit) {
      final id = widget.course!.id;
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course ini tidak memiliki id')),
        );
        return;
      }
      success = await provider.updateCourse(id, course);
    } else {
      success = await provider.createCourse(course);
    }

    // Wajib dicek setelah await sebelum memakai context
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Course berhasil diperbarui'
                : 'Course berhasil ditambahkan',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.saveError ?? 'Gagal menyimpan course'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Course' : 'Tambah Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeController,
                // Saat edit: read-only karena code dipakai sebagai kunci favorites
                readOnly: _isEdit,
                enabled: !isSaving,
                decoration: InputDecoration(
                  labelText: 'Kode Course',
                  hintText: 'contoh: MOB07',
                  helperText: _isEdit
                      ? 'Kode tidak dapat diubah (kunci favorites)'
                      : null,
                  border: const OutlineInputBorder(),
                  filled: _isEdit,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Judul Course',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credits (SKS)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Credits wajib diisi';
                  }
                  final number = int.tryParse(value.trim());
                  if (number == null) {
                    return 'Credits harus berupa angka';
                  }
                  if (number <= 0) {
                    return 'Credits harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _status = value);
                      },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // null = tombol nonaktif selama request berjalan
                onPressed: isSaving ? null : _submit,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving
                      ? 'Menyimpan...'
                      : (_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '$studentName • $studentId',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'home_page.dart' show studentName, studentId;

class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();

  static const List<String> _statusOptions = ['planned', 'active', 'done'];
  String _status = 'planned';

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
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    final success = await provider.createCourse(course);

    // Wajib dicek setelah await sebelum memakai context
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course berhasil ditambahkan')),
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
      appBar: AppBar(title: const Text('Tambah Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Kode Course',
                  hintText: 'contoh: MOB07',
                  border: OutlineInputBorder(),
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
                label: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.course});

  // Data diterima lewat constructor
  final Course course;

  Future<void> _confirmDelete(BuildContext context, Course target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus course?'),
        content: Text(
          'Course "${target.title}" (${target.code}) akan dihapus. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final provider = context.read<CourseProvider>();
    final success = await provider.deleteCourse(target);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Course berhasil dihapus'
              : (provider.saveError ?? 'Gagal menghapus course'),
        ),
      ),
    );

    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    // Ambil versi terbaru dari provider (setelah edit/refresh)
    final current = provider.courses.firstWhere(
      (c) => c.id != null && c.id == course.id,
      orElse: () => course,
    );
    final isFav = provider.isFavorite(current.code);

    return Scaffold(
      appBar: AppBar(
        title: Text(current.code),
        actions: [
          IconButton(
            tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => provider.toggleFavorite(current.code),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                current.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Kode: ${current.code}')),
                  Chip(label: Text('${current.credits} SKS')),
                  Chip(label: Text('Status: ${current.status}')),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CourseFormPage(course: current),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _confirmDelete(context, current),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '$studentName • $studentId',
                  style: TextStyle(color: mutedColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
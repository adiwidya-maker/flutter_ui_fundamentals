import 'package:flutter/material.dart';
import '../models/course.dart';

const Color primaryColor = Color(0xFF2563EB);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF64748B);
const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';

class CourseDetailPage extends StatelessWidget {
  final Course course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Text(
                          course.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kode materi: ${course.code}',
                          style: const TextStyle(color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    onFavoriteChanged();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
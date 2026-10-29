import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart' hide textColor, mutedColor;
import 'course_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteCourses = provider.courses
        .where((course) => provider.isFavorite(course.code))
        .toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/foto.didi.jpeg'),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'NIM: $studentId • Semester 5',
                  style: TextStyle(color: mutedColor),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Materi Favorit Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Chip(
                    label: Text('${favoriteCourses.length} Disukai'),
                    backgroundColor: const Color(0xFFEAF2FF),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (favoriteCourses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Belum ada materi favorit yang dipilih.',
                      style: TextStyle(color: mutedColor),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoriteCourses.length,
                  itemBuilder: (context, index) {
                    final course = favoriteCourses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CourseListTileWidget(
                        course: course,
                        isFavorite: true,
                        onFavoriteChanged: () =>
                            provider.toggleFavorite(course.code),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                        onLongPress: () {},
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
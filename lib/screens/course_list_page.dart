import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_page.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseListTileWidget(
                course: course,
                isFavorite: provider.isFavorite(course.code),
                onFavoriteChanged: () => provider.toggleFavorite(course.code),
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
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/course.dart';

const Color primaryColor = Color(0xFF2563EB);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF64748B);

class CourseListTileWidget extends StatelessWidget {
  final Course course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CourseListTileWidget({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: course.isDone
                      ? const Color(0xFFE8F8EF)
                      : const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  course.isDone
                      ? Icons.check_circle_outline
                      : Icons.menu_book_rounded,
                  color: course.isDone
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.code} • ${course.creditsLabel}',
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoriteChanged,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
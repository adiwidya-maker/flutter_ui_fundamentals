import 'package:flutter/material.dart';
import '../models/course.dart';

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
      child: ListTile(
        title: Text(course.title),
        subtitle: Text(course.code),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onFavoriteChanged,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
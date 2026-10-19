
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
}

class AssetCourseRepository implements CourseRepository {
  final String assetPath;

  const AssetCourseRepository({
    this.assetPath = 'assets/data/student_data.json',
  });

  @override
  Future<List<Course>> getCourses() async {
    final String jsonString =
        await rootBundle.loadString(assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'Format JSON harus berupa objek.',
      );
    }

    final dynamic rawCourses = decoded['courses'];

    if (rawCourses is! List) {
      throw const FormatException(
        'Properti courses tidak ditemukan dalam JSON.',
      );
    }

    return rawCourses.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Data kursus harus berupa objek JSON.',
        );
      }

      return Course.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}

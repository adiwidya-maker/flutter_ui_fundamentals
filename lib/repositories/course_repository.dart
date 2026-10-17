
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course.dart';

// Kontrak repository untuk mengambil data kursus.
abstract class CourseRepository {
  Future<List<Course>> getCourses();
}

// Implementasi repository untuk membaca data dari JSON.
class AssetCourseRepository implements CourseRepository {
  final String assetPath;

  const AssetCourseRepository({
    this.assetPath = 'assets/data/student_data.json',
  });

  @override
  Future<List<Course>> getCourses() async {
    final String jsonString =
        await rootBundle.loadString(assetPath);

    final dynamic decodedData = jsonDecode(jsonString);

    if (decodedData is! Map) {
      throw const FormatException(
        'Format JSON tidak valid. Data utama harus berupa objek.',
      );
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(decodedData);

    final dynamic rawCourses = data['courses'];

    if (rawCourses is! List) {
      throw const FormatException(
        'Data JSON harus memiliki properti courses berupa daftar.',
      );
    }

    final List<Course> courses = [];

    for (final dynamic item in rawCourses) {
      if (item is! Map) {
        throw const FormatException(
          'Setiap materi harus berupa objek JSON.',
        );
      }

      courses.add(
        Course.fromJson(
          Map<String, dynamic>.from(item),
        ),
      );
    }

    return courses;
  }
}

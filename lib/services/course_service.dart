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
    final String jsonString = await rootBundle.loadString(assetPath);
    final dynamic decodedData = jsonDecode(jsonString);

    if (decodedData is! Map) {
      throw const FormatException(
        'Format JSON tidak valid. Data utama harus berupa objek.',
      );
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(decodedData);
    final dynamic rawCourses = data['courses'];

    if (rawCourses is! List) {
      throw const FormatException(
        'Data JSON harus memiliki properti courses berupa daftar.',
      );
    }

    final List<Course> courses = [];

    for (final dynamic item in rawCourses) {
      if (item is! Map) {
        throw const FormatException('Setiap materi harus berupa objek JSON.');
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

class CourseService {
  final CourseRepository repository;

  const CourseService({
    required this.repository,
  });

  Future<List<Course>> fetchCourses() {
    return repository.getCourses();
  }
}
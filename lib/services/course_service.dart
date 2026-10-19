
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../repositories/course_repository.dart';

// GANTI dengan URL GET yang kamu dapatkan dari MockBolt.
const String apiUrl = 'https://mockbolt.com/b/e67eddee-9e3d-44c3-ae85-0c565de24048';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(
    Uri.parse(apiUrl),
  );

  if (response.statusCode == 200) {
    final dynamic data = jsonDecode(response.body);

    if (data is List) {
      return data;
    }

    if (data is Map) {
      return <dynamic>[
        Map<String, dynamic>.from(data),
      ];
    }

    throw const FormatException(
      'Format response JSON tidak valid.',
    );
  }

  throw Exception('HTTP ${response.statusCode}');
}

Future<void> testFetchCourses() async {
  try {
    final courses = await fetchCourses();

    debugPrint('HTTP GET berhasil.');
    debugPrint('Jumlah item: ${courses.length}');
    debugPrint('Response JSON: $courses');
  } catch (error) {
    debugPrint('HTTP GET gagal: $error');
  }
}

// CourseService yang sudah digunakan aplikasi tetap dipertahankan.
class CourseService {
  final CourseRepository repository;

  CourseService({
    required this.repository,
  });

  Future<List<Course>> getCourses() async {
    return await repository.getCourses();
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../repositories/course_repository.dart';

// URL endpoint API latihan (menggunakan JSONPlaceholder sesuai tahap sebelumnya)
const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

Future<List<dynamic>> fetchCoursesFromApi() async {
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
    final courses = await fetchCoursesFromApi();

    debugPrint('HTTP GET berhasil.');
    debugPrint('Jumlah item: ${courses.length}');
    debugPrint('Response JSON: $courses');
  } catch (error) {
    debugPrint('HTTP GET gagal: $error');
  }
}

// CourseService yang terintegrasi dengan pemetaan model Course.
class CourseService {
  final CourseRepository repository;

  CourseService({
    required this.repository,
  });

  Future<List<Course>> getCourses() async {
    try {
      // Mengambil data mentah dari API
      final rawData = await fetchCoursesFromApi();
      
      // Mengonversi response list JSON mentah menjadi List<Course> menggunakan Course.fromJson
      return rawData
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Gagal mengambil dari API, beralih ke repository lokal: $e');
      // Fallback ke repository lokal jika jaringan bermasalah
      return await repository.getCourses();
    }
  }
}
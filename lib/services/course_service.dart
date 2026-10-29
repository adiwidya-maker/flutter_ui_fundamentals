import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../repositories/course_repository.dart';

// URL API MockBolt asli dengan data mata kuliah
const String apiUrl = 'https://mockbolt.com/b/e67eddee-9e3d-44c3-ae85-0c565de24048';

class CourseService {
  final CourseRepository repository;

  CourseService({
    required this.repository,
  });

  // Fungsi internal dipindahkan ke dalam class Service agar terenkapsulasi
  Future<List<dynamic>> _fetchCoursesFromApi() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }
      if (data is Map) {
        return <dynamic>[Map<String, dynamic>.from(data)];
      }

      throw const FormatException('Format response JSON tidak valid.');
    }

    throw Exception('HTTP Error: ${response.statusCode}');
  }

  // Method utama yang akan dipanggil oleh CourseProvider
  Future<List<Course>> getCourses() async {
    try {
      // 1. Mencoba mengambil data dari internet (API)
      final rawData = await _fetchCoursesFromApi();
      
      // Mengonversi response JSON menjadi List<Course>
      final List<Course> coursesFromApi = rawData
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
          
      debugPrint('Berhasil mengambil ${coursesFromApi.length} data dari API MockBolt.');
      return coursesFromApi;
      
    } catch (e) {
      // 2. Fallback: Jika internet mati atau API bermasalah, gunakan data lokal
      debugPrint('Gagal mengambil dari API, beralih ke repository lokal (Asset). Error: $e');
      return await repository.getCourses();
    }
  }
}
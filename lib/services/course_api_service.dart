import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  // Constructor meminta baseUrl saat class dipanggil
  CourseApiService(this.baseUrl);

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final http.Response response;

    try {
      // Tambahkan /courses di belakang baseUrl
      response = await http
          .get(Uri.parse('$baseUrl/courses'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw Exception(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi internet atau URL endpoint.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil course. Status: ${response.statusCode}',
      );
    }

    // Memparsing JSON
    final dynamic decodedData = jsonDecode(response.body);
    final List<dynamic> data;

    // Menangani format array (List) atau objek tunggal (Map) dari MockBolt
    if (decodedData is List) {
      data = decodedData;
    } else if (decodedData is Map) {
      data = [decodedData];
    } else {
      throw const FormatException('Format response JSON tidak valid.');
    }

    // Mapping JSON ke model Course
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
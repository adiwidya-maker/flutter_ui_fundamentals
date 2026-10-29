import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  // Constructor meminta baseUrl saat class dipanggil
  CourseApiService(this.baseUrl);

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    // Memanggil endpoint API
    final response = await http.get(Uri.parse(baseUrl));

    // Mengecek status HTTP
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course. Status: ${response.statusCode}');
    }

    // Memparsing JSON
    final dynamic decodedData = jsonDecode(response.body);
    List<dynamic> data;

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
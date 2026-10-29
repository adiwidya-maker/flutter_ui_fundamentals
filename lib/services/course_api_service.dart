import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  // Constructor meminta baseUrl saat class dipanggil
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // ---------------------------------------------------------------
  // GET /courses  (Tahap 4-5)
  // ---------------------------------------------------------------
  Future<List<Course>> getCourses() async {
    final http.Response response;

    try {
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

    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------
  // POST /courses  (Tahap 6)
  // ---------------------------------------------------------------
  Future<Course> createCourse(Course course) async {
    final http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/courses'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(course.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw Exception(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi internet atau URL endpoint.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Server biasanya mengembalikan resource baru (lengkap dengan id).
      // Jika body kosong / bentuknya berbeda, pakai data yang dikirim
      // supaya proses simpan yang sudah berhasil tidak dianggap gagal.
      try {
        return Course.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } catch (_) {
        return course;
      }
    }

    throw Exception('Gagal membuat course. Status: ${response.statusCode}');
  }

  // ---------------------------------------------------------------
  // PUT /courses/{id}  (Tahap 7)
  // ---------------------------------------------------------------
  Future<void> updateCourse(int id, Course course) async {
    final http.Response response;

    try {
      response = await http
          .put(
            Uri.parse('$baseUrl/courses/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(course.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw Exception(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi internet atau URL endpoint.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course. Status: ${response.statusCode}',
      );
    }
  }

  // ---------------------------------------------------------------
  // DELETE /courses/{id}  (Tahap 8)
  // ---------------------------------------------------------------
  Future<void> deleteCourse(int id) async {
    final http.Response response;

    try {
      response = await http
          .delete(Uri.parse('$baseUrl/courses/$id'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw Exception(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi internet atau URL endpoint.',
      );
    }

    // 204 No Content termasuk rentang 2xx
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal menghapus course. Status: ${response.statusCode}',
      );
    }
  }
}
// Nama : I Gede Adiwidya Utama
// NIM  : 2415051001
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  // id dan created_at dibuat oleh database (identity GENERATED ALWAYS),
  // jadi tidak boleh ikut dikirim saat INSERT/UPDATE.
  Map<String, dynamic> _payload(Course course) {
    final json = course.toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }

  // Tahap 12: SELECT
  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase.from('courses').select().order('id');
    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Tahap 13: INSERT
  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(_payload(course))
        .select()
        .single();
    return Course.fromJson(row);
  }

  // Tahap 14: UPDATE berdasarkan id
  @override
  Future<void> updateCourse(int id, Course course) async {
    await supabase.from('courses').update(_payload(course)).eq('id', id);
  }

  // Tahap 15: DELETE berdasarkan id
  @override
  Future<void> deleteCourse(int id) async {
    final deleted = await supabase
        .from('courses')
        .delete()
        .eq('id', id)
        .select();

    // Jika RLS memblokir DELETE, Supabase tidak melempar error, tetapi
    // 0 baris terhapus. Cek agar tidak dianggap berhasil.
    if (deleted.isEmpty) {
      throw Exception(
        'Course tidak terhapus. Periksa policy DELETE (RLS) atau id course.',
      );
    }
  }
}
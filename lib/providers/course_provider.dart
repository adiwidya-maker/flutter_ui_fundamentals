import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/course_api_service.dart';

enum CourseLoadStatus {
  initial,
  loading,
  success,
  error,
}

class CourseProvider extends ChangeNotifier {
  final CourseApiService service;

  CourseProvider({
    required this.service,
  });

  CourseLoadStatus _status = CourseLoadStatus.initial;
  List<Course> _courses = <Course>[];
  String? _error;

  CourseLoadStatus get status => _status;
  List<Course> get courses => List<Course>.unmodifiable(_courses);

  // Nama field sesuai worksheet: courses, isLoading, error
  String? get error => _error;

  bool get isLoading =>
      _status == CourseLoadStatus.loading ||
      _status == CourseLoadStatus.initial;
  bool get hasError => _status == CourseLoadStatus.error;
  bool get hasData => _status == CourseLoadStatus.success;

  Future<void> loadCourses() async {
    _status = CourseLoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final List<Course> result = await service.getCourses();
      _courses = result;
      _status = CourseLoadStatus.success;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = CourseLoadStatus.error;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Tahap 6: CREATE (POST)
  // ---------------------------------------------------------------
  bool _isSaving = false;
  String? _saveError;

  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  /// Mengirim course baru. Mengembalikan true jika berhasil.
  /// Error penyimpanan disimpan di [saveError] (terpisah dari [error]
  /// supaya halaman list tidak berubah menjadi layar error).
  Future<bool> createCourse(Course course) async {
    if (_isSaving) return false; // guard submit ganda

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      await service.createCourse(course);
    } catch (e) {
      _saveError = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }

    // Refresh list: isi list diganti dari server, bukan ditambah manual
    await loadCourses();

    _isSaving = false;
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------
  // Tahap 7: UPDATE (PUT)
  // ---------------------------------------------------------------
  /// Memperbarui course berdasarkan [id]. Mengembalikan true jika berhasil.
  /// Favorites memakai code sebagai kunci dan code tidak berubah,
  /// sehingga status favorit tetap konsisten setelah refresh.
  Future<bool> updateCourse(int id, Course course) async {
    if (_isSaving) return false; // guard submit ganda

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      await service.updateCourse(id, course);
    } catch (e) {
      _saveError = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }

    await loadCourses();

    _isSaving = false;
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------
  // Tahap 8: DELETE
  // ---------------------------------------------------------------
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  /// Menghapus course. Jika course ada di favorites, ikut dihapus dari
  /// favorites agar tidak tersisa data yatim. Mengembalikan true jika berhasil.
  Future<bool> deleteCourse(Course course) async {
    if (_isDeleting) return false;

    final id = course.id;
    if (id == null) {
      _saveError = 'Course ini tidak memiliki id';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    _saveError = null;
    notifyListeners();

    try {
      await service.deleteCourse(id);
    } catch (e) {
      _saveError = e.toString().replaceFirst('Exception: ', '');
      _isDeleting = false;
      notifyListeners();
      return false;
    }

    // Bersihkan dari favorites (kunci favorites = code)
    _favorites.remove(course.code);

    await loadCourses();

    _isDeleting = false;
    notifyListeners();
    return true;
  }

  // Shared State untuk Favorites
  final Set<String> _favorites = <String>{};

  bool isFavorite(String code) {
    return _favorites.contains(code);
  }

  Set<String> get favoriteCodes => Set<String>.unmodifiable(_favorites);
  int get favoriteCount => _favorites.length;

  void toggleFavorite(String code) {
    if (code.isEmpty) return;

    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }
}
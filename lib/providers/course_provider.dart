import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/course_service.dart';

enum CourseLoadStatus {
  initial,
  loading,
  success,
  error,
}

class CourseProvider extends ChangeNotifier {
  final CourseService service;

  CourseProvider({
    required this.service,
  });

  CourseLoadStatus _status = CourseLoadStatus.initial;
  List<Course> _courses = <Course>[];
  String? _errorMessage;

  CourseLoadStatus get status => _status;
  List<Course> get courses => List<Course>.unmodifiable(_courses);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == CourseLoadStatus.loading;
  bool get hasError => _status == CourseLoadStatus.error;
  bool get hasData => _status == CourseLoadStatus.success;

  Future<void> loadCourses() async {
    _status = CourseLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Course> result = await service.getCourses();
      _courses = result;
      _status = CourseLoadStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = CourseLoadStatus.error;
    }

    notifyListeners();
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
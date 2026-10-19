import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'services/course_service.dart';
import 'screens/home_page.dart';
import 'repositories/course_repository.dart';

const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);
const Color textColor = Color(0xFF172033);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseProvider>(
          create: (_) {
            final provider = CourseProvider(
              service: CourseService(
                repository: const AssetCourseRepository(),
              ),
            );
            provider.loadCourses();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Course Explorer v2',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: pageColor,
        ),
        home: const CourseExplorerPage(),
      ),
    );
  }
}
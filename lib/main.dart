import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'services/course_api_service.dart';
import 'screens/home_page.dart';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);

// Base URL API (tanpa /courses). Untuk simulasi error, ubah sementara
// misalnya menjadi 'https://course-api-pearl.vercel.app/salah'.
const String apiBaseUrl = 'https://course-api-pearl.vercel.app';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseProvider>(
          // loadCourses() dipanggil satu kali saat provider dibuat
          create: (_) => CourseProvider(
            service: CourseApiService(apiBaseUrl),
          )..loadCourses(),
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
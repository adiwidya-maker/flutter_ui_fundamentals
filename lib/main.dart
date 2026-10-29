import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';   // BARU
import 'config/supabase_config.dart';                      // BARU
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_api_service.dart';
import 'services/course_data_source.dart';
import 'screens/home_page.dart';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);

// Base URL API (tanpa /courses). Untuk simulasi error, ubah sementara.
const String apiBaseUrl = 'https://course-api-pearl.vercel.app';

Future<void> main() async {                                // DIUBAH: async
  WidgetsFlutterBinding.ensureInitialized();

  // BARU: inisialisasi Supabase sebelum runApp()
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Merakit service -> repository. Hanya baris dataSource ini yang
  // berubah ketika sumber data diganti (REST <-> Supabase).
  final CourseDataSource dataSource = CourseApiService(apiBaseUrl);
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
      // loadCourses() dipanggil satu kali saat provider dibuat
      create: (_) => CourseProvider(repository)..loadCourses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
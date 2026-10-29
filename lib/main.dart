import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_constants.dart';
import 'config/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/responsive_shell.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

const Color pageColor = Color(0xFFF5F7FB);

// Dipakai bila ingin kembali ke REST: CourseApiService(apiBaseUrl)
const String apiBaseUrl = 'https://course-api-pearl.vercel.app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Data source aktif: Supabase (satu-satunya baris yang berubah REST <-> Supabase)
  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
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
      home: const ResponsiveShell(),
    );
  }
}
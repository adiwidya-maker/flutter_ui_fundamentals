import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'services/course_api_service.dart';
import 'screens/home_page.dart';

const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);
const Color textColor = Color(0xFF172033);

// Tahap 2: Konstanta URL endpoint latihan
const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

// Tahap 2: Fungsi asynchronous untuk request HTTP GET dan parsing JSON
Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    debugPrint('Jumlah item data berhasil ditarik: ${data.length}');
    return data;
  }
  
  throw Exception('HTTP Error: ${response.statusCode}');
}

void main() async {
  // Memastikan binding Flutter siap sebelum melakukan uji coba async jika diperlukan
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uji coba pemanggilan fungsi fetchCourses di console (opsional untuk Tahap 2)
  try {
    await fetchCourses();
  } catch (e) {
    debugPrint('Terjadi kesalahan saat fetch: $e');
  }

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
            // ---> BAGIAN YANG DIGANTI UNTUK TAHAP 4 <---
            // Menggunakan CourseApiService dengan URL MockBolt
            final provider = CourseProvider(
              service: CourseApiService(
                'https://mockbolt.com/b/e67eddee-9e3d-44c3-ae85-0c565de24048',
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
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

const String studentName = 'I Gede Adiwidya Utama';

const String studentId = '2415051001';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Learning Dashboard'),
        ),
        body: const DashboardPage(),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  Future<Map<String, dynamic>> loadStudentData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final Map<String, dynamic> data = jsonDecode(jsonString);

    return data;
  }

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCourseCard(
    Map<String, dynamic> course,
  ) {
    final bool isDone = course['status'] == 'done';

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: ListTile(
        leading: Icon(
          isDone
              ? Icons.check_circle
              : Icons.menu_book,
          color: isDone
              ? Colors.green
              : Colors.orange,
        ),
        title: Text(
          course['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${course['code']} • ${course['credits']} SKS',
        ),
        trailing: Text(
          isDone ? 'Selesai' : 'Belum',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDone
                ? Colors.green
                : Colors.orange,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat data: ${snapshot.error}',
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'Data tidak tersedia',
            ),
          );
        }

        final data = snapshot.data!;

        final student =
            data['student'] as Map<String, dynamic>;

        final courses =
            data['courses'] as List<dynamic>;

        final int completed =
            courses.where((course) {
          return course['status'] == 'done';
        }).length;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                            'assets/images/foto.didi.jpeg',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          student['name'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student['nim'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mahasiswa yang tertarik pada pemrograman mobile dan desain.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    buildSummaryCard(
                      'Total Materi',
                      '${courses.length}',
                      Icons.menu_book,
                    ),
                    const SizedBox(width: 12),
                    buildSummaryCard(
                      'Selesai',
                      '$completed',
                      Icons.check_circle,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Data Pembelajaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Jumlah Materi: ${courses.length}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Materi Selesai: $completed',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Materi Belum: ${courses.length - completed}',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Data berasal dari student_data.json',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$studentId - $studentName - Ini adalah teks yang sangat panjang untuk menguji layout',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Materi Pembelajaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course =
                        courses[index]
                            as Map<String, dynamic>;

                    return buildCourseCard(course);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
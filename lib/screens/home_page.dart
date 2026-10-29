import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';

const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';
const Color primaryColor = Color(0xFF2563EB);
const Color mutedColor = Color(0xFF64748B);
const Color textColor = Color(0xFF172033);

class CourseExplorerPage extends StatefulWidget {
  const CourseExplorerPage({super.key});

  @override
  State<CourseExplorerPage> createState() => _CourseExplorerPageState();
}

class _CourseExplorerPageState extends State<CourseExplorerPage> {
  int selectedIndex = 0;

  // Scaffold sederhana untuk state loading / error / empty.
  // Nama & NIM tetap tampil agar valid sebagai bukti screenshot.
  Widget _stateScaffold(Widget child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer v2')),
      body: Column(
        children: [
          Expanded(child: child),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '$studentName • $studentId',
              style: TextStyle(color: mutedColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    // 1. LOADING -> progress indicator
    if (courseProvider.isLoading) {
      return _stateScaffold(
        const Center(child: CircularProgressIndicator()),
      );
    }

    // 2. ERROR -> pesan + tombol Retry
    if (courseProvider.error != null) {
      return _stateScaffold(
        ErrorView(
          message: courseProvider.error!,
          onRetry: courseProvider.loadCourses,
        ),
      );
    }

    // 3. EMPTY -> pesan data belum tersedia
    if (courseProvider.courses.isEmpty) {
      return _stateScaffold(
        const Center(child: Text('Data course belum tersedia')),
      );
    }

    // 4. SUCCESS
    final courses = courseProvider.courses;
    final favoriteCourses = courses
        .where((course) => courseProvider.isFavorite(course.code))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer v2'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: courseProvider.loadCourses,
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          // TAB 0: HOME / BERANDA
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 31,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(
                                'assets/images/foto.didi.jpeg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $studentName!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Selamat datang di dashboard pembelajaranmu.',
                                  style: TextStyle(color: Color(0xFFE0E7FF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'NIM : $studentId',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Semester 5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Total Materi Tersedia: ${courses.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Lihat Daftar Materi'),
                ),
              ],
            ),
          ),

          // TAB 1: COURSES (Daftar Materi)
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final Course course = courses[index];
              final bool isFav = courseProvider.isFavorite(course.code);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseListTileWidget(
                  course: course,
                  isFavorite: isFav,
                  onFavoriteChanged: () {
                    courseProvider.toggleFavorite(course.code);
                  },
                  onTap: () {},
                  onLongPress: () {},
                ),
              );
            },
          ),

          // TAB 2: FAVORITES & PROFIL
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/images/foto.didi.jpeg'),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'NIM: $studentId • Semester 5',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Materi Favorit Saya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Chip(
                      label: Text('${favoriteCourses.length} Disukai'),
                      backgroundColor: const Color(0xFFEAF2FF),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (favoriteCourses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Belum ada materi favorit yang dipilih.',
                        style: TextStyle(color: mutedColor),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoriteCourses.length,
                    itemBuilder: (context, index) {
                      final course = favoriteCourses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CourseListTileWidget(
                          course: course,
                          isFavorite: true,
                          onFavoriteChanged: () {
                            courseProvider.toggleFavorite(course.code);
                          },
                          onTap: () {},
                          onLongPress: () {},
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
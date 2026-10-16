import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF64748B);

// ======================================================
// TAHAP 5: CHANGE NOTIFIER
// TAHAP 6: PROVIDER
// ======================================================

class FavoritesModel extends ChangeNotifier {
  final Set<String> _favorites = <String>{};

  bool isFavorite(String code) {
    return _favorites.contains(code);
  }

  Set<String> get favoriteCodes =>
      Set<String>.unmodifiable(_favorites);

  int get count => _favorites.length;

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

// ======================================================
// MAIN
// ======================================================

void main() {
  runApp(const MyApp());
}

// ======================================================
// APPLICATION
// TAHAP 6: CHANGENOTIFIERPROVIDER
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FavoritesModel>(
      create: (_) => FavoritesModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Course Explorer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: pageColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: pageColor,
            foregroundColor: textColor,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(
                color: Color(0xFFE8EDF5),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        home: const CourseExplorerPage(),
      ),
    );
  }
}

// ======================================================
// MAIN PAGE
// ======================================================

class CourseExplorerPage extends StatefulWidget {
  const CourseExplorerPage({super.key});

  @override
  State<CourseExplorerPage> createState() =>
      _CourseExplorerPageState();
}

class _CourseExplorerPageState
    extends State<CourseExplorerPage> {
  late Future<Map<String, dynamic>> studentFuture;

  int selectedIndex = 0;

  // TAHAP 1: LOCAL STATE.
  bool showStudentInfo = false;

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  final TextEditingController feedbackController =
      TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();

    // FavoritesModel dikelola oleh Provider,
    // sehingga tidak perlu di-dispose di sini.
  }

  // ====================================================
  // LOAD JSON DATA
  // ====================================================

  Future<Map<String, dynamic>> loadStudentData() async {
    final String jsonString =
        await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    return jsonDecode(jsonString)
        as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> getCourses(
    Map<String, dynamic> data,
  ) {
    final List<dynamic> rawCourses =
        data['courses'] as List<dynamic>? ?? [];

    return rawCourses
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  int getCompletedCount(
    List<Map<String, dynamic>> courses,
  ) {
    return courses
        .where(
          (course) => course['status'] == 'done',
        )
        .length;
  }

  String courseKey(Map<String, dynamic> course) {
    return (
      course['code'] ??
      course['title'] ??
      ''
    ).toString();
  }

  // ====================================================
  // TAHAP 7: CONTEXT.READ()
  // Mengakses model untuk melakukan aksi.
  // Tidak berlangganan perubahan state.
  // ====================================================

  void toggleFavorite(String code) {
    final FavoritesModel model =
        context.read<FavoritesModel>();

    final bool wasFavorite = model.isFavorite(code);

    model.toggleFavorite(code);

    showMessage(
      wasFavorite
          ? 'Materi dihapus dari favorit.'
          : 'Materi ditambahkan ke favorit.',
    );
  }

  // ====================================================
  // SNACKBAR MESSAGE
  // ====================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ====================================================
  // OPEN COURSE DETAIL
  // ====================================================

  Future<void> openCourse(
    Map<String, dynamic> course,
  ) async {
    final String code = courseKey(course);

    // context.read digunakan untuk mengambil
    // status saat halaman detail dibuka.
    final bool currentFavorite =
        context.read<FavoritesModel>().isFavorite(code);

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CourseDetailPage(
          course: course,
          isFavorite: currentFavorite,
          onFavoriteChanged: () {
            toggleFavorite(code);
          },
        ),
      ),
    );
  }

  // ====================================================
  // BOTTOM NAVIGATION BAR
  // ====================================================

  Widget buildNavigationBar() {
    return NavigationBar(
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
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Materi',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  // ====================================================
  // NAVIGATION RAIL
  // ====================================================

  Widget buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Icon(
          Icons.school_rounded,
          size: 34,
          color: primaryColor,
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Beranda'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: Text('Materi'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profil'),
        ),
      ],
    );
  }

  // ====================================================
  // MAIN BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Data pembelajaran gagal dimuat.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          studentFuture =
                              loadStudentData();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final Map<String, dynamic> data =
            snapshot.data ?? {};

        final List<Map<String, dynamic>> courses =
            getCourses(data);

        final int completed =
            getCompletedCount(courses);

        final List<Widget> pages = [
          buildHomePage(courses, completed),
          buildCoursesPage(courses),
          buildProfilePage(),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool expanded =
                constraints.maxWidth >= 840;

            return Scaffold(
              appBar: AppBar(
                title: const Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      color: primaryColor,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Course Explorer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (constraints.maxWidth >= 500)
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Center(
                        child: Text(
                          'Learning Dashboard',
                          style: TextStyle(
                            color: mutedColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              body: expanded
                  ? Row(
                      children: [
                        buildNavigationRail(),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xFFE8EDF5),
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: selectedIndex,
                            children: pages,
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(
                      index: selectedIndex,
                      children: pages,
                    ),
              bottomNavigationBar:
                  expanded ? null : buildNavigationBar(),
            );
          },
        );
      },
    );
  }

  // ====================================================
  // HOME PAGE
  // ====================================================

  Widget buildHomePage(
    List<Map<String, dynamic>> courses,
    int completed,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide =
            constraints.maxWidth >= 700;

        final double horizontalPadding =
            constraints.maxWidth >= 1000 ? 36 : 20;

        final int remaining =
            courses.length - completed;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  buildWelcomeBanner(),
                  const SizedBox(height: 24),

                  // TAHAP 1: LOCAL STATE.

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: primaryColor,
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Eksperimen Local State',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tekan tombol di bawah untuk menampilkan atau menyembunyikan informasi mahasiswa.',
                            style: TextStyle(
                              color: mutedColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  showStudentInfo =
                                      !showStudentInfo;
                                });
                              },
                              icon: Icon(
                                showStudentInfo
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              label: Text(
                                showStudentInfo
                                    ? 'Sembunyikan Informasi'
                                    : 'Tampilkan Informasi',
                              ),
                            ),
                          ),
                          if (showStudentInfo) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    studentName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'NIM: $studentId',
                                    style: TextStyle(
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Program Studi: Pendidikan Teknik Informatika',
                                    style: TextStyle(
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Semester: 5',
                                    style: TextStyle(
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Ringkasan Pembelajaran',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (wide)
                    Row(
                      children: [
                        Expanded(
                          child: buildStatCard(
                            'Total Materi',
                            '${courses.length}',
                            Icons.menu_book_rounded,
                            const Color(0xFFEAF2FF),
                            primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildStatCard(
                            'Materi Selesai',
                            '$completed',
                            Icons.check_circle_outline,
                            const Color(0xFFE8F8EF),
                            const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildStatCard(
                            'Belum Selesai',
                            '$remaining',
                            Icons.schedule_rounded,
                            const Color(0xFFFFF4E5),
                            const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        buildStatCard(
                          'Total Materi',
                          '${courses.length}',
                          Icons.menu_book_rounded,
                          const Color(0xFFEAF2FF),
                          primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildStatCard(
                                'Selesai',
                                '$completed',
                                Icons.check_circle_outline,
                                const Color(0xFFE8F8EF),
                                const Color(0xFF15803D),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildStatCard(
                                'Belum',
                                '$remaining',
                                Icons.schedule_rounded,
                                const Color(0xFFFFF4E5),
                                const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // TAHAP 7: CONTEXT.WATCH()
                  // UI mendengarkan perubahan jumlah favorit.

                  Builder(
                    builder: (context) {
                      final FavoritesModel model =
                          context.watch<FavoritesModel>();

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8EC),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Text(
                                  'Materi Favorit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Text(
                                '${model.count}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Materi Pembelajaran',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (courses.isEmpty)
                    const EmptyState()
                  else
                    ...courses.take(3).map(
                          (course) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: buildCourseListTile(course),
                          ),
                        ),

                  const SizedBox(height: 24),
                  buildStudentFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================================================
  // WELCOME BANNER
  // ====================================================

  Widget buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact =
              constraints.maxWidth < 500;

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $studentName!',
                          style: TextStyle(
                            fontSize: compact ? 17 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Selamat datang di dashboard pembelajaranmu.',
                          style: TextStyle(
                            color: Color(0xFFE0E7FF),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'NIM  $studentId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================================================
  // STATISTIC CARD
  // ====================================================

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconBackground,
    Color iconColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // STUDENT FOOTER
  // ====================================================

  Widget buildStudentFooter() {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: primaryColor,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'NIM: $studentId',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // COURSES PAGE
  // ====================================================

  Widget buildCoursesPage(
    List<Map<String, dynamic>> courses,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns =
            constraints.maxWidth >= 1100
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(
            constraints.maxWidth >= 1000 ? 32 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Semua Materi',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih materi untuk melihat detail pembelajaran.',
                    style: TextStyle(color: mutedColor),
                  ),
                  const SizedBox(height: 22),

                  if (courses.isEmpty)
                    const EmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 190,
                      ),
                      itemBuilder: (context, index) {
                        return buildCourseGridCard(
                          courses[index],
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  buildStudentFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================================================
  // COURSE LIST TILE
  // TAHAP 7: CONTEXT.WATCH() DAN CONTEXT.READ()
  // ====================================================

  Widget buildCourseListTile(
    Map<String, dynamic> course,
  ) {
    final String code = courseKey(course);

    return Builder(
      builder: (context) {
        // Watch dipakai karena ikon harus mengikuti perubahan.
        final FavoritesModel model =
            context.watch<FavoritesModel>();

        return CourseListTileWidget(
          course: course,
          isFavorite: model.isFavorite(code),
          onFavoriteChanged: () {
            // Read hanya untuk menjalankan aksi.
            context.read<FavoritesModel>()
                .toggleFavorite(code);

            showMessage(
              model.isFavorite(code)
                  ? 'Materi ditambahkan ke favorit.'
                  : 'Materi dihapus dari favorit.',
            );
          },
          onTap: () {
            openCourse(course);
          },
          onLongPress: () {
            showMessage(
              'Materi: ${course['title']} '
              '(${course['code'] ?? '-'})',
            );
          },
        );
      },
    );
  }

  // ====================================================
  // COURSE GRID CARD
  // TAHAP 7: CONTEXT.WATCH() DAN CONTEXT.READ()
  // ====================================================

  Widget buildCourseGridCard(
    Map<String, dynamic> course,
  ) {
    final String code = courseKey(course);

    return Builder(
      builder: (context) {
        final FavoritesModel model =
            context.watch<FavoritesModel>();

        return CourseGridCardWidget(
          course: course,
          isFavorite: model.isFavorite(code),
          onFavoriteChanged: () {
            final FavoritesModel favorites =
                context.read<FavoritesModel>();

            final bool wasFavorite =
                favorites.isFavorite(code);

            favorites.toggleFavorite(code);

            showMessage(
              wasFavorite
                  ? 'Materi dihapus dari favorit.'
                  : 'Materi ditambahkan ke favorit.',
            );
          },
          onTap: () {
            openCourse(course);
          },
        );
      },
    );
  }

  // ====================================================
  // PROFILE PAGE
  // ====================================================

  Widget buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil Mahasiswa',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informasi mahasiswa dan formulir feedback.',
                style: TextStyle(color: mutedColor),
              ),
              const SizedBox(height: 22),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundImage: AssetImage(
                          'assets/images/foto.didi.jpeg',
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        studentName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'NIM: $studentId',
                        style: TextStyle(color: mutedColor),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pendidikan Teknik Informatika',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Feedback Pembelajaran',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text('Nama Mahasiswa'),
                        const SizedBox(height: 8),
                        const TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.person_outline),
                            hintText: studentName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text('NIM'),
                        const SizedBox(height: 8),
                        const TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.badge_outlined),
                            hintText: studentId,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text('Komentar atau Masukan'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: feedbackController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Tuliskan kesan atau masukan...',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Feedback wajib diisi.';
                            }

                            if (value.trim().length < 5) {
                              return 'Feedback minimal 5 karakter.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isLoading
                                ? null
                                : submitFeedback,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              isLoading
                                  ? 'Mengirim...'
                                  : 'Kirim Feedback',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  // SUBMIT FEEDBACK
  // ====================================================

  Future<void> submitFeedback() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengiriman'),
          content: const Text(
            'Apakah Anda yakin ingin mengirim feedback ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Kirim'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    showMessage(
      'Feedback berhasil dikirim. Terima kasih, $studentName!',
    );

    feedbackController.clear();
  }
}

// ======================================================
// CHILD WIDGET: COURSE LIST TILE
// ======================================================

class CourseListTileWidget extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CourseListTileWidget({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = course['status'] == 'done';

    final String code =
        (course['code'] ?? course['title'] ?? '-')
            .toString();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFE8F8EF)
                      : const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_outline
                      : Icons.menu_book_rounded,
                  color: isDone
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course['title'] ?? 'Materi'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$code • ${course['credits'] ?? '-'} SKS',
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    _buildStatusPill(isDone),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                onPressed: onFavoriteChanged,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? Colors.red : mutedColor,
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isDone) {
    final Color color = isDone
        ? const Color(0xFF15803D)
        : const Color(0xFFB45309);

    final Color background = isDone
        ? const Color(0xFFE8F8EF)
        : const Color(0xFFFFF4E5);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? 'Selesai' : 'Belum selesai',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ======================================================
// CHILD WIDGET: COURSE GRID CARD
// ======================================================

class CourseGridCardWidget extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTap;

  const CourseGridCardWidget({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = course['status'] == 'done';

    final String code =
        (course['code'] ?? course['title'] ?? '-')
            .toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFE8F8EF)
                      : const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_outline
                      : Icons.menu_book_rounded,
                  color: isDone
                      ? const Color(0xFF15803D)
                      : primaryColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course['title'] ?? 'Materi'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode: $code',
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'SKS: ${course['credits'] ?? '-'}',
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDone
                          ? 'Selesai'
                          : 'Belum selesai',
                      style: TextStyle(
                        color: isDone
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                onPressed: onFavoriteChanged,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? Colors.red : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// EMPTY STATE
// ======================================================

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Tidak ada materi tersedia.',
          style: TextStyle(color: mutedColor),
        ),
      ),
    );
  }
}

// ======================================================
// COURSE DETAIL PAGE
// ======================================================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = course['status'] == 'done';

    final String code =
        (course['code'] ?? course['title'] ?? '-')
            .toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFFE8F8EF)
                                : const Color(0xFFEAF2FF),
                            borderRadius:
                                BorderRadius.circular(24),
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check_circle_outline
                                : Icons.menu_book_rounded,
                            color: isDone
                                ? const Color(0xFF15803D)
                                : primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${course['title'] ?? 'Materi'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kode materi: $code',
                          style: const TextStyle(
                            color: mutedColor,
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 20),
                          child: Divider(
                            color: Color(0xFFE8EDF5),
                          ),
                        ),
                        _buildInfoRow('Kode', code),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Bobot SKS',
                          '${course['credits'] ?? '-'} SKS',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Status',
                          isDone ? 'Selesai' : 'Belum selesai',
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 20),
                          child: Divider(
                            color: Color(0xFFE8EDF5),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Identitas Mahasiswa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Nama', studentName),
                        const SizedBox(height: 6),
                        _buildInfoRow('NIM', studentId),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: () {
                    onFavoriteChanged();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite
                        ? 'Hapus dari Favorit'
                        : 'Tambah ke Favorit',
                  ),
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke Materi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: mutedColor),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
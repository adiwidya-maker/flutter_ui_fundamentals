import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String studentName = 'I Gede Adiwidya Utama';
const String studentId = '2415051001';

const Color primaryColor = Color(0xFF2563EB);
const Color pageColor = Color(0xFFF5F7FB);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF64748B);

void main() {
  runApp(const MyApp());
}

// ======================================================
// APPLICATION
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            side: const BorderSide(color: Color(0xFFE8EDF5)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
    );
  }
}

// ======================================================
// MAIN PAGE + INTEGRASI MINI PROJECT (STAGE 15)
// ======================================================

class CourseExplorerPage extends StatefulWidget {
  const CourseExplorerPage({super.key});

  @override
  State<CourseExplorerPage> createState() => _CourseExplorerPageState();
}

class _CourseExplorerPageState extends State<CourseExplorerPage> {
  late Future<Map<String, dynamic>> studentFuture;

  int selectedIndex = 0;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController studyController = TextEditingController(
    text: 'Pendidikan Teknik Informatika',
  );

  final TextEditingController addressController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  // Form & Feedback State (Stage 13 & 14)
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController feedbackController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  void dispose() {
    emailController.dispose();
    studyController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> loadStudentData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/student_data.json');

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> getCourses(
    Map<String, dynamic> data,
  ) {
    final rawCourses = data['courses'] as List<dynamic>? ?? [];

    return rawCourses.whereType<Map<String, dynamic>>().toList();
  }

  int getCompletedCount(
    List<Map<String, dynamic>> courses,
  ) {
    return courses.where((course) => course['status'] == 'done').length;
  }

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

  // Passing data & returning result (Stage 8 & 9)
  Future<void> openCourse(
    Map<String, dynamic> course,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(course: course),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      showMessage('Materi berhasil ditambahkan ke favorit.');
    }
  }

  // NavigationBar untuk Compact / Medium layout (Stage 10 & 11)
  Widget buildNavigationBar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
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

  // NavigationRail untuk Expanded layout (Stage 11)
  Widget buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                          studentFuture = loadStudentData();
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

        final data = snapshot.data ?? {};
        final courses = getCourses(data);
        final completed = getCompletedCount(courses);

        final pages = [
          buildHomePage(courses, completed),
          buildCoursesPage(courses),
          buildProfilePage(),
        ];

        // Adaptive Navigation Shell (Stage 11 & 15)
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool expanded = constraints.maxWidth >= 840;

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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                          style: TextStyle(color: mutedColor),
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
              bottomNavigationBar: expanded ? null : buildNavigationBar(),
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
    final remaining = courses.length - completed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 700;

        final double horizontalPadding =
            constraints.maxWidth >= 1000 ? 36 : 20;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildWelcomeBanner(),
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
                          setState(() => selectedIndex = 1);
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
                            padding: const EdgeInsets.only(bottom: 12),
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
          final bool compact = constraints.maxWidth < 500;

          return Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Icon(icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget buildStudentFooter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: $studentId',
                    style: const TextStyle(
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
  // COURSES PAGE - RESPONSIVE GRID (STAGE 5)
  // ====================================================

  Widget buildCoursesPage(
    List<Map<String, dynamic>> courses,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 1100
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 190,
                      ),
                      itemBuilder: (context, index) {
                        return buildCourseGridCard(courses[index]);
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

  Widget buildCourseListTile(
    Map<String, dynamic> course,
  ) {
    final bool isDone = course['status'] == 'done';
    bool isFavorite = course['isFavorite'] ?? false;

    return StatefulBuilder(
      builder: (context, setStateCard) {
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => openCourse(course),
            onLongPress: () {
              showMessage('Materi: ${course['title']} (${course['code'] ?? '-'})');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  buildCourseIcon(isDone),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          '${course['code'] ?? '-'} • ${course['credits'] ?? '-'} SKS',
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 9),
                        buildStatusPill(isDone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : mutedColor,
                    ),
                    onPressed: () {
                      setStateCard(() {
                        isFavorite = !isFavorite;
                        course['isFavorite'] = isFavorite;
                      });
                      showMessage(
                        isFavorite
                            ? 'Ditambahkan ke favorit lokal.'
                            : 'Dihapus dari favorit.',
                      );
                    },
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
      },
    );
  }

  Widget buildCourseGridCard(
    Map<String, dynamic> course,
  ) {
    final bool isDone = course['status'] == 'done';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCourse(course),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCourseIcon(isDone),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course['title'] ?? 'Materi'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode: ${course['code'] ?? '-'}',
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
                    const Spacer(),
                    buildStatusPill(isDone),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCourseIcon(bool isDone) {
    return Container(
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
    );
  }

  Widget buildStatusPill(bool isDone) {
    final color = isDone
        ? const Color(0xFF15803D)
        : const Color(0xFFB45309);

    final background = isDone
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

  // ====================================================
  // PROFILE PAGE - FORM, VALIDATION & DIALOG (STAGE 13 & 14)
  // ====================================================

  Widget buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Informasi mahasiswa dan formulir profil.',
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
                      Text(
                        studentName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'NIM: $studentId',
                        style: const TextStyle(color: mutedColor),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Formulir Feedback & Konfirmasi',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Nama Mahasiswa'),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          initialValue: studentName,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('NIM'),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          initialValue: studentId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Komentar / Feedback Pembelajaran'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: feedbackController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Tuliskan kesan atau masukan materi...',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Icon(Icons.comment_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Feedback wajib diisi.';
                            }
                            if (value.trim().length < 5) {
                              return 'Feedback minimal harus 5 karakter.';
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
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      final bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Konfirmasi Pengiriman'),
                                          content: const Text(
                                            'Apakah Anda yakin ingin mengirim feedback pembelajaran ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Batal'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Ya, Kirim'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        setState(() => isLoading = true);
                                        await Future.delayed(
                                          const Duration(seconds: 2),
                                        );
                                        if (!mounted) return;
                                        setState(() => isLoading = false);

                                        showMessage(
                                          'Feedback berhasil dikirim. Terima kasih, $studentName!',
                                        );
                                        feedbackController.clear();
                                      }
                                    }
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              isLoading ? 'Mengirim...' : 'Kirim Feedback',
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
}

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
// COURSE DETAIL PAGE (STAGE 8 & 9)
// ======================================================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = course['status'] == 'done';

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            borderRadius: BorderRadius.circular(24),
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
                          'Kode materi: ${course['code'] ?? '-'}',
                          style: const TextStyle(color: mutedColor),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xFFE8EDF5)),
                        ),
                        _buildInfoRow('Kode', '${course['code'] ?? '-'}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            'Bobot SKS', '${course['credits'] ?? '-'} SKS'),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            'Status', isDone ? 'Selesai' : 'Belum selesai'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xFFE8EDF5)),
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
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Tambah ke Favorit'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: mutedColor)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
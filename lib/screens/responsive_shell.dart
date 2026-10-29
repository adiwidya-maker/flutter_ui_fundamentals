import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/course_provider.dart';
import '../widgets/error_view.dart';
import 'course_form_page.dart';
import 'course_list_page.dart';
import 'favorites_page.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int selectedIndex = 0;

  static const List<(IconData, IconData, String)> _items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Courses'),
    (Icons.favorite_outline, Icons.favorite, 'Favorites'),
  ];

  void _select(int index) => setState(() => selectedIndex = index);

  Widget _addButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CourseFormPage()),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Tambah'),
    );
  }

  // Scaffold untuk state loading / error / empty.
  // Nama & NIM tetap tampil agar valid sebagai bukti screenshot.
  Widget _stateScaffold(Widget child, {Widget? floatingActionButton}) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer v2')),
      floatingActionButton: floatingActionButton,
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
    final provider = context.watch<CourseProvider>();

    // 1. LOADING
    if (provider.isLoading) {
      return _stateScaffold(const Center(child: CircularProgressIndicator()));
    }

    // 2. ERROR + Retry
    if (provider.error != null) {
      return _stateScaffold(
        ErrorView(message: provider.error!, onRetry: provider.loadCourses),
      );
    }

    // 3. EMPTY
    if (provider.courses.isEmpty) {
      return _stateScaffold(
        const Center(child: Text('Data course belum tersedia')),
        floatingActionButton: _addButton(),
      );
    }

    // 4. SUCCESS
    final pages = <Widget>[
      _HomeTab(
        total: provider.courses.length,
        onSeeCourses: () => _select(1),
      ),
      const CourseListPage(),
      const FavoritesPage(),
    ];
    final content = IndexedStack(index: selectedIndex, children: pages);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Course Explorer v2'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: provider.loadCourses,
              ),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: _select,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final item in _items)
                          NavigationRailDestination(
                            icon: Icon(item.$1),
                            selectedIcon: Icon(item.$2),
                            label: Text(item.$3),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                )
              : content,
          floatingActionButton: _addButton(),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final item in _items)
                      NavigationDestination(
                        icon: Icon(item.$1),
                        selectedIcon: Icon(item.$2),
                        label: item.$3,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

// Tab Home / dashboard
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.total, required this.onSeeCourses});

  final int total;
  final VoidCallback onSeeCourses;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
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
                        _pill('NIM : $studentId'),
                        const SizedBox(width: 10),
                        _pill('Semester 5'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Total Materi Tersedia: $total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onSeeCourses,
                icon: const Icon(Icons.menu_book),
                label: const Text('Lihat Daftar Materi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
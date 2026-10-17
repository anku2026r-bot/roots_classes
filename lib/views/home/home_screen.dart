import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/classes_controller.dart';
import '../../controllers/test_series_controller.dart';
import '../auth/login_screen.dart';
import '../classes/classes_screen.dart';
import '../classes/class_detail_screen.dart';
import '../test_series/test_series_screen.dart';
import '../test_series/test_result_screen.dart';
import 'package:flutter/services.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_logo.dart';
import '../widgets/bouncing_pressable.dart';
import 'home_view.dart';
import '../profile/student_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../counseling/academic_counseling_screen.dart';
import '../../core/utils/app_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<HomeViewState> _homeViewKey = GlobalKey<HomeViewState>();
  int _selectedTabIndex = 0;


  void _showNotificationsModal(BuildContext context) {
    AppNavigator.push(context, const NotificationsScreen());

  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      HomeView(
        key: _homeViewKey,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onNavigateTab: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      const ClassesScreen(),
      const TestSeriesScreen(),
      const _MyLearningsView(),
      const _ProfileView(),
    ];

    final List<String> titles = [
      'Home',
      'Classes & Batches',
      'Test Series',
      'My Learnings',
      'My Profile',
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onNavigateTab: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Open Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: _selectedTabIndex == 0
            ? Row(
                children: [
                  const AppLogo(iconSize: 32, showTagline: false, isCompact: true),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Roots Classes',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'Ludhiana • Premier Institute',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  const AppLogo(iconSize: 32, showTagline: false, isCompact: true),
                  const SizedBox(width: 10),
                  Text(
                    titles[_selectedTabIndex],
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                ],
              ),
        actions: [
          // RSAT Scholarship Badge Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: BouncingPressable(
              onTap: () => AppNavigator.push(context, const AcademicCounselingScreen()),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      'RSAT 100%',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Notification Bell
          IconButton(
            tooltip: 'Announcements',
            icon: const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, size: 22),
                Positioned(
                  top: -1,
                  right: -1,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
            onPressed: () => _showNotificationsModal(context),
          ),

          if (_selectedTabIndex == 4)
            IconButton(
              tooltip: 'Sign Out',
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: () => _ProfileView.showLogoutConfirmation(context),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedTabIndex = index;
          });
        },
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded, color: AppColors.primary),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: 'Test Series',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary),
            label: 'My Learnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _MyLearningsView extends StatelessWidget {
  const _MyLearningsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classesController = context.watch<ClassesController>();
    final testSeriesController = context.watch<TestSeriesController>();

    final enrolledClasses = classesController.classes.where((c) => c.isEnrolled).toList();
    final attemptedTests = testSeriesController.userAttempts;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            dividerHeight: 0,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'Enrolled Batches (${enrolledClasses.length})'),
              Tab(text: 'Attempted Tests (${attemptedTests.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Enrolled Classes Tab with Pull-To-Refresh
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await Future.wait([
                      context.read<ClassesController>().fetchClasses(),
                      Future.delayed(const Duration(milliseconds: 350)),
                    ]);
                  },
                  child: enrolledClasses.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No enrolled batches yet.',
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Enroll in any live or recorded batch from the Classes tab.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: enrolledClasses.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = enrolledClasses[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary),
                                ),
                                title: Text(
                                  item.title,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${item.educator.name} • ${item.validity}',
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ClassDetailScreen(classId: item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),

                // Attempted Tests Tab with Pull-To-Refresh
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await Future.wait([
                      context.read<TestSeriesController>().fetchTestSeries(),
                      Future.delayed(const Duration(milliseconds: 350)),
                    ]);
                  },
                  child: attemptedTests.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No test history available.',
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Take any mock test to analyze your speed, accuracy, and All India Rank.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: attemptedTests.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final att = attemptedTests[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.successLight,
                                  child: const Icon(Icons.quiz_rounded, color: AppColors.success),
                                ),
                                title: Text(
                                  att.testTitle,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Score: ${att.totalScore.toInt()}/${att.maxMarks} • Accuracy: ${att.accuracyPercentage}%',
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TestResultScreen(result: att),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.logoutConfirmTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppStrings.logoutConfirmMessage,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthController>();
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const StudentProfileScreen();
  }
}

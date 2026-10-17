import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_constants.dart';
import '../../controllers/test_series_controller.dart';
import '../../models/test_series_model.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_badge.dart';
import 'test_detail_screen.dart';
import 'test_result_screen.dart';
import '../enrollment/course_enrollment_screen.dart';
import '../../core/utils/app_navigator.dart';

class TestSeriesScreen extends StatefulWidget {
  const TestSeriesScreen({super.key});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestSeriesController>().fetchTestSeries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showUnlockDialog(BuildContext context, TestSeriesModel item) {
    AppNavigator.push(context, CourseEnrollmentScreen(testSeriesItem: item));
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TestSeriesController>();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            controller.fetchTestSeries(),
            Future.delayed(const Duration(milliseconds: 350)),
          ]);
        },
        child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    CustomSearchBar(
                      hintText: 'Search mock tests and exam series...',
                      onChanged: (q) => controller.setSearchQuery(q),
                    ),
                    const SizedBox(height: 12),
                    CategoryFilterBar(
                      categories: ApiConstants.categories,
                      selectedCategory: controller.selectedCategory,
                      onSelected: (cat) => controller.setCategory(cat),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Available Series (${controller.testSeriesList.length})'),
                    Tab(text: 'Attempted Tests (${controller.userAttempts.length})'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Series Catalog
            _buildCatalogTab(controller, isDark),
            // Attempts History
            _buildAttemptsTab(controller, isDark),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildCatalogTab(TestSeriesController controller, bool isDark) {
    if (controller.isLoading && controller.testSeriesList.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, _) => const SkeletonCard(height: 200),
      );
    }

    if (controller.errorMessage != null && controller.testSeriesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(controller.errorMessage!, style: GoogleFonts.outfit()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.fetchTestSeries(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.testSeriesList.isEmpty) {
      return Center(
        child: Text(
          'No test series found.',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: controller.testSeriesList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = controller.testSeriesList[index];
        return _buildTestSeriesCard(context, item, isDark);
      },
    );
  }

  Widget _buildTestSeriesCard(BuildContext context, TestSeriesModel item, bool isDark) {
    final canAccess = item.canAccess;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TestDetailScreen(testSeriesId: item.id)),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(label: item.category, type: BadgeType.category),
                  if (item.isPurchased)
                    const StatusBadge(label: 'Purchased', type: BadgeType.purchased)
                  else if (item.isFree)
                    const StatusBadge(label: 'Free Access', type: BadgeType.free)
                  else
                    StatusBadge(label: 'Locked', type: BadgeType.locked),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                item.title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Exam metrics pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetricPill(Icons.assignment_outlined, '${item.numberOfTests} Mock Tests', isDark),
                  _buildMetricPill(Icons.help_outline_rounded, '${item.totalQuestions} Questions', isDark),
                  _buildMetricPill(Icons.timer_outlined, '${item.durationMinutes} Mins', isDark),
                  _buildMetricPill(Icons.star_outline_rounded, '${item.totalMarks} Marks', isDark),
                  _buildMetricPill(Icons.remove_circle_outline_rounded, '-${item.negativeMarking} Neg Marking', isDark),
                ],
              ),
              const Divider(height: 24),

              // Price and CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Full Access Package',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          item.isFree ? 'FREE' : '₹${item.price.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: item.isFree ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (canAccess) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TestDetailScreen(testSeriesId: item.id)),
                            );
                          } else {
                            _showUnlockDialog(context, item);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAccess ? AppColors.primary : AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          canAccess ? 'View Tests' : 'Unlock Series',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsTab(TestSeriesController controller, bool isDark) {
    if (controller.userAttempts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_edu_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No tests attempted yet.',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start any test in the catalog to see real-time scores and ranking.',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.userAttempts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final attempt = controller.userAttempts[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        attempt.testTitle,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Score: ${attempt.totalScore.toInt()} / ${attempt.maxMarks}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Accuracy: ${attempt.accuracyPercentage}%',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    Text(
                      'AIR Rank: #${attempt.rank} (Top ${(100 - attempt.percentile).toStringAsFixed(1)}%)',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TestResultScreen(result: attempt),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Detailed Solutions & Analytics'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

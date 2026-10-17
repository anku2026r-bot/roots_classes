import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/test_series_controller.dart';
import '../../models/test_series_model.dart';
import '../widgets/status_badge.dart';
import 'test_instructions_screen.dart';
import '../../core/utils/app_navigator.dart';

class TestDetailScreen extends StatelessWidget {
  final String testSeriesId;

  const TestDetailScreen({super.key, required this.testSeriesId});

  TestSeriesModel? _findSeries(TestSeriesController controller) {
    try {
      return controller.testSeriesList.firstWhere((t) => t.id == testSeriesId);
    } catch (_) {
      return controller.testSeriesList.isNotEmpty ? controller.testSeriesList.first : null;
    }
  }

  void _confirmStartTest(BuildContext context, TestItemModel test) {
    AppNavigator.push(context, TestInstructionsScreen(test: test));
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TestSeriesController>();
    final series = _findSeries(controller);

    if (series == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          series.title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh Test Series',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing tests...'),
                  duration: Duration(milliseconds: 600),
                ),
              );
              await Future.wait([
                controller.fetchTestSeries(),
                Future.delayed(const Duration(milliseconds: 350)),
              ]);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            controller.fetchTestSeries(),
            Future.delayed(const Duration(milliseconds: 350)),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Series Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(label: series.category, type: BadgeType.category),
                  const SizedBox(height: 10),
                  Text(
                    series.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    series.description,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tests in Bundle Title
            Text(
              'Tests Included in Series (${series.tests.length})',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // List of Tests
            if (series.tests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No tests scheduled yet in this bundle.',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: series.tests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final test = series.tests[index];
                  final canTake = test.isFree || series.canAccess;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test.title,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${test.totalQuestions} Questions • ${test.durationMinutes} mins • ${test.totalMarks} Marks',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (test.isFree)
                                const StatusBadge(label: 'Free Test', type: BadgeType.free)
                              else
                                const StatusBadge(label: 'Premium', type: BadgeType.locked),
                              ElevatedButton.icon(
                                onPressed: canTake
                                    ? () => _confirmStartTest(context, test)
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please unlock the test series first.'),
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  canTake ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
                                  size: 16,
                                ),
                                label: Text(canTake ? 'Start Test' : 'Locked'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canTake ? AppColors.primary : Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ),
  );
  }
}

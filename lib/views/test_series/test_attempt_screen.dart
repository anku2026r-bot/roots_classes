import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/test_series_controller.dart';
import 'test_result_screen.dart';

class TestAttemptScreen extends StatelessWidget {
  const TestAttemptScreen({super.key});

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    final String mm = m < 10 ? '0$m' : '$m';
    final String ss = s < 10 ? '0$s' : '$s';
    return '$mm:$ss';
  }

  void _showSubmitConfirmation(BuildContext context) {
    final controller = context.read<TestSeriesController>();
    final totalQ = controller.activeQuestions.length;
    final answered = controller.userAnswers.length;
    final marked = controller.markedForReview.length;
    final unattempted = totalQ - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Submit Test Paper?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to finish the examination? You will not be able to change your answers.',
              style: GoogleFonts.outfit(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            _buildSummaryRow('Total Questions:', '$totalQ'),
            _buildSummaryRow('Answered:', '$answered', color: AppColors.success),
            _buildSummaryRow('Marked for Review:', '$marked', color: AppColors.warning),
            _buildSummaryRow('Unattempted:', '$unattempted', color: AppColors.error),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Test'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await controller.submitExam();
              if (context.mounted && result != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TestResultScreen(result: result)),
                );
              }
            },
            child: const Text('Final Submit'),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TestSeriesController>();
    final currentQ = controller.currentQuestion;
    final questions = controller.activeQuestions;
    final activeTest = controller.activeTest;

    if (currentQ == null || questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex = controller.currentQuestionIndex;
    final selectedOption = controller.userAnswers[currentQ.id];
    final isMarked = controller.markedForReview.contains(currentQ.id);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showSubmitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 1,
          title: Text(
            activeTest?.title ?? 'CBT Examination',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Timer Badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: controller.remainingTimeSeconds < 300
                    ? AppColors.errorLight
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 16,
                    color: controller.remainingTimeSeconds < 300
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(controller.remainingTimeSeconds),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: controller.remainingTimeSeconds < 300
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Question Palette Drawer button
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'Question Palette',
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: _buildPaletteDrawer(context, controller, isDark),
        body: Column(
          children: [
            // Question Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentQ.section,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '+${currentQ.marksPositive.toInt()} / -${currentQ.marksNegative.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Question Content & Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    Text(
                      currentQ.questionText,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentQ.options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, optIdx) {
                        final option = currentQ.options[optIdx];
                        final isSelected = selectedOption == optIdx;

                        return InkWell(
                          onTap: () {
                            controller.selectAnswer(currentQ.id, optIdx);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : (isDark ? AppColors.surfaceDark : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                                  child: Text(
                                    option.label,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Clear Response & Review Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedOption != null)
                          TextButton.icon(
                            onPressed: () => controller.clearAnswer(currentQ.id),
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            label: const Text('Clear Response'),
                          )
                        else
                          const SizedBox.shrink(),
                        TextButton.icon(
                          onPressed: () => controller.toggleMarkForReview(currentQ.id),
                          icon: Icon(
                            isMarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isMarked ? AppColors.warning : null,
                            size: 18,
                          ),
                          label: Text(
                            isMarked ? 'Marked for Review' : 'Mark for Review',
                            style: GoogleFonts.outfit(
                              color: isMarked ? AppColors.warning : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    OutlinedButton(
                      onPressed: currentIndex > 0 ? () => controller.previousQuestion() : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Previous'),
                    ),

                    // Submit Test Button
                    ElevatedButton(
                      onPressed: () => _showSubmitConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Submit Paper'),
                    ),

                    // Next / Save & Next Button
                    ElevatedButton(
                      onPressed: currentIndex < questions.length - 1
                          ? () => controller.nextQuestion()
                          : () => _showSubmitConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(currentIndex < questions.length - 1 ? 'Save & Next' : 'Finish'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteDrawer(
    BuildContext context,
    TestSeriesController controller,
    bool isDark,
  ) {
    final questions = controller.activeQuestions;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question Navigation Palette',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegendItem('Answered', AppColors.success),
                  _buildLegendItem('Review', AppColors.warning),
                  _buildLegendItem('Not Visited', Colors.grey.shade400),
                ],
              ),
              const Divider(height: 24),
              // Grid of question numbers
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, idx) {
                    final q = questions[idx];
                    final isAnswered = controller.userAnswers.containsKey(q.id);
                    final isMarked = controller.markedForReview.contains(q.id);
                    final isCurrent = controller.currentQuestionIndex == idx;

                    Color bg = Colors.grey.shade300;
                    Color fg = Colors.black87;

                    if (isAnswered) {
                      bg = AppColors.success;
                      fg = Colors.white;
                    } else if (isMarked) {
                      bg = AppColors.warning;
                      fg = Colors.white;
                    }

                    return InkWell(
                      onTap: () {
                        controller.goToQuestion(idx);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrent
                              ? Border.all(color: AppColors.primary, width: 2.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: fg,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 11)),
      ],
    );
  }
}

class SliverSimpleGridDelegateWithFixedCrossAxisCount
    extends SliverGridDelegateWithFixedCrossAxisCount {
  const SliverSimpleGridDelegateWithFixedCrossAxisCount({
    required super.crossAxisCount,
  });
}

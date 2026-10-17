import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/test_attempt_model.dart';

class TestResultScreen extends StatelessWidget {
  final TestResultModel result;

  const TestResultScreen({super.key, required this.result});

  String _formatDuration(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Performance Scorecard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Summary Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    result.testTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Big Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${result.totalScore.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' / ${result.maxMarks}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Score metrics badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryMetric('Accuracy', '${result.accuracyPercentage}%'),
                      _buildSummaryMetric('All India Rank', '#${result.rank}'),
                      _buildSummaryMetric('Percentile', '${result.percentile}%'),
                      _buildSummaryMetric('Time Taken', _formatDuration(result.timeTakenSeconds)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Breakdown counters row
            Row(
              children: [
                Expanded(
                  child: _buildCountCard(
                    'Correct',
                    '${result.correctCount}',
                    AppColors.success,
                    Icons.check_circle_rounded,
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCountCard(
                    'Incorrect',
                    '${result.incorrectCount}',
                    AppColors.error,
                    Icons.cancel_rounded,
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCountCard(
                    'Unattempted',
                    '${result.unattemptedCount}',
                    Colors.grey,
                    Icons.help_rounded,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question-by-Question Section
            Text(
              'Detailed Question Analysis & Explanations',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.questionsAnalysis.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final qa = result.questionsAnalysis[index];
                return _buildQuestionAnalysisCard(qa, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCountCard(
    String label,
    String count,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysisCard(QuestionAnalysisModel qa, bool isDark) {
    Color statusColor;
    String statusLabel;

    if (!qa.isAttempted) {
      statusColor = Colors.grey;
      statusLabel = 'Unattempted (0 Marks)';
    } else if (qa.isCorrect) {
      statusColor = AppColors.success;
      statusLabel = 'Correct (+${qa.marksAwarded.toInt()} Marks)';
    } else {
      statusColor = AppColors.error;
      statusLabel = 'Incorrect (${qa.marksAwarded.toInt()} Marks)';
    }

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Q${qa.questionNumber} • ${qa.section}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Question Text
            Text(
              qa.questionText,
              style: GoogleFonts.outfit(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Options summary
            Column(
              children: List.generate(qa.optionTexts.length, (optIdx) {
                final isSelected = qa.selectedOptionIndex == optIdx;
                final isCorrectOption = qa.correctOptionIndex == optIdx;

                Color? optBg;
                Color optBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

                if (isCorrectOption) {
                  optBg = AppColors.successLight;
                  optBorder = AppColors.success;
                } else if (isSelected && !qa.isCorrect) {
                  optBg = AppColors.errorLight;
                  optBorder = AppColors.error;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: optBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: optBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        String.fromCharCode(65 + optIdx),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          qa.optionTexts[optIdx],
                          style: GoogleFonts.outfit(fontSize: 13),
                        ),
                      ),
                      if (isCorrectOption)
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16)
                      else if (isSelected && !qa.isCorrect)
                        const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Explanation box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.amber.shade800),
                      const SizedBox(width: 6),
                      Text(
                        'Explanation & Concept Solution:',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    qa.explanation,
                    style: GoogleFonts.outfit(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/test_series_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../../models/test_series_model.dart';
import 'test_attempt_screen.dart';

class TestInstructionsScreen extends StatefulWidget {
  final TestItemModel test;

  const TestInstructionsScreen({
    super.key,
    required this.test,
  });

  @override
  State<TestInstructionsScreen> createState() => _TestInstructionsScreenState();
}

class _TestInstructionsScreenState extends State<TestInstructionsScreen> {
  bool _agreedToRules = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final test = widget.test;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Examination Instructions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppColors.primary, const Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROOTS ALL-INDIA TEST SERIES',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF93C5FD),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      test.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatChip(Icons.access_time_rounded, '${test.durationMinutes} Mins'),
                        const SizedBox(width: 8),
                        _buildStatChip(Icons.help_outline_rounded, '${test.totalQuestions} Questions'),
                        const SizedBox(width: 8),
                        _buildStatChip(Icons.star_rounded, '${test.totalMarks} Marks'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Marking Scheme & Pattern', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildRow('Correct Answer', '+4.00 Marks', AppColors.success),
                    const Divider(height: 16),
                    _buildRow('Wrong / Incorrect Answer', '-${test.negativeMarking} Marks', AppColors.error),
                    const Divider(height: 16),
                    _buildRow('Unattempted Question', '0.00 Marks', Colors.grey),
                    const Divider(height: 16),
                    _buildRow('Passing Criterion', '${test.passingMarks} Marks', AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Important Examination Rules', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildRule(1, 'Timer will start immediately once you press Begin Examination. The clock does not pause.'),
              _buildRule(2, 'Do NOT switch tabs or minimize the app. Doing so may trigger auto-submission.'),
              _buildRule(3, 'You can mark questions for review and navigate between questions using the Question Palette.'),
              _buildRule(4, 'Your responses are saved in real-time. Click Submit Test Paper only when you have completed all sections.'),
              const SizedBox(height: 24),

              // Agreement Checkbox
              InkWell(
                onTap: () => setState(() => _agreedToRules = !_agreedToRules),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _agreedToRules
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _agreedToRules ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreedToRules,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _agreedToRules = v ?? false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'I have read all examination rules and agree to take the test in strict test environment.',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Begin Examination Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _agreedToRules
                      ? () async {
                          final controller = context.read<TestSeriesController>();
                          await controller.startExam(widget.test);
                          if (context.mounted) {
                            AppNavigator.pushReplacement(
                              context,
                              const TestAttemptScreen(),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    'Begin Examination Now →',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13)),
        Text(value, style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: valColor)),
      ],
    );
  }

  Widget _buildRule(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../home/home_screen.dart';
import '../../core/utils/app_navigator.dart';

class EmailVerificationHelpScreen extends StatefulWidget {
  const EmailVerificationHelpScreen({super.key});

  @override
  State<EmailVerificationHelpScreen> createState() => _EmailVerificationHelpScreenState();
}

class _EmailVerificationHelpScreenState extends State<EmailVerificationHelpScreen> {
  bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final email = auth.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Verification Status',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verification Incomplete',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your registered email address:\n$email\nhas not yet been confirmed.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Checklist & Tips
              Text(
                'Troubleshooting Checklist',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildCheckItem(
                icon: Icons.mark_email_read_outlined,
                title: 'Check Spam or Junk Folder',
                desc: 'Verification links can sometimes land in spam or promotions tabs.',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                icon: Icons.timer_outlined,
                title: 'Code Validity',
                desc: 'The 6-digit confirmation code remains active for 15 minutes.',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                icon: Icons.spellcheck_rounded,
                title: 'Verify Spelling',
                desc: 'Make sure your entered email address has no typographical errors.',
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              CustomButton(
                text: 'Simulate Email Link Click (Instant Verify)',
                isLoading: _isSimulating,
                backgroundColor: AppColors.accent,
                onPressed: () async {
                  setState(() => _isSimulating = true);
                  final success = await auth.verifyEmail(code: '');
                  setState(() => _isSimulating = false);
                  if (context.mounted && success) {
                    AppNavigator.pushAndRemoveUntil(
                      context,
                      const HomeScreen(),
                    );

                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => AppNavigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back to Code Entry',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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

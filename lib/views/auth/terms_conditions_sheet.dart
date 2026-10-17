import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

import '../legal/privacy_policy_screen.dart';
import '../legal/terms_conditions_screen.dart';
import '../../core/utils/app_navigator.dart';

class TermsConditionsSheet extends StatelessWidget {
  final bool isPrivacyPolicy;

  const TermsConditionsSheet({
    super.key,
    this.isPrivacyPolicy = false,
  });

  static void show(BuildContext context, {bool isPrivacyPolicy = false}) {
    AppNavigator.push(
      context,
      isPrivacyPolicy ? const PrivacyPolicyScreen() : const TermsConditionsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service';

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isPrivacyPolicy
                  ? _buildPrivacyContent(isDark)
                  : _buildTermsContent(isDark),
            ),
          ),
          // Accept Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'I Understand & Close',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. Educational Services', isDark),
        _buildParagraph(
          'Roots Classes provides educational curriculum, mock tests, video lessons, and interactive tutoring. By enrolling and creating an account, you agree to access content solely for non-commercial educational purposes.',
          isDark,
        ),
        _buildSectionHeader('2. Account Integrity & Security', isDark),
        _buildParagraph(
          'You are responsible for maintaining the confidentiality of your login credentials. Sharing accounts or attempting unauthorized access to teacher assessments or protected batches is strictly prohibited.',
          isDark,
        ),
        _buildSectionHeader('3. Code of Conduct', isDark),
        _buildParagraph(
          'Students and faculty must treat one another with mutual respect in discussion forums, live classrooms, and feedback portals. Any abusive, harassing, or spammy conduct will result in account suspension.',
          isDark,
        ),
        _buildSectionHeader('4. Intellectual Property', isDark),
        _buildParagraph(
          'All lecture materials, notes, test series, and design assets are the exclusive intellectual property of Roots Classes.',
          isDark,
        ),
      ],
    );
  }

  Widget _buildPrivacyContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. Data We Collect', isDark),
        _buildParagraph(
          'Roots Classes collects your full name, email address, password hash, device identifiers, and academic progress data to provide a personalized learning journey.',
          isDark,
        ),
        _buildSectionHeader('2. How We Use Information', isDark),
        _buildParagraph(
          'Your information is used strictly to authenticate you, secure your student profile, deliver course updates, and provide academic support.',
          isDark,
        ),
        _buildSectionHeader('3. Data Security & Cryptography', isDark),
        _buildParagraph(
          'All passwords are salted and cryptographically hashed using standard cryptographic algorithms. Plaintext passwords are never saved or exposed.',
          isDark,
        ),
        _buildSectionHeader('4. Third-Party Sharing', isDark),
        _buildParagraph(
          'We do not sell your personal data to marketing vendors. Academic records remain private between you and your instructors.',
          isDark,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        height: 1.5,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}

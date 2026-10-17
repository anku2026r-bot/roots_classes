import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Terms',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing terms of service...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roots Classes Terms & Conditions',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Last Updated: January 2025 • Official Student Policy',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _buildSection(
                '1. Acceptance of Terms',
                'By accessing or registering with Roots Classes (Roots Coaching Institute, Ludhiana), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our app or enrolled services.',
                isDark,
              ),
              _buildSection(
                '2. Course Access & Content Licensing',
                'All study materials, video lectures, test series, DPPs, and problem solutions provided in this application are the copyrighted property of Roots Classes. Students are granted a non-transferable, single-user license solely for personal educational use.',
                isDark,
              ),
              _buildSection(
                '3. Student Account Security',
                'You are responsible for safeguarding your login credentials. Sharing accounts, recording lectures, or distributing copyrighted PDF question papers will result in immediate termination of account access without refund.',
                isDark,
              ),
              _buildSection(
                '4. Tuition Fees, RSAT Scholarships & Refunds',
                'All fees paid for online or offline classroom courses are strictly subject to Roots Classes enrollment guidelines. Scholarship waivers awarded through RSAT are non-transferable and applicable exclusively to the recipient student.',
                isDark,
              ),
              _buildSection(
                '5. Online Test Conduct & Honor Code',
                'Students appearing for all-India mock test series must adhere to the examination rules. Unfair means or multi-device attempts will invalidate predicted rank and analytics certificates.',
                isDark,
              ),
              _buildSection(
                '6. Governing Law & Contact Jurisdiction',
                'These terms are governed by the laws of India. Any disputes are subject to the exclusive jurisdiction of the competent courts in Ludhiana, Punjab.',
                isDark,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Roots Classes • Gill Rd, Ludhiana • rootsclasses1313@gmail.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : Colors.grey.shade800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

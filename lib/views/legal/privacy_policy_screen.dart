import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Policy',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing privacy policy...'), duration: Duration(milliseconds: 600)),
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
                'Roots Classes Privacy Policy',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'How we collect, protect, and respect your academic data',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _buildSection(
                '1. Information We Collect',
                'We collect student personal information necessary for academic enrollment, including full name, email address, mobile number, current class, competitive target (JEE/NEET/Boards), and test performance scores.',
                isDark,
              ),
              _buildSection(
                '2. How We Use Student Data',
                'Your information is used solely to:\n• Provide online video lectures and personalized test analysis\n• Send crucial batch schedules, admit card notifications, and exam alerts\n• Share academic progress reports with parents or guardians\n• Verify fee receipts and scholarship eligibility.',
                isDark,
              ),
              _buildSection(
                '3. Non-Disclosure & Data Security',
                'Roots Classes maintains strict data confidentiality. We do NOT sell, rent, or trade your student phone numbers or contact details to third-party marketing companies.',
                isDark,
              ),
              _buildSection(
                '4. Payment Security',
                'All fee transactions are processed through RBI-approved encrypted payment gateways (such as Razorpay). We never store your credit card CVV, netbanking passwords, or UPI PINs.',
                isDark,
              ),
              _buildSection(
                '5. Account Rights & Deletion',
                'Students may request updates or deletion of their account records at any time by contacting us at rootsclasses1313@gmail.com.',
                isDark,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Roots Coaching Institute • Ludhiana, Punjab • rootsclasses1313@gmail.com',
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_navigator.dart';
import '../../about/about_us_screen.dart';
import '../../classes/classes_screen.dart';
import '../../test_series/test_series_screen.dart';
import '../../doubts/ask_doubt_screen.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    final features = [
      _FeatureData(
        number: '01',
        title: 'Expert Faculty',
        subtitle: 'Learn from IIT, AIIMS alumni & top pedagogues with 10+ years of proven academic success.',
        icon: Icons.school_rounded,
        color: const Color(0xFF2563EB),
      ),
      _FeatureData(
        number: '02',
        title: 'Live & Recorded Classes',
        subtitle: 'Interactive live sessions with doubt clearance plus lifetime recorded lecture archives anytime.',
        icon: Icons.videocam_rounded,
        color: const Color(0xFF10B981),
      ),
      _FeatureData(
        number: '03',
        title: 'Regular Test Series',
        subtitle: 'Weekly chapter-wise tests, full-length all-India mock exams & AI-backed performance analytics.',
        icon: Icons.quiz_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _FeatureData(
        number: '04',
        title: 'Personal Doubt Sessions',
        subtitle: '1-on-1 personalized mentorship, dedicated WhatsApp group support, and daily doubt clearance counters.',
        icon: Icons.support_agent_rounded,
        color: const Color(0xFFEF4444),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Tag
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'WHY ROOTS CLASSES',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Everything You Need to Crack Your Exam',
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 27 : (isTablet ? 24 : 22.5),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We combine top-tier pedagogy, continuous assessment, and personal guidance to ensure guaranteed rank improvement.',
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // 4-Column or 2-Column Responsive Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: isDesktop ? 200 : (isTablet ? 190 : 185),
            ),
            itemBuilder: (context, index) {
              final item = features[index];
              return _FeatureCard(item: item, isDark: isDark);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FeatureData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData item;
  final bool isDark;

  const _FeatureCard({required this.item, required this.isDark});

  void _onCardTap(BuildContext context) {
    switch (item.number) {
      case '01':
        AppNavigator.push(context, const AboutUsScreen());
        break;
      case '02':
        AppNavigator.push(context, const ClassesScreen());
        break;
      case '03':
        AppNavigator.push(context, const TestSeriesScreen());
        break;
      case '04':
        AppNavigator.push(context, const AskDoubtScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onCardTap(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                Text(
                  item.number,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: item.color.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 16, color: item.color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                height: 1.35,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

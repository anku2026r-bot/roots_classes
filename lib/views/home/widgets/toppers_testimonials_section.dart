import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ToppersTestimonialsSection extends StatelessWidget {
  const ToppersTestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    final toppers = [
      _TopperData(
        name: 'Rohan Gupta',
        rank: 'AIR 15',
        exam: 'JEE Advanced',
        quote:
            'Roots Classes transformed my preparation. The test series simulated actual exam conditions, and Akash Sir\'s physics derivations were absolute game changers.',
        year: '2025',
        badgeColor: AppColors.primary,
      ),
      _TopperData(
        name: 'Priya Sharma',
        rank: 'AIR 112',
        exam: 'NEET UG',
        quote:
            'The NCERT line-by-line breakdown and personalized doubt support made all the difference. I scored 685/720 thanks to continuous mentorship!',
        year: '2025',
        badgeColor: const Color(0xFF10B981),
      ),
      _TopperData(
        name: 'Sneha Gupta',
        rank: 'AIR 256',
        exam: 'IIT JEE',
        quote:
            'The faculty dedication at Roots Classes is unmatched. 1-on-1 mentorship sessions and weekly chapter tests eliminated every single weak spot.',
        year: '2025',
        badgeColor: const Color(0xFF8B5CF6),
      ),
      _TopperData(
        name: 'Vikram Singh',
        rank: '99.8%',
        exam: 'CBSE 12th Board',
        quote:
            'Roots Classes 100-Day Percentage Booster course made board exams feel effortless. Their step-wise answer presentation strategy helped me score 99.8%!',
        year: '2025',
        badgeColor: const Color(0xFFF59E0B),
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
          // Section Heading
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SUCCESS STORIES',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Real Results from Real Students',
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 27 : (isTablet ? 24 : 22),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hear how Roots Classes helped our students crack top IITs, AIIMS, and score 99%+ in CBSE board exams.',
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // Cards list
          if (isDesktop || isTablet)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: toppers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 260,
              ),
              itemBuilder: (context, index) {
                return _TopperCard(data: toppers[index], isDark: isDark);
              },
            )
          else
            SizedBox(
              height: 245,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: toppers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 290,
                    child: _TopperCard(data: toppers[index], isDark: isDark),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TopperData {
  final String name;
  final String rank;
  final String exam;
  final String quote;
  final String year;
  final Color badgeColor;

  const _TopperData({
    required this.name,
    required this.rank,
    required this.exam,
    required this.quote,
    required this.year,
    required this.badgeColor,
  });
}

class _TopperCard extends StatelessWidget {
  final _TopperData data;
  final bool isDark;

  const _TopperCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Header: Avatar, Name, Rank Badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: data.badgeColor.withValues(alpha: 0.15),
                child: Text(
                  data.name[0],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: data.badgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      data.exam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: data.badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.rank,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating Stars
          Row(
            children: List.generate(
              5,
              (index) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
            ),
          ),

          const SizedBox(height: 8),

          // Quote
          Expanded(
            child: Text(
              '“${data.quote}”',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

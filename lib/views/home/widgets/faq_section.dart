import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    final faqs = [
      _FaqItem(
        question: 'What courses are offered at Roots Classes?',
        answer:
            'We provide structured, result-driven programs for Foundation (Classes 8th, 9th, 10th), Medical Entrance (NEET-UG), Engineering Entrance (IIT-JEE Main + Advanced), and our signature 100-Day Board Percentage Booster courses.',
      ),
      _FaqItem(
        question: 'How are live classes and recorded lectures conducted?',
        answer:
            'Lectures are streamed in ultra-HD with real-time interactive chat for instant doubt resolution. High-quality recorded archives, digital notes, and Daily Practice Problems (DPPs) are available 24/7 on our platform.',
      ),
      _FaqItem(
        question: 'Do you provide mock test series with detailed solutions?',
        answer:
            'Yes! Every student gets access to weekly chapter-wise tests and full-length all-India mock tests mirroring official NTA/CBSE exam patterns with detailed AI-powered performance diagnostics and video solutions.',
      ),
      _FaqItem(
        question: 'How can I apply for the 100% Scholarship Program?',
        answer:
            'You can appear for the Roots Scholarship Admission Test (RSAT) conducted online and at our Ludhiana centre to qualify for up to 100% scholarship on program tuition fees.',
      ),
      _FaqItem(
        question: 'Is 1-on-1 personal doubt mentorship available?',
        answer:
            'Yes. Beyond regular classes, we host scheduled 1-on-1 doubt counters and dedicated WhatsApp mentor groups where teachers personally guide you through every complex problem.',
      ),
      _FaqItem(
        question: 'Are printed study materials and NCERT notes included?',
        answer:
            'Complete study packages including NCERT line-by-line concept maps, formula cheat sheets, past 15 years question banks, and mock question books are included with full programs.',
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Got Questions? We Have Answers',
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 26 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Everything you need to know about our batches, admission process, test series, and scholarship test.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // FAQ Accordion List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    iconColor: AppColors.primary,
                    collapsedIconColor: isDark ? Colors.white60 : Colors.grey,
                    title: Text(
                      faq.question,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    children: [
                      Text(
                        faq.answer,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          height: 1.45,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

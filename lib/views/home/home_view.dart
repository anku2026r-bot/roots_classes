import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/home_controller.dart';
import '../../models/class_model.dart';
import 'widgets/counseling_dialog.dart';
import 'widgets/hero_banner_section.dart';
import 'widgets/meet_the_team_section.dart';
import 'widgets/toppers_testimonials_section.dart';
import 'widgets/watch_to_learn_section.dart';
import 'widgets/why_choose_us_section.dart';
import 'widgets/your_programs_section.dart';
import '../enrollment/course_enrollment_screen.dart';
import '../../core/utils/app_navigator.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final Function(int tabIndex)? onNavigateTab;

  const HomeView({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
  });

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _programsKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _videosKey = GlobalKey();

  void scrollToPrograms() => _scrollToKey(_programsKey);
  void scrollToVideos() => _scrollToKey(_videosKey);
  void scrollToTeam() => _scrollToKey(_teamKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().fetchHomeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _openEnrollScreen(BuildContext context, ClassModel classItem) {
    AppNavigator.push(context, CourseEnrollmentScreen(classItem: classItem));
  }


  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait([
          homeController.refreshHomeData(),
          Future.delayed(const Duration(milliseconds: 350)),
        ]);
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner Section
              HeroBannerSection(
                banners: homeController.banners,
                onPrimaryCta: () => _scrollToKey(_programsKey),
                onSecondaryCta: () => _scrollToKey(_videosKey),
              ),

              // 2. Why Roots Classes (4 Core Pillars from website)
              const WhyChooseUsSection(),

              // 3. Your Program Section with Admission & Scholarship Announcement
              Container(
                key: _programsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admissions open & 100% scholarship banner (belonging to this section)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => CounselingDialog.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFFEF4444).withValues(alpha: 0.18),
                                        const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                      ]
                                    : [
                                        const Color(0xFFFEF2F2),
                                        const Color(0xFFFFFBEB),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.campaign_rounded,
                                    size: 16,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Admissions open for 2025-26 batch  •  ',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(
                                          text: 'Apply for 100% Scholarship →',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    YourProgramsSection(
                      programs: homeController.filteredPrograms,
                      isLoading: homeController.isLoading,
                      errorMessage: homeController.errorMessage,
                      selectedCategory: homeController.selectedProgramCategory,
                      onCategoryChanged: homeController.setProgramCategory,
                      onRetry: homeController.fetchHomeData,
                      onEnrollPressed: (p) => _openEnrollScreen(context, p),
                      onViewAllPressed: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1); // Go to Classes tab
                        }
                      },
                    ),
                  ],
                ),
              ),

              // 4. Meet the Team Section (Akash Sir & Maths ma'am)
              Container(
                key: _teamKey,
                child: MeetTheTeamSection(
                  teamMembers: homeController.teamMembers,
                  isLoading: homeController.isLoading,
                ),
              ),

              // 5. Watch to Learn Section
              Container(
                key: _videosKey,
                child: WatchToLearnSection(
                  videos: homeController.filteredVideos,
                  isLoading: homeController.isLoading,
                  selectedCategory: homeController.selectedVideoCategory,
                  onCategoryChanged: homeController.setVideoCategory,
                ),
              ),

              // 6. Toppers & Student Success Stories (Reviews from website)
              const ToppersTestimonialsSection(),

              // Clean native bottom padding
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

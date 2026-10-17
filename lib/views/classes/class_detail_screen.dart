import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/classes_controller.dart';
import '../../models/class_model.dart';
import '../home/widgets/counseling_dialog.dart';
import '../widgets/bouncing_pressable.dart';
import '../widgets/status_badge.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ClassModel? _findClass(ClassesController controller) {
    try {
      return controller.classes.firstWhere((c) => c.id == widget.classId);
    } catch (_) {
      return controller.classes.isNotEmpty ? controller.classes.first : null;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    if (category.contains('JEE')) {
      return const [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)];
    } else if (category.contains('NEET')) {
      return const [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF059669)];
    } else if (category.contains('Foundation') ||
        category.contains('10') ||
        category.contains('9') ||
        category.contains('8')) {
      return const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)];
    } else if (category.contains('CUET') || category.contains('Board')) {
      return const [Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFFEA580C)];
    }
    return const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)];
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('JEE')) return Icons.architecture_rounded;
    if (category.contains('NEET')) return Icons.biotech_rounded;
    if (category.contains('Foundation')) return Icons.school_rounded;
    return Icons.auto_stories_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ClassesController>();
    final classItem = _findClass(controller);

    if (classItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final discountPercent =
        (classItem.originalPrice > classItem.price && classItem.originalPrice > 0)
            ? (((classItem.originalPrice - classItem.price) /
                        classItem.originalPrice) *
                    100)
                .round()
            : 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
        title: Text(
          classItem.category,
          style: GoogleFonts.outfit(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Course',
            icon: const Icon(Icons.share_rounded, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course link for "${classItem.title}" copied!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Course',
            icon: const Icon(Icons.refresh_rounded, size: 21),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing course details...'),
                  duration: Duration(milliseconds: 600),
                ),
              );
              await Future.wait([
                controller.fetchClasses(),
                Future.delayed(const Duration(milliseconds: 350)),
              ]);
            },
          ),
          IconButton(
            tooltip: 'Scholarship Counseling',
            icon: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
            onPressed: () => CounselingDialog.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            controller.fetchClasses(),
            Future.delayed(const Duration(milliseconds: 350)),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PROMINENT COURSE THUMBNAIL (thamnes)
            _buildCourseThumbnail(context, classItem, isDark),

            // 2. COURSE DETAILS SECTION (niche saari details)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        label: classItem.category,
                        type: BadgeType.category,
                      ),
                      if (classItem.isEnrolled)
                        const StatusBadge(
                          label: 'Enrolled',
                          type: BadgeType.enrolled,
                        )
                      else if (classItem.isFree)
                        const StatusBadge(
                          label: 'Free Access',
                          type: BadgeType.free,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                              const SizedBox(width: 4),
                              Text(
                                '${classItem.rating} (${classItem.totalStudents}+ Enrolled)',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Course Title
                  Text(
                    classItem.title,
                    style: GoogleFonts.outfit(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Course Subtitle / Objective
                  Text(
                    classItem.subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pricing & Discount Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
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
                      children: [
                        Row(
                          children: [
                            Text(
                              classItem.isFree ? 'FREE' : '₹${classItem.price.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: classItem.isFree
                                    ? AppColors.success
                                    : const Color(0xFF0284C7),
                              ),
                            ),
                            if (!classItem.isFree && classItem.originalPrice > classItem.price) ...[
                              const SizedBox(width: 10),
                              Text(
                                '₹${classItem.originalPrice.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$discountPercent% OFF',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded, size: 15, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              classItem.validity,
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // RSAT scholarship banner strip
                        InkWell(
                          onTap: () => CounselingDialog.show(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Up to 100% Scholarship Available via RSAT Exam',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFFD97706)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. KEY BATCH HIGHLIGHTS / MATRIX
                  Text(
                    'What You Will Get in this Batch',
                    style: GoogleFonts.outfit(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.videocam_rounded,
                          color: const Color(0xFF0284C7),
                          title: '${classItem.liveClassesCount}+ Live',
                          subtitle: 'Interactive Classes',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.play_circle_fill_rounded,
                          color: const Color(0xFF8B5CF6),
                          title: '${classItem.recordedLecturesCount}+ Videos',
                          subtitle: 'Recorded Backup',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF10B981),
                          title: '${classItem.studyMaterialsCount}+ Notes',
                          subtitle: 'DPP & Formula Books',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.assignment_rounded,
                          color: const Color(0xFFF59E0B),
                          title: '${classItem.testSeriesCount}+ Tests',
                          subtitle: 'AIR Rank Analysis',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 4. TAB CONTROLS (Overview, Lectures, Notes)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      tabs: [
                        const Tab(text: 'Overview & Faculty'),
                        Tab(text: 'Lectures (${classItem.lectures.length})'),
                        Tab(text: 'Notes (${classItem.materials.length})'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. TAB VIEW CONTENT DIRECTLY UNDERNEATH
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      switch (_tabController.index) {
                        case 0:
                          return _buildOverviewContent(classItem, isDark);
                        case 1:
                          return _buildLecturesContent(classItem, isDark);
                        case 2:
                          return _buildMaterialsContent(classItem, isDark);
                        default:
                          return _buildOverviewContent(classItem, isDark);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.isFree ? 'Free Admission' : 'Total Course Fee',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    classItem.isFree ? 'FREE' : '₹${classItem.price.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: classItem.isFree ? AppColors.success : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
              BouncingPressable(
                onTap: () async {
                  if (classItem.isEnrolled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You are already enrolled! Enjoy learning.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF0284C7),
                      ),
                    );
                  } else {
                    final success = await controller.enrollClass(classItem.id);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully enrolled in ${classItem.title}!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: classItem.isEnrolled
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF0284C7), const Color(0xFF1E3A8A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        classItem.isEnrolled ? Icons.check_circle_rounded : Icons.bolt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        classItem.isEnrolled
                            ? 'Already Enrolled'
                            : (classItem.isFree ? 'Enroll for Free' : 'Enroll in Batch'),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: Colors.white,
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
    );
  }

  // TOP PROMINENT COURSE THUMBNAIL
  Widget _buildCourseThumbnail(BuildContext context, ClassModel item, bool isDark) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCategoryGradient(item.category),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Network Image or Academic Art
          if (item.bannerUrl != null && item.bannerUrl!.isNotEmpty)
            Image.network(
              item.bannerUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildThumbnailArtwork(item),
            )
          else
            _buildThumbnailArtwork(item),

          // Cinematic Dark Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Top-Left Category Badge Pill
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white30, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getCategoryIcon(item.category), size: 12, color: const Color(0xFFFBBF24)),
                  const SizedBox(width: 5),
                  Text(
                    item.category.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-Right Batch Tag
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'BATCH 2026',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Central Play Preview Button
          Center(
            child: BouncingPressable(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playing batch preview for "${item.title}"'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Bottom Bar Overlay
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded, size: 12, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 5),
                      Text(
                        'By ${item.educator.name}',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF34D399)),
                      const SizedBox(width: 4),
                      Text(
                        'Preview Available',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailArtwork(ClassModel item) {
    return Stack(
      children: [
        Positioned(
          right: -30,
          bottom: -30,
          child: Icon(
            _getCategoryIcon(item.category),
            size: 190,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          left: -20,
          top: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. OVERVIEW & FACULTY TAB CONTENT
  Widget _buildOverviewContent(ClassModel item, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Educator Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                child: Text(
                  item.educator.name.isNotEmpty ? item.educator.name[0] : 'E',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.educator.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0284C7)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.educator.subject,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.educator.qualification} • ${item.educator.experience} Experience',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // About the Course Description
        Text(
          'About This Course',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            item.description,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Roots Classes Advantages
        Text(
          'Why Roots Classes?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        _buildAdvantageTile(
          icon: Icons.psychology_rounded,
          title: 'Daily Practice Problems (DPP)',
          description: 'Topic-wise graded questions with detailed step-by-step video solutions.',
          isDark: isDark,
        ),
        _buildAdvantageTile(
          icon: Icons.contact_support_rounded,
          title: '1-on-1 Dedicated Doubt Counters',
          description: 'Live mentor support to resolve concepts and numericals instantly.',
          isDark: isDark,
        ),
        _buildAdvantageTile(
          icon: Icons.analytics_rounded,
          title: 'All-India Test Series & Benchmarking',
          description: 'Compare your preparation with aspirants nationwide on exact NTA patterns.',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAdvantageTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF0284C7)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. LECTURES TAB CONTENT
  Widget _buildLecturesContent(ClassModel item, bool isDark) {
    if (item.lectures.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.videocam_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              'Live lectures schedule starting soon.',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: item.lectures.map((lec) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: lec.isLive
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFF0284C7).withValues(alpha: 0.12),
              child: Icon(
                lec.isLive ? Icons.videocam_rounded : Icons.play_arrow_rounded,
                color: lec.isLive ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
              ),
            ),
            title: Text(
              lec.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            subtitle: Text(
              lec.isLive
                  ? 'LIVE NOW • ${lec.scheduledAt ?? ""}'
                  : '${lec.durationMinutes} mins recorded session',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: lec.isLive ? const Color(0xFFEF4444) : Colors.grey,
              ),
            ),
            trailing: Icon(
              item.isEnrolled ? Icons.play_circle_fill_rounded : Icons.lock_outline_rounded,
              size: 22,
              color: item.isEnrolled ? const Color(0xFF0284C7) : Colors.grey,
            ),
            onTap: () {
              if (!item.isEnrolled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enroll in this batch to watch this lecture.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playing lecture: ${lec.title}'),
                    backgroundColor: const Color(0xFF0284C7),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  // 3. STUDY NOTES & MATERIALS TAB CONTENT
  Widget _buildMaterialsContent(ClassModel item, bool isDark) {
    if (item.materials.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              'No study notes uploaded for this batch yet.',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: item.materials.map((mat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF059669).withValues(alpha: 0.12),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF059669)),
            ),
            title: Text(
              mat.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            subtitle: Text(
              '${mat.fileType} • ${mat.fileSize}',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download_rounded, color: Color(0xFF0284C7)),
              onPressed: () {
                if (!item.isEnrolled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enroll in this batch to download study materials.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloading "${mat.title}"...'),
                      backgroundColor: const Color(0xFF0284C7),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

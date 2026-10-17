import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_constants.dart';
import '../../controllers/classes_controller.dart';
import '../../models/class_model.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_badge.dart';
import 'class_detail_screen.dart';
import '../enrollment/course_enrollment_screen.dart';
import '../../core/utils/app_navigator.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassesController>().fetchClasses();
    });
  }

  void _showEnrollDialog(BuildContext context, ClassModel classItem) {
    AppNavigator.push(context, CourseEnrollmentScreen(classItem: classItem));
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ClassesController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.fetchClasses(),
            Future.delayed(const Duration(milliseconds: 350)),
          ]);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Header Bar & Search Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    CustomSearchBar(
                      hintText: 'Search classes, batches, or educators...',
                      onChanged: (q) => controller.setSearchQuery(q),
                    ),
                    const SizedBox(height: 14),

                    // Category Chips Bar
                    CategoryFilterBar(
                      categories: ApiConstants.categories,
                      selectedCategory: controller.selectedCategory,
                      onSelected: (cat) => controller.setCategory(cat),
                    ),
                  ],
                ),
              ),
            ),

            // Content Body
            if (controller.isLoading && controller.classes.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const SkeletonCard(height: 210),
                    childCount: 4,
                  ),
                ),
              )
            else if (controller.errorMessage != null && controller.classes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 56,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchClasses(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (controller.classes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes found for "${controller.selectedCategory}"',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try clearing your search query or choosing another category.',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = controller.classes[index];
                      return _buildClassCard(context, item, isDark);
                    },
                    childCount: controller.classes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClassDetailScreen(classId: item.id)),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardThumbnailBanner(item),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        label: item.category,
                        type: BadgeType.category,
                      ),
                  if (item.isEnrolled)
                    const StatusBadge(
                      label: 'Enrolled',
                      type: BadgeType.enrolled,
                    )
                  else if (item.isFree)
                    const StatusBadge(
                      label: 'Free Access',
                      type: BadgeType.free,
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating} (${item.totalStudents}+)',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                item.title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Educator Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      item.educator.name.isNotEmpty ? item.educator.name[0] : 'E',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.educator.name,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${item.educator.subject} • ${item.educator.experience}',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Deliverables Pills (Live classes, recorded, materials)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildFeaturePill(Icons.videocam_rounded, '${item.liveClassesCount} Live Classes', isDark),
                  _buildFeaturePill(Icons.play_circle_outline_rounded, '${item.recordedLecturesCount} Lectures', isDark),
                  _buildFeaturePill(Icons.description_outlined, '${item.studyMaterialsCount} Notes', isDark),
                  _buildFeaturePill(Icons.quiz_outlined, '${item.testSeriesCount} Tests', isDark),
                ],
              ),
              const Divider(height: 24),

              // Price & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price Tag
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.validity,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              item.isFree ? 'FREE' : '₹${item.price.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: item.isFree ? AppColors.success : AppColors.primary,
                              ),
                            ),
                            if (!item.isFree && item.originalPrice > item.price) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${item.originalPrice.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  decoration: TextDecoration.lineThrough,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Button
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (item.isEnrolled) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ClassDetailScreen(classId: item.id)),
                            );
                          } else {
                            _showEnrollDialog(context, item);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.isEnrolled ? AppColors.accent : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          item.isEnrolled ? 'Access Batch' : (item.isFree ? 'Enroll Free' : 'Buy Batch'),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
}

  Widget _buildFeaturePill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardThumbnailBanner(ClassModel item) {
    final colors = _getCategoryGradient(item.category);
    return Container(
      height: 115,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.bannerUrl != null && item.bannerUrl!.isNotEmpty)
            Image.network(
              item.bannerUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              _getCategoryIcon(item.category),
              size: 110,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam_rounded, size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${item.liveClassesCount}+ Live',
                    style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}

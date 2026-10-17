import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/class_model.dart';
import '../../classes/class_detail_screen.dart';
import '../../widgets/bouncing_pressable.dart';
import '../../widgets/skeleton_loader.dart';

class YourProgramsSection extends StatelessWidget {
  final List<ClassModel> programs;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final Function(String category) onCategoryChanged;
  final VoidCallback onRetry;
  final Function(ClassModel program)? onEnrollPressed;
  final VoidCallback? onViewAllPressed;

  const YourProgramsSection({
    super.key,
    required this.programs,
    required this.isLoading,
    this.errorMessage,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onRetry,
    this.onEnrollPressed,
    this.onViewAllPressed,
  });

  static const List<String> categories = [
    'All',
    'Foundation (8-10)',
    'Medical (NEET)',
    'Engineering (JEE)',
    'Board Booster',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'YOUR PROGRAMS',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Comprehensive Batches & Programs',
                      style: GoogleFonts.outfit(
                        fontSize: isDesktop ? 27 : (isTablet ? 24 : 22.5),
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Curated curriculum designed by India’s top coaching mentors.',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAllPressed != null) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onViewAllPressed,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    'View All',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                    ),
                    backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade100,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => onCategoryChanged(cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Content body: Loading, Error, Empty, or Programs Grid
          if (isLoading)
            _buildLoadingSkeleton(isDesktop: isDesktop, isTablet: isTablet)
          else if (errorMessage != null)
            _buildErrorState(context)
          else if (programs.isEmpty)
            _buildEmptyState(context)
          else
            _buildProgramsGrid(context, isDesktop: isDesktop, isTablet: isTablet),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton({required bool isDesktop, required bool isTablet}) {
    final count = isDesktop ? 3 : (isTablet ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 380,
      ),
      itemBuilder: (_, _) => const SkeletonCard(height: 380),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'Unable to fetch available programs.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
            label: Text('Try Again', style: GoogleFonts.outfit(color: Colors.white)),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No programs found in "$selectedCategory"',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting "All" or browse other course categories.',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => onCategoryChanged('All'),
            child: const Text('Show All Programs'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsGrid(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: programs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: 440,
      ),
      itemBuilder: (context, index) {
        final program = programs[index];
        return _ProgramCard(
          program: program,
          onEnrollPressed: onEnrollPressed,
        );
      },
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ClassModel program;
  final Function(ClassModel)? onEnrollPressed;

  const _ProgramCard({
    required this.program,
    this.onEnrollPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncingPressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDetailScreen(classId: program.id),
          ),
        );
      },
      lowerBound: 0.97,
      child: Container(
        decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Image / Visual Header Banner
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getCategoryGradient(program.category),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative shapes
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),

                  // Category tag & Enrolled badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        program.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                  if (program.isEnrolled)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'ENROLLED',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Center icon/graphic
                  Center(
                    child: Icon(
                      _getCategoryIcon(program.category),
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 44,
                    ),
                  ),

                  // Rating pill
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            program.rating.toString(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program Title
                    Text(
                      program.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.5,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Program Short Description
                    Text(
                      program.subtitle.isNotEmpty ? program.subtitle : program.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Educator info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            program.educator.name.isNotEmpty
                                ? program.educator.name[0]
                                : 'E',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${program.educator.name} • ${program.educator.experience}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Divider(height: 16),

                    // Price & Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${program.price.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                              if (program.originalPrice > program.price)
                                Text(
                                  '₹${program.originalPrice.toInt()}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action Buttons: "View Details" & "Enroll"
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // View Details Button
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ClassDetailScreen(classId: program.id),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View Details',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                if (!program.isEnrolled && onEnrollPressed != null) ...[
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => onEnrollPressed!(program),
                                    child: Text(
                                      'Enroll',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
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

  List<Color> _getCategoryGradient(String category) {
    if (category.contains('JEE')) {
      return [const Color(0xFF1E3A8A), const Color(0xFF2563EB)];
    } else if (category.contains('NEET')) {
      return [const Color(0xFF065F46), const Color(0xFF059669)];
    } else if (category.contains('CUET')) {
      return [const Color(0xFF7C2D12), const Color(0xFFEA580C)];
    } else if (category.contains('GATE')) {
      return [const Color(0xFF581C87), const Color(0xFF9333EA)];
    }
    return [const Color(0xFF1E293B), const Color(0xFF334155)];
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('JEE')) {
      return Icons.architecture_rounded;
    } else if (category.contains('NEET')) {
      return Icons.biotech_rounded;
    } else if (category.contains('CUET')) {
      return Icons.menu_book_rounded;
    } else if (category.contains('GATE')) {
      return Icons.computer_rounded;
    }
    return Icons.school_rounded;
  }
}

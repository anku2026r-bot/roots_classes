import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/classes_controller.dart';
import '../../controllers/test_series_controller.dart';
import '../auth/login_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/bouncing_pressable.dart';
import '../../core/utils/app_navigator.dart';
import 'edit_profile_screen.dart';
import 'student_id_card_screen.dart';
import 'fee_receipts_screen.dart';
import 'change_password_screen.dart';
import '../legal/terms_conditions_screen.dart';
import '../legal/privacy_policy_screen.dart';
import 'video_quality_screen.dart';
import '../center/offline_center_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _notificationsEnabled = true;
  bool _testRemindersEnabled = true;
  String _selectedQuality = 'High (720p)';
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final classesCtrl = context.watch<ClassesController>();
    final testCtrl = context.watch<TestSeriesController>();

    final user = auth.currentUser;
    final enrolledCount = classesCtrl.classes.where((c) => c.isEnrolled).length;
    final testsCount = testCtrl.userAttempts.length;

    final userName = (user != null && user.name.isNotEmpty) ? user.name : 'Aman Sharma';
    final userEmail = (user != null && user.email.isNotEmpty) ? user.email : 'student@rootsclasses.com';
    final userPhone = (user != null && (user.phone?.isNotEmpty ?? false)) ? user.phone! : '+91 98775-15330';
    final userClass = (user != null && (user.currentClass?.isNotEmpty ?? false)) ? user.currentClass! : '11th Standard';
    final userCourse = (user != null && (user.interestedCourse?.isNotEmpty ?? false)) ? user.interestedCourse! : 'Medical (NEET)';
    final userGender = (user != null && (user.gender?.isNotEmpty ?? false)) ? user.gender! : 'Male';
    final userAddress = (user != null && (user.address?.isNotEmpty ?? false)) ? user.address! : 'Model Town, Ludhiana, Punjab';
    final userDob = (user != null && (user.dateofBirth?.isNotEmpty ?? false)) ? user.dateofBirth! : '15-04-2006';
    final isVerified = user?.isEmailVerified ?? true;
    final studentId = 'RC-${(user?.id.hashCode.abs() ?? 1024) % 90000 + 10000}';
    final joinDate = user != null
        ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
        : '12/10/2026';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait([
          context.read<AuthController>().initialize(),
          context.read<ClassesController>().fetchClasses(),
          context.read<TestSeriesController>().fetchTestSeries(),
          Future.delayed(const Duration(milliseconds: 350)),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. EXECUTIVE EDTECH HERO BANNER & STUDENT BADGE CARD
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Top Curved Academy Header Banner
                      Container(
                        height: 96,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0B132B), // Obsidian Slate
                              Color(0xFF1E3A8A), // Prestige Royal Navy
                              Color(0xFF0284C7), // Electric Ocean Blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand Tagline
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30, width: 0.8),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 14,
                                    color: Color(0xFFFBBF24),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ROOTS CLASSES',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'EXCELLENCE â€¢ EST. 2012',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Top Right Gold Scholarship Ribbon
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars_rounded, size: 12.5, color: Color(0xFFB45309)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'RSAT 100% SCHOLAR',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFB45309),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Student Info Body Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          children: [
                            // Profile Avatar & Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Glowing Avatar with Camera Badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                                          style: GoogleFonts.outfit(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: InkWell(
                                        onTap: () => _showEditProfileDialog(context, auth),
                                        child: Container(
                                          padding: const EdgeInsets.all(4.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                // Student Name, Email, Copyable Roll Number
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          if (isVerified) ...[
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.verified_rounded,
                                              size: 17,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        userEmail,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Interactive Copy Roll Number Pill
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: studentId));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Roll No "$studentId" copied!'),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: const Color(0xFF0284C7),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.content_copy_rounded,
                                                size: 10,
                                                color: Color(0xFF0284C7),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'Roll No: $studentId',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '(Tap to copy)',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9.5,
                                                  color: const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Edit Profile Pill Button
                                BouncingPressable(
                                  onTap: () => _showEditProfileDialog(context, auth),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit_outlined, size: 11, color: Color(0xFF0284C7)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Program Capsule Tag
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.school_rounded, size: 12.5, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '$userCourse \u2022 Class $userClass',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Integrated 4-Metric Grid inside Hero Card
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildMetricCol(
                                    value: '$enrolledCount',
                                    label: 'Batches',
                                    icon: Icons.school_rounded,
                                    color: const Color(0xFF0284C7),
                                    isDark: isDark,
                                  ),
                                  _buildVerticalDivider(isDark),
                                  _buildMetricCol(
                                    value: '$testsCount',
                                    label: 'Tests',
                                    icon: Icons.analytics_rounded,
                                    color: const Color(0xFF7C3AED),
                                    isDark: isDark,
                                  ),
                                  _buildVerticalDivider(isDark),
                                  _buildMetricCol(
                                    value: '94.8%',
                                    label: 'Attendance',
                                    icon: Icons.check_circle_rounded,
                                    color: const Color(0xFF10B981),
                                    isDark: isDark,
                                  ),
                                  _buildVerticalDivider(isDark),
                                  _buildMetricCol(
                                    value: 'Top 1%',
                                    label: 'Center Rank',
                                    icon: Icons.military_tech_rounded,
                                    color: const Color(0xFFD97706),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Profile Completion Mini Bar
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  'Profile 85% Completed',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: 0.85,
                                      minHeight: 4,
                                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showEditProfileDialog(context, auth),
                                  child: Text(
                                    'Complete Now >',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0284C7),
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
              ),

              const SizedBox(height: 16),

              // 2. MODERN SEGMENTED TABS
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    _buildSegmentTab(0, 'Academics', Icons.school_rounded, isDark),
                    _buildSegmentTab(1, 'ID & Receipts', Icons.badge_rounded, isDark),
                    _buildSegmentTab(2, 'Account & Help', Icons.manage_accounts_rounded, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. TAB CONTENT
              if (_selectedTabIndex == 0) ...[
                // TAB 1: ACADEMICS
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        title: 'My Batches',
                        value: '$enrolledCount Enrolled',
                        subtitle: 'Live & Classroom',
                        icon: Icons.school_rounded,
                        color: const Color(0xFF0284C7),
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$enrolledCount active batches enrolled'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF0284C7),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionTile(
                        title: 'Test Reports',
                        value: '$testsCount Attempted',
                        subtitle: 'Rank & Performance',
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFF7C3AED),
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Viewing comprehensive test analytics & ranking'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF7C3AED),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Performance & Mentorship Section
                _buildSectionCard(
                  title: 'Academic Performance & Mentorship',
                  icon: Icons.military_tech_rounded,
                  isDark: isDark,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Classroom Attendance: 94.8%',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '54 out of 57 lectures attended \u2022 Excellent consistency',
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoTile(
                      icon: Icons.leaderboard_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Overall Center Rank',
                      value: '#14 in North Zone (Top 1%)',
                      isDark: isDark,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Top 1%',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.person_pin_rounded,
                      iconColor: const Color(0xFF0078FF),
                      label: 'Academic Mentor',
                      value: 'Er. Subhash Sir (Physics Lead)',
                      isDark: isDark,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0078FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Assigned',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0078FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.alarm_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      label: 'Next Scheduled Lecture',
                      value: 'Tomorrow \u2022 09:00 AM (Organic Chemistry)',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Academic Program Overview Card
                _buildSectionCard(
                  title: 'Academic Program Details',
                  icon: Icons.school_rounded,
                  isDark: isDark,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFF0F7FF), const Color(0xFFE0EFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0078FF).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.school_rounded, color: Color(0xFF0078FF), size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ACADEMIC PROGRAM',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: const Color(0xFF0078FF),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0078FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Class $userClass',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userCourse,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0A1628),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFFB0500)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Roots Flagship Center, Ludhiana \u2022 Offline Batch',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
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
              ] else if (_selectedTabIndex == 1) ...[
                // TAB 2: ID & RECEIPTS
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        title: 'Digital ID Pass',
                        value: 'Campus Pass',
                        subtitle: 'QR Entry & Attendance',
                        icon: Icons.badge_rounded,
                        color: const Color(0xFF059669),
                        isDark: isDark,
                        onTap: () => _showStudentIdCard(
                          context,
                          studentName: userName,
                          studentId: studentId,
                          course: userCourse,
                          className: userClass,
                          phone: userPhone,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionTile(
                        title: 'Fee Receipts',
                        value: 'Payment History',
                        subtitle: 'Official Invoices & Dues',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFD97706),
                        isDark: isDark,
                        onTap: () => _showReceiptsModal(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Documents & ID Cards Section
                _buildSectionCard(
                  title: 'Official Documents & ID Pass',
                  icon: Icons.assignment_ind_rounded,
                  isDark: isDark,
                  children: [
                    _buildDocumentTile(
                      icon: Icons.badge_rounded,
                      iconColor: const Color(0xFF0078FF),
                      title: 'Digital Student Identity Card',
                      subtitle: 'Official barcode & QR access card for Ludhiana Center',
                      actionLabel: 'View ID',
                      onTap: () => _showStudentIdCard(
                        context,
                        studentName: userName,
                        studentId: studentId,
                        course: userCourse,
                        className: userClass,
                        phone: userPhone,
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Course Fee Receipts & Invoices',
                      subtitle: 'Download official admission & installment fee receipts',
                      actionLabel: 'Receipts',
                      onTap: () => _showReceiptsModal(context),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      icon: Icons.military_tech_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'RSAT 2025 Scholarship Certificate',
                      subtitle: '100% Tuition Fee Waiver Authorization Letter',
                      actionLabel: 'Download',
                      actionIcon: Icons.download_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading RSAT Scholarship Letter...'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ] else ...[
                // TAB 3: ACCOUNT & HELP
                _buildSectionCard(
                  title: 'Personal & Contact Details',
                  icon: Icons.person_pin_rounded,
                  isDark: isDark,
                  action: InkWell(
                    onTap: () => _showEditProfileDialog(context, auth),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0078FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0078FF).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded, size: 13, color: Color(0xFF0078FF)),
                          const SizedBox(width: 4),
                          Text(
                            'Edit Details',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0078FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  children: [
                    _buildInfoTile(
                      icon: Icons.phone_android_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: 'Mobile Number',
                      value: userPhone,
                      isDark: isDark,
                      onTap: () => _showEditProfileDialog(context, auth),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.mail_outline_rounded,
                      iconColor: const Color(0xFF0078FF),
                      label: 'Email Address',
                      value: userEmail,
                      isDark: isDark,
                      onTap: () => _showEditProfileDialog(context, auth),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.cake_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Date of Birth',
                      value: userDob,
                      isDark: isDark,
                      onTap: () => _showEditProfileDialog(context, auth),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      label: 'Gender',
                      value: userGender,
                      isDark: isDark,
                      onTap: () => _showEditProfileDialog(context, auth),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      icon: Icons.home_work_rounded,
                      iconColor: const Color(0xFF0284C7),
                      label: 'Residential Address',
                      value: userAddress,
                      isDark: isDark,
                      onTap: () => _showEditProfileDialog(context, auth),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Preferences & Study Settings
                _buildSectionCard(
                  title: 'Preferences & Study Settings',
                  icon: Icons.tune_rounded,
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: const Color(0xFF0078FF),
                      title: 'Live Class Reminders',
                      subtitle: 'Get notified 15 mins before lectures',
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeTrackColor: const Color(0xFF0078FF),
                        onChanged: (val) {
                          setState(() => _notificationsEnabled = val);
                        },
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Test Series Deadlines',
                      subtitle: 'Alerts when new mock test papers go live',
                      trailing: Switch.adaptive(
                        value: _testRemindersEnabled,
                        activeTrackColor: const Color(0xFF7C3AED),
                        onChanged: (val) {
                          setState(() => _testRemindersEnabled = val);
                        },
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      icon: Icons.video_library_rounded,
                      iconColor: const Color(0xFF059669),
                      title: 'Video Download Quality',
                      subtitle: 'Preferred offline lecture resolution',
                      onTap: () => _showQualityPicker(context),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedQuality,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Security & Access
                _buildSectionCard(
                  title: 'Security & Access',
                  icon: Icons.security_rounded,
                  isDark: isDark,
                  children: [
                    _buildDocumentTile(
                      icon: Icons.key_rounded,
                      iconColor: const Color(0xFF0078FF),
                      title: 'Change Password',
                      subtitle: 'Update account authentication password',
                      actionLabel: 'Update',
                      onTap: () => _showChangePasswordDialog(context),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.devices_rounded,
                      iconColor: const Color(0xFF059669),
                      label: 'Active Device',
                      value: 'Android Tablet / Phone',
                      isDark: isDark,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Connected',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.lock_clock_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Member Since',
                      value: joinDate,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Roots Ludhiana Help & Support
                _buildSectionCard(
                  title: 'Roots Classes Help & Support',
                  icon: Icons.support_agent_rounded,
                  isDark: isDark,
                  children: [
                    _buildDocumentTile(
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Helpline & Counselor',
                      subtitle: '+91 98775-15330 \u2022 Student Support Desk',
                      actionLabel: 'Call Now',
                      actionIcon: Icons.phone_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dialing Ludhiana Support: +91 98775-15330...'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFFB0500),
                      title: 'Offline Flagship Center',
                      subtitle: 'Gill Rd, Opp. ITI College, Shilapuri, Ludhiana',
                      actionLabel: 'Details',
                      actionIcon: Icons.arrow_forward_ios_rounded,
                      onTap: () => AppNavigator.push(context, const OfflineCenterScreen()),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Terms of Service',
                      subtitle: 'Student admission & platform terms',
                      actionLabel: 'View',
                      onTap: () => AppNavigator.push(context, const TermsConditionsScreen()),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'Privacy Policy',
                      subtitle: 'Data protection and student privacy',
                      actionLabel: 'View',
                      onTap: () => AppNavigator.push(context, const PrivacyPolicyScreen()),
                      isDark: isDark,
                    ),
                  ],
                ),


                const SizedBox(height: 20),

                // Sign Out Button
                CustomButton(
                  text: 'Sign Out from App',
                  backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                  textColor: AppColors.error,
                  icon: Icons.logout_rounded,
                  onPressed: () => _showLogoutConfirmation(context),
                ),
              ],

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Roots Classes App v2.4.0 \u2022 Made with â¤ï¸ in Punjab',
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSegmentTab(int index, String label, IconData icon, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0284C7) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0284C7))
                    : (isDark ? Colors.white54 : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildMetricCol({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return BouncingPressable(
      onTap: onTap,
      lowerBound: 0.94,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap == null) return tile;

    return BouncingPressable(
      onTap: onTap,
      lowerBound: 0.97,
      borderRadius: BorderRadius.circular(14),
      child: tile,
    );
  }

  Widget _buildDocumentTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required bool isDark,
    IconData actionIcon = Icons.arrow_forward_ios_rounded,
  }) {
    return BouncingPressable(
      onTap: onTap,
      lowerBound: 0.96,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(actionIcon, size: 11, color: iconColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildFormSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthController auth) {
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialName = (user != null && user.name.isNotEmpty) ? user.name : 'Aman Sharma';
    final initialEmail = (user != null && user.email.isNotEmpty) ? user.email : 'student@rootsclasses.com';
    String initialDigits = (user?.phone ?? '9877515330').replaceAll(RegExp(r'\D'), '');
    if (initialDigits.length > 10 && initialDigits.startsWith('91')) {
      initialDigits = initialDigits.substring(2);
    }
    if (initialDigits.isEmpty) initialDigits = '9877515330';

    final initialAddress = (user?.address?.isNotEmpty == true) ? user!.address! : 'Model Town, Ludhiana, Punjab';
    final initialDob = (user?.dateofBirth?.isNotEmpty == true) ? user!.dateofBirth! : '15-04-2006';

    final nameCtrl = TextEditingController(text: initialName);
    final emailCtrl = TextEditingController(text: initialEmail);
    final phoneCtrl = TextEditingController(text: initialDigits);
    final addressCtrl = TextEditingController(text: initialAddress);
    final dobCtrl = TextEditingController(text: initialDob);

    String selectedCourse = (user?.interestedCourse?.isNotEmpty == true) ? user!.interestedCourse! : 'Medical (NEET)';
    String selectedClass = (user?.currentClass?.isNotEmpty == true) ? user!.currentClass! : '11th Standard';
    String selectedGender = (user?.gender?.isNotEmpty == true) ? user!.gender! : 'Male';

    final formKey = GlobalKey<FormState>();

    AppNavigator.push(context, EditProfileScreen(user: user));
    return;
    // ignore: dead_code
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Student Profile',
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Update personal, academic & contact details',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                color: isDark ? Colors.white60 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 22),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Form Scrollable Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION: PERSONAL INFO
                          _buildFormSectionHeader('PERSONAL DETAILS', Icons.person_rounded, isDark),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: 'Student Full Name',
                            hint: 'Enter your full name',
                            controller: nameCtrl,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Date of Birth
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2007, 4, 15),
                                      firstDate: DateTime(1990),
                                      lastDate: now,
                                    );
                                    if (picked != null) {
                                      final day = picked.day.toString().padLeft(2, '0');
                                      final month = picked.month.toString().padLeft(2, '0');
                                      setModalState(() {
                                        dobCtrl.text = '$day-$month-${picked.year}';
                                      });
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: CustomTextField(
                                      label: 'Date of Birth (Tap to pick)',
                                      hint: 'DD-MM-YYYY',
                                      controller: dobCtrl,
                                      prefixIcon: Icons.calendar_month_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Gender
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gender',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedGender,
                                          isExpanded: true,
                                          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                                          items: ['Male', 'Female', 'Other'].map((g) {
                                            return DropdownMenuItem(
                                              value: g,
                                              child: Text(g, style: GoogleFonts.outfit(fontSize: 13.5)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setModalState(() => selectedGender = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION: ACADEMICS
                          _buildFormSectionHeader('ACADEMIC PROGRAM & CLASS', Icons.school_rounded, isDark),
                          const SizedBox(height: 10),
                          Text(
                            'Target Exam / Course',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Medical (NEET)',
                              'Engineering (JEE)',
                              'Foundation (8-10)',
                              'Board Booster',
                            ].map((c) {
                              final isSel = selectedCourse.contains(c.split(' ').first);
                              return ChoiceChip(
                                label: Text(c),
                                selected: isSel,
                                selectedColor: AppColors.primary,
                                labelStyle: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                onSelected: (_) {
                                  setModalState(() => selectedCourse = c);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 14),
                          Text(
                            'Current Class',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              '8th Standard',
                              '9th Standard',
                              '10th Standard',
                              '11th Standard',
                              '12th Standard',
                              'Dropper / Repeater',
                            ].map((cls) {
                              final isSel = selectedClass.contains(cls.split(' ').first);
                              return ChoiceChip(
                                label: Text(cls),
                                selected: isSel,
                                selectedColor: AppColors.primary,
                                labelStyle: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                onSelected: (_) {
                                  setModalState(() => selectedClass = cls);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // SECTION: CONTACT & LOCATION
                          _buildFormSectionHeader('CONTACT & RESIDENCE', Icons.contact_mail_rounded, isDark),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: 'Mobile Number',
                            hint: '10-digit mobile number',
                            controller: phoneCtrl,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Phone number required';
                              final digits = val.replaceAll(RegExp(r'\D'), '');
                              final ten = (digits.length > 10 && digits.startsWith('91')) ? digits.substring(2) : digits;
                              return Validators.validatePhone(ten);
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Email Address',
                            hint: 'student@rootsclasses.com',
                            controller: emailCtrl,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'City & Residential Address',
                            hint: 'e.g. Model Town, Ludhiana, Punjab',
                            controller: addressCtrl,
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom CTA Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          label: Text(
                            'Save Profile',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(ctx);

                            final cleanPhone = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
                            final formattedPhone = (cleanPhone.length > 10 && cleanPhone.startsWith('91'))
                                ? cleanPhone.substring(2)
                                : cleanPhone;

                            final success = await auth.updateProfile(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              phone: formattedPhone,
                              currentClass: selectedClass,
                              interestedCourse: selectedCourse,
                              address: addressCtrl.text.trim(),
                              dateofBirth: dobCtrl.text.trim(),
                              gender: selectedGender,
                            );

                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Profile updated successfully!',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(auth.errorMessage ?? 'Failed to update profile'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showStudentIdCard(
    BuildContext context, {
    required String studentName,
    required String studentId,
    required String course,
    required String className,
    required String phone,
  }) {
    AppNavigator.push(
      context,
      StudentIdCardScreen(
        studentName: studentName,
        studentId: studentId,
        course: course,
        className: className,
        phone: phone,
      ),
    );
    return;
    // ignore: dead_code
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROOTS CLASSES',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'STUDENT IDENTITY CARD',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '2025-26',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                        style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      studentName,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Roll No: $studentId',
                      style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _cardRow('Course', course),
                          const SizedBox(height: 6),
                          _cardRow('Class', className),
                          const SizedBox(height: 6),
                          _cardRow('Center', 'Ludhiana Flagship Center'),
                          const SizedBox(height: 6),
                          _cardRow('Helpline', phone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.white70),
                        const SizedBox(width: 10),
                        Text(
                          'Verified Authentic Student\nRoots Classes Ludhiana',
                          style: GoogleFonts.outfit(fontSize: 10, color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
            label: const Text('Download ID', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID Card downloaded to device storage!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
        Text(val, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    );
  }

  void _showReceiptsModal(BuildContext context) {
    AppNavigator.push(context, const FeeReceiptsScreen());
    return;
    // ignore: dead_code
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Enrolled Course Fee Receipts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JEE Main & Advanced 2026 Batch', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Invoice #RC-INV-2025-01 • Paid ₹12,000 via UPI', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading Invoice #RC-INV-2025-01...'), backgroundColor: AppColors.success),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityPicker(BuildContext context) async {
    final result = await AppNavigator.push<String>(
      context,
      VideoQualityScreen(currentQuality: _selectedQuality),
    );
    if (result != null) {
      setState(() => _selectedQuality = result);
    }
  }


  void _showChangePasswordDialog(BuildContext context) {
    AppNavigator.push(context, const ChangePasswordScreen());
    return;
    // ignore: dead_code
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => Consumer<AuthController>(
        builder: (context, auth, _) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(auth.errorMessage!, style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13)),
                      ),
                    CustomTextField(
                      label: 'Current Password',
                      hint: 'Enter existing password',
                      controller: oldPasswordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: Validators.validateLoginPassword,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'New Password',
                      hint: 'Enter strong new password',
                      controller: newPasswordController,
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Confirm New Password',
                      hint: 'Re-enter new password',
                      controller: confirmPasswordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (val) => Validators.validateConfirmPassword(val, newPasswordController.text),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  auth.clearMessages();
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final success = await auth.changePassword(
                          oldPassword: oldPasswordController.text,
                          newPassword: newPasswordController.text,
                        );
                        if (dialogCtx.mounted && success) {
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                child: auth.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.logoutConfirmTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(AppStrings.logoutConfirmMessage, style: GoogleFonts.outfit(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthController>();
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

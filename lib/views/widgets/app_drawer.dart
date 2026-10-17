import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/classes_controller.dart';
import '../../controllers/test_series_controller.dart';
import '../auth/login_screen.dart';
import '../home/widgets/counseling_dialog.dart';
import 'app_logo.dart';
import 'bouncing_pressable.dart';
import '../../core/utils/app_navigator.dart';
import '../materials/study_materials_screen.dart';
import '../center/offline_center_screen.dart';
import '../counseling/academic_counseling_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onScrollToVideos;
  final VoidCallback? onScrollToTeam;
  final VoidCallback? onScrollToToppers;
  final VoidCallback? onScrollToFaq;

  const AppDrawer({
    super.key,
    this.onNavigateTab,
    this.onScrollToVideos,
    this.onScrollToTeam,
    this.onScrollToToppers,
    this.onScrollToFaq,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final classesCtrl = context.watch<ClassesController>();
    final testCtrl = context.watch<TestSeriesController>();

    final user = auth.currentUser;
    final isAuthenticated = auth.isAuthenticated;
    final enrolledCount = classesCtrl.classes.where((c) => c.isEnrolled).length;
    final testAttemptsCount = testCtrl.userAttempts.length;

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Column(
        children: [
          // 1. Header (User profile banner or guest banner)
          _DrawerHeader(
            isAuthenticated: isAuthenticated,
            userName: user?.name ?? 'Aspirant',
            userEmail: user?.email ?? '',
            userPhone: user?.phone ?? '',
            userTarget: (user != null && (user.interestedCourse?.isNotEmpty ?? false))
                ? '${user.interestedCourse} Aspirant • Class ${user.currentClass ?? ""}'
                : 'JEE & NEET Prep • Roots Classes',
            isDark: isDark,
            onLoginPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),

          // 2. Quick stats pill for logged in student
          if (isAuthenticated)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickStatPill(
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    value: '$enrolledCount',
                    label: 'Enrolled',
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigateTab != null) onNavigateTab!(3); // My Learnings
                    },
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  _QuickStatPill(
                    icon: Icons.assignment_turned_in_rounded,
                    color: AppColors.accent,
                    value: '$testAttemptsCount',
                    label: 'Tests Taken',
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigateTab != null) onNavigateTab!(2); // Test series
                    },
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  _QuickStatPill(
                    icon: Icons.workspace_premium_rounded,
                    color: const Color(0xFFF59E0B),
                    value: '100%',
                    label: 'RSAT Aid',
                    onTap: () {
                      Navigator.pop(context);
                      CounselingDialog.show(context);
                    },
                  ),
                ],
              ),
            ),

          // 3. Scrollable List of Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _SectionTitle('ACADEMICS & LEARNING', isDark: isDark),

                _DrawerTile(
                  icon: Icons.home_rounded,
                  iconColor: AppColors.primary,
                  title: 'Home Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(0);
                  },
                ),

                _DrawerTile(
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Classes & Batches',
                  badgeText: 'Live',
                  badgeColor: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(1);
                  },
                ),

                _DrawerTile(
                  icon: Icons.assignment_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'All-India Test Series',
                  badgeText: 'AIR Rank',
                  badgeColor: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(2);
                  },
                ),

                _DrawerTile(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF059669),
                  title: 'My Learnings & History',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(3);
                  },
                ),

                _DrawerTile(
                  icon: Icons.play_circle_fill_rounded,
                  iconColor: AppColors.error,
                  title: 'Watch to Learn (Free Videos)',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(0);
                    if (onScrollToVideos != null) onScrollToVideos!();
                  },
                ),

                _DrawerTile(
                  icon: Icons.folder_copy_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'Free Study Materials & DPP',
                  onTap: () {
                    Navigator.pop(context);
                    AppNavigator.push(context, const StudyMaterialsScreen());
                  },
                ),

                const Divider(height: 24, indent: 8, endIndent: 8),

                _SectionTitle('ROOTS EXCLUSIVE', isDark: isDark),

                _DrawerTile(
                  icon: Icons.stars_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'RSAT 2025 Scholarship',
                  badgeText: '100% Aid',
                  badgeColor: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    AppNavigator.push(
                      context,
                      const AcademicCounselingScreen(initialStream: 'RSAT 100% Scholarship Test'),
                    );
                  },
                ),

                _DrawerTile(
                  icon: Icons.support_agent_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  title: 'Free 1-on-1 Counseling',
                  onTap: () {
                    Navigator.pop(context);
                    AppNavigator.push(context, const AcademicCounselingScreen());
                  },
                ),

                _DrawerTile(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Meet Our Expert Faculty',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(0);
                    if (onScrollToTeam != null) onScrollToTeam!();
                  },
                ),

                _DrawerTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Toppers Hall of Fame',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(0);
                    if (onScrollToToppers != null) onScrollToToppers!();
                  },
                ),

                const Divider(height: 24, indent: 8, endIndent: 8),

                _SectionTitle('HELP & CONTACT', isDark: isDark),

                _DrawerTile(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.error,
                  title: 'Ludhiana Offline Center',
                  subtitle: 'Gill Rd, Opp. ITI College',
                  onTap: () {
                    Navigator.pop(context);
                    AppNavigator.push(context, const OfflineCenterScreen());
                  },
                ),

                _DrawerTile(
                  icon: Icons.call_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Call Support (+91 98775-15330)',
                  onTap: () {
                    Navigator.pop(context);
                    AppNavigator.push(context, const OfflineCenterScreen());
                  },
                ),

                _DrawerTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: Colors.grey,
                  title: 'Frequently Asked Questions',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(0);
                    if (onScrollToFaq != null) onScrollToFaq!();
                  },
                ),

                _DrawerTile(
                  icon: Icons.person_rounded,
                  iconColor: AppColors.primary,
                  title: 'My Profile & Settings',
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateTab != null) onNavigateTab!(4);
                  },
                ),
              ],
            ),
          ),

          // 4. Drawer Footer (Version & Logout)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.grey.shade50,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Roots Classes App v2.4.0',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Made with ❤️ in Punjab',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (isAuthenticated)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogoutConfirmation(context, auth);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.outfit(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login_rounded, size: 16, color: AppColors.primary),
                    label: Text(
                      'Sign In',
                      style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showLogoutConfirmation(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from Roots Classes?',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}


class _DrawerHeader extends StatelessWidget {
  final bool isAuthenticated;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userTarget;
  final bool isDark;
  final VoidCallback onLoginPressed;

  const _DrawerHeader({
    required this.isAuthenticated,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userTarget,
    required this.isDark,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1628), // Website deep navy
            Color(0xFF005BD6), // Saturated blue
            Color(0xFF0078FF), // Website electric royal blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: isAuthenticated
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : const AppLogo(iconSize: 32, showTagline: false, isCompact: true),
                ),
              ),

              // Close drawer icon
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (isAuthenticated) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 19),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              userTarget,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (userEmail.isNotEmpty || userPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                userEmail.isNotEmpty ? userEmail : userPhone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ] else ...[
            Text(
              'Welcome, Aspirant! 🚀',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in for RSAT scholarship, live tests & personalized batches.',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(Icons.login_rounded, size: 17),
                label: Text(
                  'Login / Register',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                onPressed: onLoginPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickStatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  const _QuickStatPill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 12, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingPressable(
      onTap: onTap,
      lowerBound: 0.97,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText!,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


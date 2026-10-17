import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../auth/login_screen.dart';
import '../../widgets/app_logo.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onScrollToPrograms;
  final VoidCallback? onScrollToTeam;
  final VoidCallback? onScrollToVideos;

  const HomeHeader({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
    this.onScrollToPrograms,
    this.onScrollToTeam,
    this.onScrollToVideos,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isAuthenticated = auth.isAuthenticated;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Mobile Drawer toggle if drawer available
            if (!isDesktop && onOpenDrawer != null) ...[
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: onOpenDrawer,
                tooltip: 'Navigation Menu',
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.backgroundLight,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // App Logo
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (onNavigateTab != null) onNavigateTab!(0);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(iconSize: 34, showTagline: false, isCompact: true),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Desktop / Tablet Navigation Links
            if (isDesktop || isTablet)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NavLink(
                        label: 'Home',
                        isActive: true,
                        onTap: () => onNavigateTab?.call(0),
                      ),
                      const SizedBox(width: 6),
                      _NavLink(
                        label: 'Programs',
                        onTap: onScrollToPrograms ?? () => onNavigateTab?.call(1),
                      ),
                      const SizedBox(width: 6),
                      _NavLink(
                        label: 'Test Series',
                        onTap: () => onNavigateTab?.call(2),
                      ),
                      const SizedBox(width: 6),
                      _NavLink(
                        label: 'Our Team',
                        onTap: onScrollToTeam,
                      ),
                      const SizedBox(width: 6),
                      _NavLink(
                        label: 'Watch to Learn',
                        onTap: onScrollToVideos,
                      ),
                    ],
                  ),
                ),
              )
            else
              const Spacer(),

            // Right Action Items (Search, Notification, Profile / Login)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Notification Icon
                IconButton(
                  tooltip: 'Announcements',
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 22),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'NEET & JEE 2026 Test Series Registrations are open!',
                          style: GoogleFonts.outfit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // User Profile / Sign In Pill
                if (isAuthenticated)
                  PopupMenuButton<String>(
                    tooltip: 'Profile & Account',
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    onSelected: (value) async {
                      if (value == 'profile') {
                        onNavigateTab?.call(4);
                      } else if (value == 'learnings') {
                        onNavigateTab?.call(3);
                      } else if (value == 'logout') {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Enrolled Student',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(height: 16),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 18),
                            const SizedBox(width: 10),
                            Text('My Profile', style: GoogleFonts.outfit(fontSize: 14)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'learnings',
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 18),
                            const SizedBox(width: 10),
                            Text('My Learnings', style: GoogleFonts.outfit(fontSize: 14)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              (user?.name.isNotEmpty ?? false)
                                  ? user!.name[0].toUpperCase()
                                  : 'S',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isDesktop || isTablet) ...[
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 110),
                              child: Text(
                                user?.name.split(' ').first ?? 'Student',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 16),
                    label: Text(
                      'Sign In',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavLink({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

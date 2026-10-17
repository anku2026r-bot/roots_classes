import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../counseling/academic_counseling_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Admissions Open for 2025-26 Batch',
      'desc': 'Class 10th, 11th & 12th Board & NEET/JEE foundation batches are now open. Apply today for up to 100% RSAT Scholarship!',
      'time': 'Just now',
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFFEF4444),
      'isRead': false,
      'category': 'Admissions',
    },
    {
      'id': '2',
      'title': 'All-India Mock Test 1 Live',
      'desc': 'JEE Main Physics Full Mock Test 1 is now open for all students. Test your readiness and get your predicted AIR.',
      'time': '2 hours ago',
      'icon': Icons.assignment_turned_in_rounded,
      'color': const Color(0xFF7C3AED),
      'isRead': false,
      'category': 'Tests',
    },
    {
      'id': '3',
      'title': 'Live Doubt Counter: Physics Mechanics',
      'desc': 'Akash Sir will host a special 1-on-1 problem-solving session today at 6:00 PM for enrolled students.',
      'time': 'Yesterday',
      'icon': Icons.video_camera_front_rounded,
      'color': const Color(0xFF2563EB),
      'isRead': true,
      'category': 'Classes',
    },
    {
      'id': '4',
      'title': 'New DPP Uploaded: Organic Chemistry',
      'desc': 'Daily practice sheet with step-wise video solutions is available under your Free Study Materials section.',
      'time': '2 days ago',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF10B981),
      'isRead': true,
      'category': 'Materials',
    },
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _selectedCategory == 'All'
        ? _notifications
        : _notifications.where((n) => n['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Notifications',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing notifications...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: ['All', 'Admissions', 'Tests', 'Classes', 'Materials'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Notification List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (mounted) setState(() {});
                },
                child: filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No notifications found', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isUnread = !(item['isRead'] as bool);
                        final color = item['color'] as Color;

                        return Container(
                          decoration: BoxDecoration(
                            color: isUnread
                                ? (isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.05))
                                : (isDark ? AppColors.surfaceDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isUnread
                                  ? color.withValues(alpha: 0.3)
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item['icon'] as IconData, color: color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: GoogleFonts.outfit(
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item['time'] as String,
                                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['desc'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                        height: 1.35,
                                      ),
                                    ),
                                    if (item['category'] == 'Admissions') ...[
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          AppNavigator.push(
                                            context,
                                            const AcademicCounselingScreen(),
                                          );
                                        },
                                        child: Text(
                                          'Apply for RSAT Scholarship →',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

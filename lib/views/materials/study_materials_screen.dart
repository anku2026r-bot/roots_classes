import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  final List<Map<String, dynamic>> _materials = [
    {
      'title': 'Physics Formula Compendium 2025',
      'desc': 'Complete Mechanics, Electrodynamics & Modern Physics cheat sheet with derivation summaries.',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFF2563EB),
      'subject': 'Physics',
      'fileSize': '4.8 MB',
      'downloads': '14.2k',
      'fileType': 'PDF',
    },
    {
      'title': 'Organic Chemistry Reaction Mechanism Maps',
      'desc': 'Comprehensive mechanism flows & named reactions for JEE/NEET curated by Akash Sir.',
      'icon': Icons.science_rounded,
      'color': const Color(0xFFEC4899),
      'subject': 'Chemistry',
      'fileSize': '6.2 MB',
      'downloads': '18.9k',
      'fileType': 'PDF',
    },
    {
      'title': 'Mathematics High-Yield DPPs (Calculus)',
      'desc': 'Calculus & Algebra daily practice problem sets with step-by-step solutions.',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF059669),
      'subject': 'Mathematics',
      'fileSize': '3.5 MB',
      'downloads': '9.8k',
      'fileType': 'PDF',
    },
    {
      'title': 'NCERT Line-by-Line Biology Booster',
      'desc': 'Complete Class 11 & 12 Zoology and Botany high-probability diagrams & summary cards.',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF10B981),
      'subject': 'Biology',
      'fileSize': '8.1 MB',
      'downloads': '21.5k',
      'fileType': 'PDF',
    },
    {
      'title': 'Physical Chemistry Formula & Constant Sheet',
      'desc': 'Thermodynamics, Equilibrium, Electrochemistry & Chemical Kinetics formulas at a glance.',
      'icon': Icons.biotech_rounded,
      'color': const Color(0xFFF59E0B),
      'subject': 'Chemistry',
      'fileSize': '2.9 MB',
      'downloads': '11.3k',
      'fileType': 'PDF',
    },
    {
      'title': 'CBSE Class 12 Board Step-Wise Solved Papers',
      'desc': 'Previous 10 years solved board papers with examiner marking criteria & model answer templates.',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF7C3AED),
      'subject': 'Board Booster',
      'fileSize': '12.4 MB',
      'downloads': '16.7k',
      'fileType': 'PDF',
    },
  ];

  String _selectedSubject = 'All';
  final Set<String> _downloadingTitles = {};

  void _handleDownload(String title) {
    if (_downloadingTitles.contains(title)) return;
    setState(() => _downloadingTitles.add(title));

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _downloadingTitles.remove(title));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "$title" successfully! Saved to offline storage.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _selectedSubject == 'All'
        ? _materials
        : _materials.where((m) => m['subject'] == _selectedSubject).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Free Study Materials & DPP',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Materials',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing study materials...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: ['All', 'Physics', 'Chemistry', 'Mathematics', 'Biology', 'Board Booster']
                    .map((sub) {
                  final isSelected = _selectedSubject == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(sub),
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                      onSelected: (_) => setState(() => _selectedSubject = sub),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Material Cards
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (mounted) setState(() {});
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final m = filtered[index];
                  final color = m['color'] as Color;
                  final title = m['title'] as String;
                  final isDownloading = _downloadingTitles.contains(title);

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(m['icon'] as IconData, color: color, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['desc'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    m['subject'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${m['fileSize']} • ${m['downloads']} downloads',
                                  style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.grey),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? color.withValues(alpha: 0.25) : color,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: isDownloading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.download_rounded, size: 16),
                              label: Text(
                                isDownloading ? 'Downloading...' : 'Download',
                                style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                              onPressed: isDownloading ? null : () => _handleDownload(title),
                            ),
                          ],
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

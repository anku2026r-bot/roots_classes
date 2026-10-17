import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class VideoQualityScreen extends StatefulWidget {
  final String currentQuality;

  const VideoQualityScreen({
    super.key,
    required this.currentQuality,
  });

  @override
  State<VideoQualityScreen> createState() => _VideoQualityScreenState();
}

class _VideoQualityScreenState extends State<VideoQualityScreen> {
  late String _selected;

  final List<Map<String, String>> _options = [
    {
      'title': 'Auto (Recommended)',
      'desc': 'Adjusts automatically based on your network speed (consumes 150 - 600 MB/hr)',
      'value': 'Auto (Adapts to Speed)',
      'badge': 'Recommended',
    },
    {
      'title': 'Standard (480p)',
      'desc': 'Saves mobile data while keeping board text and equations clear (~250 MB/hr)',
      'value': 'Standard (480p - Saves Data)',
      'badge': 'Data Saver',
    },
    {
      'title': 'High (720p)',
      'desc': 'Crystal-clear lecture visuals and diagrams (~650 MB/hr)',
      'value': 'High (720p - Recommended)',
      'badge': 'HD',
    },
    {
      'title': 'Full HD (1080p)',
      'desc': 'Maximum classroom fidelity for large tablet or desktop displays (~1.4 GB/hr)',
      'value': 'Full HD (1080p)',
      'badge': 'Full HD',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentQuality;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Streaming Quality',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Preference',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing quality preferences...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) setState(() => _selected = widget.currentQuality);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 350));
            if (mounted) setState(() => _selected = widget.currentQuality);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hd_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Choose your default video playback resolution across all concept lectures and revision sessions.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Quality Level',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ..._options.map((opt) {
              final isSelected = _selected.contains(opt['value']!.split(' ')[0]);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Radio<String>(
                    value: opt['value']!,
                    // ignore: deprecated_member_use
                    groupValue: _selected,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selected = val);
                      }
                    },
                  ),
                  title: Row(
                    children: [
                      Text(
                        opt['title']!,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          opt['badge']!,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      opt['desc']!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.3,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() => _selected = opt['value']!);
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                AppNavigator.pop(context, _selected);
              },
              child: Text(
                'Save Quality Preference',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

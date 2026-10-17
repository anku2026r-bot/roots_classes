import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

enum BadgeType {
  free,
  enrolled,
  purchased,
  locked,
  live,
  category,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? icon;

    switch (type) {
      case BadgeType.free:
        bg = AppColors.successLight;
        fg = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case BadgeType.enrolled:
      case BadgeType.purchased:
        bg = const Color(0xFFE0F2FE); // Light sky
        fg = const Color(0xFF0284C7); // Sky 600
        icon = Icons.verified_rounded;
        break;
      case BadgeType.locked:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.lock_outline_rounded;
        break;
      case BadgeType.live:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        icon = Icons.fiber_manual_record_rounded;
        break;
      case BadgeType.category:
        bg = const Color(0xFFEEF2FF); // Indigo 50
        fg = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

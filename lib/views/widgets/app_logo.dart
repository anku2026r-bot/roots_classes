import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showTagline;
  final bool isCompact;

  const AppLogo({
    super.key,
    this.iconSize = 56,
    this.showTagline = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Icon Emblem
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.08),
              child: Image.asset(
                'assets/images/roots_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: iconSize * 0.54,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ROOTS ',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                ),
              ),
              Text(
                'CLASSES',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          if (showTagline) ...[
            const SizedBox(height: 4),
            Text(
              AppStrings.appTagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

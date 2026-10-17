import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = Validators.evaluatePassword(password);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color color;
    if (strength.score >= 0.8) {
      color = AppColors.success;
    } else if (strength.score >= 0.6) {
      color = AppColors.accent;
    } else if (strength.score >= 0.4) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Progress Meter & Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.score,
                  minHeight: 5,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Criteria Checklist
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _buildCriterionItem('8+ chars', strength.hasMinLength, isDark),
            _buildCriterionItem('Uppercase (A-Z)', strength.hasUppercase, isDark),
            _buildCriterionItem('Number (0-9)', strength.hasDigit, isDark),
            _buildCriterionItem('Special symbol', strength.hasSpecialChar, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildCriterionItem(String label, bool isMet, bool isDark) {
    final activeColor = isMet ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 13,
          color: activeColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            color: activeColor,
          ),
        ),
      ],
    );
  }
}

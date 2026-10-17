import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Brand Colors (Exact rootsclasses.in CSS identity)
  static const Color primary = Color(0xFF0078FF); // Website Royal Blue (#0078FF)
  static const Color primaryLight = Color(0xFF3B95FF);
  static const Color primaryDark = Color(0xFF005BD6);
  static const Color accent = Color(0xFFFB0500); // Website Crimson Red (#FB0500)
  static const Color accentLight = Color(0xFFFF3B38);

  // Exact Brand Palette
  static const Color brandBlue = Color(0xFF0078FF);
  static const Color brandRed = Color(0xFFFB0500);
  static const Color brandYellow = Color(0xFFFFCF5C);
  static const Color brandGreen = Color(0xFF00B074);
  static const Color whatsapp = Color(0xFF25D366);

  // Neutral Colors (Light - matching clean white website)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0A1628); // Website dark heading (#0A1628)
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color inputFillLight = Color(0xFFF1F5F9); // Slate 100

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0A1628); // Website dark navy
  static const Color surfaceDark = Color(0xFF132238);
  static const Color cardDark = Color(0xFF1B2D4A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF293E60);
  static const Color inputFillDark = Color(0xFF1B2D4A);

  // Status Colors
  static const Color success = Color(0xFF00B074);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFFB0500);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0078FF);

  // Gradients matching rootsclasses.in
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0078FF), Color(0xFF005BD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFB0500), Color(0xFFFF3B38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

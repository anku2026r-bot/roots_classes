import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';
import '../../core/utils/app_navigator.dart';
import 'email_verification_help_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyWithCode() async {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit verification code.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await auth.verifyEmail(code: code);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? 'Email successfully verified!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _handleCheckStatus() async {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    // Refresh user status
    await auth.refreshUserStatus();

    if (!mounted) return;

    if (auth.isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Navigate to dedicated verification status page
      _openVerificationStatusPage();
    }
  }

  void _openVerificationStatusPage() {
    AppNavigator.push(
      context,
      const EmailVerificationHelpScreen(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final email = auth.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: Icon(
              Icons.logout_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_rounded,
                        color: AppColors.accent,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    AppStrings.verifyEmailTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      children: [
                        const TextSpan(text: 'We have dispatched a verification email to\n'),
                        TextSpan(
                          text: email,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text: '.\nPlease enter your 6-digit code below or click the link in your email.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error Banner
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: GoogleFonts.outfit(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: auth.clearMessages,
                            child: const Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 6-digit Verification Code Input
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: GoogleFonts.outfit(
                        letterSpacing: 6,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Code Button
                  CustomButton(
                    text: 'Confirm Code & Continue',
                    isLoading: auth.isLoading,
                    onPressed: _handleVerifyWithCode,
                  ),
                  const SizedBox(height: 12),

                  // Check Status Button
                  OutlinedButton.icon(
                    onPressed: _handleCheckStatus,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      AppStrings.checkStatusButton,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resend Code
                  Center(
                    child: TextButton(
                      onPressed: auth.verificationCooldown > 0 ? null : auth.resendVerificationEmail,
                      child: Text(
                        auth.verificationCooldown > 0
                            ? 'Resend email in ${auth.verificationCooldown}s'
                            : AppStrings.resendVerificationButton,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: auth.verificationCooldown > 0
                              ? (isDark ? Colors.white38 : Colors.black38)
                              : (isDark ? AppColors.accentLight : AppColors.accent),
                        ),
                      ),
                    ),
                  ),

                  // Switch Account
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: Text(
                        AppStrings.changeAccount,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

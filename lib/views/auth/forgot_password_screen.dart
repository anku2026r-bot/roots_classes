import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_bar.dart';

enum ForgotPasswordStep {
  email,
  otp,
  newPassword,
  completed,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _otpFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  String _currentPasswordInput = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // Step 1: Send OTP
  Future<void> _handleSendOtp() async {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    final success = await auth.sendOtp(_emailController.text.trim());
    if (mounted && success) {
      setState(() {
        _currentStep = ForgotPasswordStep.otp;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? 'OTP sent to your email'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Step 2: Verify OTP
  Future<void> _handleVerifyOtp() async {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    if (!_otpFormKey.currentState!.validate()) {
      return;
    }

    final success = await auth.verifyOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (mounted && success) {
      setState(() {
        _currentStep = ForgotPasswordStep.newPassword;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? 'OTP verified successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Step 3: Reset Password
  Future<void> _handleResetPassword() async {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    final success = await auth.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (mounted && success) {
      setState(() {
        _currentStep = ForgotPasswordStep.completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            size: 20,
          ),
          onPressed: () {
            auth.clearMessages();
            if (_currentStep == ForgotPasswordStep.otp) {
              setState(() => _currentStep = ForgotPasswordStep.email);
            } else if (_currentStep == ForgotPasswordStep.newPassword) {
              setState(() => _currentStep = ForgotPasswordStep.otp);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  _buildStepIndicator(isDark),
                  const SizedBox(height: 28),

                  // Emblem Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: (_currentStep == ForgotPasswordStep.completed
                                ? AppColors.success
                                : AppColors.primary)
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStepIcon(),
                        color: _currentStep == ForgotPasswordStep.completed
                            ? AppColors.success
                            : AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _getStepTitle(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    _getStepSubtitle(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
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
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Dynamic Step Form
                  if (_currentStep == ForgotPasswordStep.email)
                    _buildEmailForm(auth)
                  else if (_currentStep == ForgotPasswordStep.otp)
                    _buildOtpForm(auth, isDark)
                  else if (_currentStep == ForgotPasswordStep.newPassword)
                    _buildNewPasswordForm(auth)
                  else
                    _buildCompletedView(),

                  const SizedBox(height: 20),

                  // Back to Login Link
                  if (_currentStep != ForgotPasswordStep.completed)
                    TextButton.icon(
                      onPressed: () {
                        auth.clearMessages();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      label: Text(
                        AppStrings.backToLogin,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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

  // Visual Step Progress Bar
  Widget _buildStepIndicator(bool isDark) {
    final steps = [
      {'num': '1', 'title': 'Email'},
      {'num': '2', 'title': 'OTP'},
      {'num': '3', 'title': 'Reset'},
    ];

    int activeIdx = 0;
    if (_currentStep == ForgotPasswordStep.otp) activeIdx = 1;
    if (_currentStep == ForgotPasswordStep.newPassword) activeIdx = 2;
    if (_currentStep == ForgotPasswordStep.completed) activeIdx = 3;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final isPast = (index ~/ 2) < activeIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isPast
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.black12),
            ),
          );
        }

        final stepIdx = index ~/ 2;
        final isCurrent = stepIdx == activeIdx;
        final isDone = stepIdx < activeIdx;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.primary
                    : isCurrent
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                border: Border.all(
                  color: (isDone || isCurrent)
                      ? AppColors.primary
                      : (isDark ? Colors.white24 : Colors.black26),
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        steps[stepIdx]['num']!,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? AppColors.primary
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Step 1: Email Form
  Widget _buildEmailForm(AuthController auth) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: AppStrings.emailLabel,
            hint: 'rahul@gmail.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmail,
            onSubmitted: (_) => _handleSendOtp(),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send OTP',
            icon: Icons.send_rounded,
            isLoading: auth.isLoading,
            onPressed: _handleSendOtp,
          ),
        ],
      ),
    );
  }

  // Step 2: OTP Verification Form
  Widget _buildOtpForm(AuthController auth, bool isDark) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Email badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _emailController.text.trim(),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    auth.clearMessages();
                    setState(() => _currentStep = ForgotPasswordStep.email);
                  },
                  child: Text(
                    'Change',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6-digit OTP Field
          CustomTextField(
            label: 'Enter 6-Digit OTP',
            hint: '523841',
            controller: _otpController,
            focusNode: _otpFocus,
            prefixIcon: Icons.pin_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the OTP sent to your email';
              }
              if (val.trim().length < 4) {
                return 'Enter a valid OTP';
              }
              return null;
            },
            onSubmitted: (_) => _handleVerifyOtp(),
          ),
          const SizedBox(height: 12),

          // Resend OTP Countdown
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: auth.resetCooldown > 0 ? null : _handleSendOtp,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                auth.resetCooldown > 0
                    ? 'Resend OTP in ${auth.resetCooldown}s'
                    : 'Resend OTP',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: auth.resetCooldown > 0 ? Colors.grey : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Verify OTP Button
          CustomButton(
            text: 'Verify OTP',
            icon: Icons.check_circle_outline_rounded,
            isLoading: auth.isLoading,
            onPressed: _handleVerifyOtp,
          ),
        ],
      ),
    );
  }

  // Step 3: New Password Form
  Widget _buildNewPasswordForm(AuthController auth) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'New Password',
            hint: 'Min. 6 characters',
            controller: _newPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: Validators.validatePassword,
            onChanged: (val) => setState(() => _currentPasswordInput = val),
            onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),
          const SizedBox(height: 8),
          PasswordStrengthBar(password: _currentPasswordInput),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirm New Password',
            hint: 'Re-enter your new password',
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            prefixIcon: Icons.lock_reset_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please confirm your new password';
              }
              if (val != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onSubmitted: (_) => _handleResetPassword(),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Reset Password',
            icon: Icons.lock_reset_rounded,
            isLoading: auth.isLoading,
            onPressed: _handleResetPassword,
          ),
        ],
      ),
    );
  }

  // Completed State View
  Widget _buildCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
              const SizedBox(height: 12),
              Text(
                'Password Reset Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You can now log in to Roots Classes with your new password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Login Now',
          icon: Icons.login_rounded,
          onPressed: () {
            context.read<AuthController>().clearMessages();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  IconData _getStepIcon() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return Icons.lock_reset_rounded;
      case ForgotPasswordStep.otp:
        return Icons.mark_email_read_rounded;
      case ForgotPasswordStep.newPassword:
        return Icons.key_rounded;
      case ForgotPasswordStep.completed:
        return Icons.task_alt_rounded;
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Forgot Password';
      case ForgotPasswordStep.otp:
        return 'Verify OTP';
      case ForgotPasswordStep.newPassword:
        return 'Set New Password';
      case ForgotPasswordStep.completed:
        return 'Success!';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Enter your registered email address and we will send you a 6-digit verification OTP.';
      case ForgotPasswordStep.otp:
        return 'An OTP has been dispatched to your email. Please enter the 6-digit code below (valid for 10 minutes).';
      case ForgotPasswordStep.newPassword:
        return 'Please enter and confirm your new secure password.';
      case ForgotPasswordStep.completed:
        return 'Your password has been updated securely. Proceed to sign in.';
    }
  }
}

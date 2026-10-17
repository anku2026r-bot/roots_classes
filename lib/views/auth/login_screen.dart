import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_navigator.dart';
import '../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Pre-fill remembered email if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.rememberedEmail.isNotEmpty) {
        _emailController.text = auth.rememberedEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
    if (step == 1) {
      Future.delayed(const Duration(milliseconds: 380), () {
        if (mounted) {
          _passwordFocusNode.requestFocus();
        }
      });
    }
  }

  void _handleContinueToPassword() {
    final auth = context.read<AuthController>();
    auth.clearMessages();

    if (_emailFormKey.currentState?.validate() ?? false) {
      _goToStep(1);
    }
  }

  Future<void> _handleLogin() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    auth.clearMessages();

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final name = auth.currentUser?.name ?? 'Student';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Successful! Welcome, $name.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      AppNavigator.pushAndRemoveUntil(
        context,
        const HomeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) {
          _goToStep(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo
                    const AppLogo(iconSize: 60),
                    const SizedBox(height: 24),

                    // Multi-Step Progress Indicator Header
                    _buildStepIndicator(isDark),
                    const SizedBox(height: 24),

                    // Error Banner (if any)
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
                      const SizedBox(height: 16),
                    ],

                    // Multi-Step Content View
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _currentStep == 0
                          ? _buildStepOne(isDark, auth)
                          : _buildStepTwo(isDark, auth),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Visual Stepper Header
  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Step 1 Chip
          _buildStepNode(
            stepNumber: 1,
            title: 'Account',
            isActive: _currentStep == 0,
            isCompleted: _currentStep > 0,
            isDark: isDark,
            onTap: () {
              if (_currentStep > 0) _goToStep(0);
            },
          ),

          // Connecting Line
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _currentStep > 0
                    ? AppColors.primary
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Step 2 Chip
          _buildStepNode(
            stepNumber: 2,
            title: 'Security',
            isActive: _currentStep == 1,
            isCompleted: false,
            isDark: isDark,
            onTap: () {
              if (_emailFormKey.currentState?.validate() ?? false) {
                _goToStep(1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = isDark ? Colors.white38 : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : (isActive ? activeColor : (isDark ? Colors.white10 : Colors.grey.shade200)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : (isActive ? activeColor : Colors.transparent),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        '$stepNumber',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: (isActive || isCompleted)
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Account Identifier (Email or Student ID)
  Widget _buildStepOne(bool isDark, AuthController auth) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting Header
          Text(
            AppStrings.welcomeBack,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 1 of 2: Enter your registered email address or student account.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Quick account chip if remembered
          if (auth.rememberedEmail.isNotEmpty && _emailController.text != auth.rememberedEmail) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _emailController.text = auth.rememberedEmail;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent: ${auth.rememberedEmail}',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Use',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email Field
          CustomTextField(
            label: AppStrings.emailLabel,
            hint: AppStrings.emailHint,
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
            onSubmitted: (_) => _handleContinueToPassword(),
          ),
          const SizedBox(height: 28),

          // Next Step Button
          CustomButton(
            text: 'Continue to Password →',
            onPressed: _handleContinueToPassword,
          ),
          const SizedBox(height: 24),

          // Sign Up Navigation Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.noAccountPrompt,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  auth.clearMessages();
                  AppNavigator.push(
                    context,
                    const SignUpScreen(),
                  );
                },
                child: Text(
                  AppStrings.signUpNow,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 2: Security & Password Verification
  Widget _buildStepTwo(bool isDark, AuthController auth) {
    final emailText = _emailController.text.trim();

    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Account Badge Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    emailText.isNotEmpty ? emailText[0].toUpperCase() : 'S',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emailText,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Roots Classes Student Account',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _goToStep(0),
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: Text(
                    'Change',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Password Step Header
          Text(
            'Enter Your Password',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 2 of 2: Confirm your security password to log in.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 22),

          // Password Field
          CustomTextField(
            label: AppStrings.passwordLabel,
            hint: AppStrings.passwordHint,
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: Validators.validateLoginPassword,
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 14),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me Checkbox
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: auth.rememberMe,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (val) {
                          auth.setRememberMe(val ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          auth.setRememberMe(!auth.rememberMe);
                        },
                        child: Text(
                          AppStrings.rememberMe,
                          overflow: TextOverflow.ellipsis,
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
              const SizedBox(width: 8),

              // Forgot Password Link
              Flexible(
                child: TextButton(
                  onPressed: () {
                    auth.clearMessages();
                    AppNavigator.push(
                      context,
                      const ForgotPasswordScreen(),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.forgotPassword,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Action Buttons: Back + Sign In
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _goToStep(0),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: AppStrings.loginButton,
                  isLoading: auth.isLoading,
                  onPressed: _handleLogin,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Switch Account Option
          Center(
            child: TextButton(
              onPressed: () {
                _passwordController.clear();
                _goToStep(0);
              },
              child: Text(
                'Log in with a different account',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

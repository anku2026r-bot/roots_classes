import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  final SessionService _sessionService;

  AuthController({
    required AuthService authService,
    required SessionService sessionService,
  })  : _authService = authService,
        _sessionService = sessionService;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _errorMessage;
  String? _successMessage;
  bool _rememberMe = false;
  String _rememberedEmail = '';
  
  Timer? _resetCooldownTimer;
  int _resetCooldown = 0;

  Timer? _verificationCooldownTimer;
  int _verificationCooldown = 0;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get rememberMe => _rememberMe;
  String get rememberedEmail => _rememberedEmail;
  int get resetCooldown => _resetCooldown;
  int get verificationCooldown => _verificationCooldown;

  /// Initializes session and auto-login state
  Future<void> initialize() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      _rememberMe = _sessionService.getRememberMe();
      _rememberedEmail = _sessionService.getRememberedEmail() ?? '';

      if (_sessionService.hasActiveSession()) {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
      }

      // Do not auto-force user on boot so Login page opens first
    } catch (e) {
      _errorMessage = 'Failed to restore session. Please log in.';
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  /// Instant login with any credentials entered
  void setAnyUser({String? name, String? email}) {
    final effectiveEmail = email != null && email.trim().isNotEmpty
        ? email.trim()
        : 'student@rootsclasses.com';
    final effectiveName = name != null && name.trim().isNotEmpty
        ? name.trim()
        : 'Student';

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: effectiveName,
      email: effectiveEmail,
      isEmailVerified: true,
      role: 'Student',
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }


  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Sign In with real email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'Login failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'A network or system error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sign Up with student details matching backend API
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? currentClass,
    String? interestedCourse,
    String? dateofBirth,
    String? gender,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        currentClass: currentClass,
        interestedCourse: interestedCourse,
        dateofBirth: dateofBirth,
        gender: gender,
        address: address,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'Registration failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during account creation: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Step 1: Send OTP to email for password reset
  Future<bool> sendOtp(String email) async {
    if (_resetCooldown > 0) {
      _errorMessage = 'Please wait $_resetCooldown seconds before resending OTP.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.sendOtp(email);
      if (result.isSuccess) {
        _successMessage = result.message;
        _startResetCooldown(60);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'Failed to send OTP.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error while requesting OTP: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Step 2: Verify OTP
  Future<bool> verifyOtp({required String email, required String otp}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.verifyOtp(email: email, otp: otp);
      if (result.isSuccess) {
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'OTP verification failed.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error verifying OTP: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Step 3: Reset Password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (result.isSuccess) {
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'Password reset failed.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error resetting password: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sends password reset link/email (delegates to sendOtp)
  Future<bool> sendPasswordReset(String email) async {
    return sendOtp(email);
  }

  /// Verifies current user's email with code or confirmation
  Future<bool> verifyEmail({required String code}) async {
    if (_currentUser == null) {
      _errorMessage = 'No authenticated user to verify.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.verifyEmail(
        email: _currentUser!.email,
        code: code,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message ?? 'Verification failed.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Verification failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Resends email verification code
  Future<bool> resendVerificationEmail() async {
    if (_currentUser == null) return false;
    if (_verificationCooldown > 0) {
      _errorMessage = 'Please wait $_verificationCooldown seconds before resending.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.resendVerificationEmail(_currentUser!.email);
      if (result.isSuccess) {
        _successMessage = result.message;
        _startVerificationCooldown(60);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to resend verification: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Reloads / refreshes current user status (e.g. to check if verified)
  Future<void> refreshUserStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Signs out user and clears session
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;
      _successMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (result.isSuccess) {
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update password: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Update student profile details
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? currentClass,
    String? interestedCourse,
    String? gender,
    String? address,
    String? dateofBirth,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    clearMessages();

    try {
      if (_currentUser == null) {
        final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = UserModel(
          id: newId,
          name: (name != null && name.trim().isNotEmpty) ? name.trim() : 'Student',
          email: (email != null && email.trim().isNotEmpty) ? email.trim() : 'student@rootsclasses.com',
          phone: phone,
          currentClass: currentClass,
          interestedCourse: interestedCourse,
          gender: gender,
          address: address,
          dateofBirth: dateofBirth,
          avatarUrl: avatarUrl,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
      } else {
        _currentUser = _currentUser!.copyWith(
          name: (name != null && name.trim().isNotEmpty) ? name.trim() : _currentUser!.name,
          email: (email != null && email.trim().isNotEmpty) ? email.trim() : _currentUser!.email,
          phone: phone ?? _currentUser!.phone,
          currentClass: currentClass ?? _currentUser!.currentClass,
          interestedCourse: interestedCourse ?? _currentUser!.interestedCourse,
          gender: gender ?? _currentUser!.gender,
          address: address ?? _currentUser!.address,
          dateofBirth: dateofBirth ?? _currentUser!.dateofBirth,
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        );
      }

      await _authService.saveUser(_currentUser!);
      final token = _sessionService.getSessionToken() ?? 'rc_token_${_currentUser!.id}';
      await _sessionService.saveSession(
        token: token,
        userId: _currentUser!.id,
        rememberMe: true,
        email: _currentUser!.email,
      );

      _successMessage = 'Profile details updated successfully!';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _startResetCooldown(int seconds) {
    _resetCooldown = seconds;
    _resetCooldownTimer?.cancel();
    _resetCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resetCooldown <= 1) {
        _resetCooldown = 0;
        timer.cancel();
      } else {
        _resetCooldown--;
      }
      notifyListeners();
    });
  }

  void _startVerificationCooldown(int seconds) {
    _verificationCooldown = seconds;
    _verificationCooldownTimer?.cancel();
    _verificationCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_verificationCooldown <= 1) {
        _verificationCooldown = 0;
        timer.cancel();
      } else {
        _verificationCooldown--;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _resetCooldownTimer?.cancel();
    _verificationCooldownTimer?.cancel();
    super.dispose();
  }
}

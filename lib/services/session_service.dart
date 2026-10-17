import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keySessionToken = 'rc_session_token';
  static const String _keyUserId = 'rc_user_id';
  static const String _keyRememberMe = 'rc_remember_me';
  static const String _keyRememberedEmail = 'rc_remembered_email';
  static const String _keySessionCreatedAt = 'rc_session_created_at';

  final SharedPreferences _prefs;

  SessionService(this._prefs);

  static Future<SessionService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionService(prefs);
  }

  /// Saves session data on successful authentication
  Future<void> saveSession({
    required String token,
    required String userId,
    required bool rememberMe,
    required String email,
  }) async {
    await _prefs.setString(_keySessionToken, token);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setBool(_keyRememberMe, rememberMe);
    await _prefs.setString(_keySessionCreatedAt, DateTime.now().toIso8601String());

    if (rememberMe) {
      await _prefs.setString(_keyRememberedEmail, email);
    } else {
      await _prefs.remove(_keyRememberedEmail);
    }
  }

  /// Returns current session token
  String? getSessionToken() => _prefs.getString(_keySessionToken);

  /// Returns active user ID
  String? getActiveUserId() => _prefs.getString(_keyUserId);

  /// Returns whether remember-me was chosen
  bool getRememberMe() => _prefs.getBool(_keyRememberMe) ?? false;

  /// Returns remembered email for auto-fill
  String? getRememberedEmail() => _prefs.getString(_keyRememberedEmail);

  /// Checks if current session is active and not expired (30-day token expiry)
  bool hasActiveSession() {
    final token = getSessionToken();
    final userId = getActiveUserId();
    final createdAtStr = _prefs.getString(_keySessionCreatedAt);

    if (token == null || userId == null || createdAtStr == null) {
      return false;
    }

    final createdAt = DateTime.tryParse(createdAtStr);
    if (createdAt == null) return false;

    // Session valid for 30 days
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays > 30) {
      clearSession();
      return false;
    }

    return true;
  }

  /// Clears active session on logout (preserves remembered email if user requested)
  Future<void> clearSession() async {
    final rememberMe = getRememberMe();
    final rememberedEmail = getRememberedEmail();

    await _prefs.remove(_keySessionToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySessionCreatedAt);

    if (!rememberMe) {
      await _prefs.remove(_keyRememberMe);
      await _prefs.remove(_keyRememberedEmail);
    } else if (rememberedEmail != null) {
      // Keep remembered email intact for subsequent login ease
      await _prefs.setString(_keyRememberedEmail, rememberedEmail);
      await _prefs.setBool(_keyRememberMe, true);
    }
  }
}

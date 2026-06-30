import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final _box = GetStorage();

  static const _keyLoginTimestamp = 'login_timestamp';
  static const _keyKeepLoggedIn = 'keep_logged_in';
  static const _keyUserId = 'user_id';
  static const _sessionDurationDays = 30;

  /// Save session after successful login
  static void saveSession({
    required String userId,
    required bool keepLoggedIn,
  }) {
    _box.write(_keyUserId, userId);
    _box.write(_keyKeepLoggedIn, keepLoggedIn);
    _box.write(_keyLoginTimestamp, DateTime.now().toIso8601String());
  }

  /// Returns true if a valid session exists (within 30 days)
  static bool isSessionValid() {
    final keepLoggedIn = _box.read<bool>(_keyKeepLoggedIn) ?? false;
    if (!keepLoggedIn) return false;

    final timestampStr = _box.read<String>(_keyLoginTimestamp);
    if (timestampStr == null) return false;

    final loginTime = DateTime.tryParse(timestampStr);
    if (loginTime == null) return false;

    final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
    return daysSinceLogin < _sessionDurationDays;
  }

  /// Update last activity timestamp
  static void refreshSession() {
    if (_box.read<bool>(_keyKeepLoggedIn) == true) {
      _box.write(_keyLoginTimestamp, DateTime.now().toIso8601String());
    }
  }

  /// Clear all session data (logout)
  static void clearSession() {
    _box.remove(_keyLoginTimestamp);
    _box.remove(_keyKeepLoggedIn);
    _box.remove(_keyUserId);
  }

  static String? get savedUserId => _box.read<String>(_keyUserId);
}

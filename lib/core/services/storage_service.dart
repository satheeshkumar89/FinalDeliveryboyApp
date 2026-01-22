import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing secure local storage of authentication data
class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyUserId = 'user_id';

  /// Save authentication data to local storage
  Future<void> saveAuthData({
    required String accessToken,
    String? phoneNumber,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (phoneNumber != null) {
      await prefs.setString(_keyPhoneNumber, phoneNumber);
    }
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  /// Get saved access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get saved phone number
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  /// Get saved user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = await getUserId();
    if (userId == null) return null;
    return {'id': userId};
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all authentication data (logout)
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyPhoneNumber);
    await prefs.remove(_keyUserId);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

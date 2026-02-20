import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  static const String _keyToken = 'auth_token';

  /// Saves the authentication token to local storage.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Retrieves the saved authentication token.
  /// Returns an empty string if no token exists.
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken) ?? '';
  }

  /// Clears the token (useful for logout).
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}

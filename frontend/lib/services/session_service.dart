// Stores and retrieves the JWT token and user info using shared_preferences so it persists across app restarts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // save token and user info after login
  static Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // get stored user info
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  // clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
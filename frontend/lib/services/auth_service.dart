// Handles all HTTP calls related to auth
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {

  // POST /api/auth/login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        // return the error message from backend e.g. 'Invalid username or password'
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      // network error, backend not running, wrong IP etc.
      return {'success': false, 'message': 'Cannot connect to server. Check your connection.'};
    }
  }

  // POST /api/auth/logout
  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
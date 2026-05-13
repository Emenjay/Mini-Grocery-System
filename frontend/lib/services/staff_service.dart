import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class StaffService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppState.token}',
  };

  // GET /api/users?search=&role=
  static Future<Map<String, dynamic>> getAllStaff({
    String search = '',
    String role = '',
  }) async {
    try {
      final queryParams = {
        if (search.isNotEmpty) 'search': search,
        if (role.isNotEmpty) 'role': role,
      };
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/api/users',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'users': data['users']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/users/:id/toggle-duty
  static Future<Map<String, dynamic>> toggleDuty(int userId) async {
    try {
      final url = '${AppConstants.baseUrl}/api/users/$userId/toggle-duty';
      print('Calling: $url'); // check this in Flutter console
      final response = await http.post(Uri.parse(url), headers: _headers);
      print(
        'Response: ${response.statusCode} ${response.body}',
      ); // check this too
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'is_on_duty': data['is_on_duty']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to toggle duty',
      };
    } catch (e) {
      print('Error: $e'); // check what error is thrown
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/users/:id
  static Future<Map<String, dynamic>> getStaffByID(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/users/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
          'attendance': data['attendance'],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/users
  static Future<Map<String, dynamic>> addStaff({
    required int roleID,
    required String username,
    required String password,
    required String fullName,
    String? contactNumber,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/users'),
        headers: _headers,
        body: jsonEncode({
          'roleID': roleID,
          'username': username,
          'password': password,
          'fullName': fullName,
          if (contactNumber != null) 'contactNumber': contactNumber,
          if (address != null) 'address': address,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'user': data['user']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to add staff',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PUT /api/users/:id
  static Future<Map<String, dynamic>> updateStaff({
    required int id,
    String? fullName,
    String? contactNumber,
    String? address,
    String? username,
    String? password,
    int? roleID,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (contactNumber != null) body['contactNumber'] = contactNumber;
      if (address != null) body['address'] = address;
      if (username != null) body['username'] = username;
      if (password != null) body['password'] = password;
      if (roleID != null) body['roleID'] = roleID;

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/users/$id'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PATCH /api/users/:id/deactivate
  static Future<Map<String, dynamic>> deactivateStaff(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/api/users/$id/deactivate'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to deactivate',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/users/roles - fetch roles for add staff dropdown
static Future<Map<String, dynamic>> getRoles() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/users/roles'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'roles': data['roles']};
    }
    return {'success': false, 'message': data['message'] ?? 'Failed to fetch roles'};
  } catch (e) {
    return {'success': false, 'message': 'Cannot connect to server.'};
  }
}
}

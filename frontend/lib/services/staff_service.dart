import 'dart:convert';
import 'dart:io';
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
      final uri = Uri.parse('${AppConstants.baseUrl}/api/users')
          .replace(queryParameters: queryParams);
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

  // POST /api/users - multipart/form-data because of optional profile picture
  static Future<Map<String, dynamic>> addStaff({
    required int roleID,
    required String username,
    required String password,
    required String fullName,
    String? contactNumber,
    String? address,
    File? profilePicture,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}/api/users'),
      );
      request.headers['Authorization'] = 'Bearer ${AppState.token}';

      // required fields
      request.fields['roleID']   = roleID.toString();
      request.fields['username'] = username;
      request.fields['password'] = password;
      request.fields['fullName'] = fullName;
      if (contactNumber != null) request.fields['contactNumber'] = contactNumber;
      if (address != null)       request.fields['address']       = address;

      // attach photo if provided
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to add staff'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PUT /api/users/:id - multipart/form-data to support optional profile picture upload
  // backend multer handles file save and deletes the old photo automatically
  static Future<Map<String, dynamic>> updateStaff({
    required int id,
    String? fullName,
    String? contactNumber,
    String? address,
    String? username,
    String? password,
    int? roleID,
    File? profilePicture, // pass File to upload new photo, null to keep existing
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/api/users/$id'),
      );
      request.headers['Authorization'] = 'Bearer ${AppState.token}';

      // only include fields that were provided
      if (fullName != null)      request.fields['fullName']      = fullName;
      if (contactNumber != null) request.fields['contactNumber'] = contactNumber;
      if (address != null)       request.fields['address']       = address;
      if (username != null)      request.fields['username']      = username;
      if (password != null)      request.fields['password']      = password;
      if (roleID != null)        request.fields['roleID']        = roleID.toString();

      // attach new profile picture if provided - backend deletes old one before saving new
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Failed to update'};
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
      return {'success': false, 'message': data['message'] ?? 'Failed to deactivate'};
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
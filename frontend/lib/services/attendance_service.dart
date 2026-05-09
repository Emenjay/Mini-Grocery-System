import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class AttendanceService {

  // GET /api/attendance/active - checks if cashier already has a running shift today
  // returns { hasActiveShift: bool, cashIn: double? }
  static Future<Map<String, dynamic>> getActiveShift() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/attendance/active'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to check active shift'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/attendance/start - starts cashier shift with cash-in amount
  static Future<Map<String, dynamic>> startShift(double cashIn) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/attendance/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
        body: jsonEncode({'cashIn': cashIn}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to start shift'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/attendance/end - ends cashier shift with cash-out amount
  static Future<Map<String, dynamic>> endShift(double cashOut) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/attendance/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
        body: jsonEncode({'cashOut': cashOut}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to end shift'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}
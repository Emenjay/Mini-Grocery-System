import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class InventoryService {

  // GET /api/inventory-dashboard/dashboard
  static Future<Map<String, dynamic>> getDashboardCounts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/inventory-dashboard/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['dashboard']};
      } else {
        // error message
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch dashboard'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}
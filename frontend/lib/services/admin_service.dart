import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

// AdminService handles admin-specific API calls, such as managing inventory and users.
class AdminService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppState.token}',
  };

  // GET /api/inventory - reuse product service endpoint
  static Future<Map<String, dynamic>> getAllProducts({
    String search = '',
    String category = '',
    String stockStatus = '',
    String sortName = '',
    String sortPrice = '',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
        if (stockStatus.isNotEmpty) 'stockStatus': stockStatus,
        if (sortName.isNotEmpty) 'sortName': sortName,
        if (sortPrice.isNotEmpty) 'sortPrice': sortPrice,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/api/inventory',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PUT /api/inventory/:id — update markup (admin only)
  static Future<Map<String, dynamic>> updateMarkup({
    required int productId,
    required double markupPercent,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/inventory/$productId'),
        headers: _headers,
        body: jsonEncode({'markupPrice': markupPercent}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update markup',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // DELETE /api/inventory/:id
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/inventory/$productId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}

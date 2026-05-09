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
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch dashboard'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // product methods

  // GET /api/inventory - fetch products with filters, search, and pagination
  static Future<Map<String, dynamic>> getProducts({
    String search = '',
    String category = '',
    String stockStatus = '',
    String expirationFilter = '',
    String sortName = '',
    String sortPrice = '',
    int page = 1,
    int limit = 20,
    bool all = false,
    bool recentlyAdded = false,
  }) async {
    try {
      // build query params from provided filters
      final queryParams = {
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
        if (stockStatus.isNotEmpty) 'stockStatus': stockStatus,
        if (expirationFilter.isNotEmpty) 'expirationFilter': expirationFilter,
        if (sortName.isNotEmpty) 'sortName': sortName,
        if (sortPrice.isNotEmpty) 'sortPrice': sortPrice,
        'page': page.toString(),
        'limit': limit.toString(),
        if (all) 'all': 'true',
        if (recentlyAdded) 'recentlyAdded': 'true',
      };

      final uri = Uri.parse('${AppConstants.baseUrl}/api/inventory')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'products': data['products'],
          'pagination': data['pagination'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch products'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // DELETE /api/inventory/:id - delete a product
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/inventory/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to delete product'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}
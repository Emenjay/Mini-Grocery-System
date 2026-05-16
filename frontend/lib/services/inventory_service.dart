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

  // GET /api/inventory?all=true — fetch all approved products for cashier POS
  // cashier only sees approved products (backend filters by role from JWT)
  static Future<Map<String, dynamic>> getCashierProducts({
    String search = '',
    String category = '',
  }) async {
    try {
      final queryParams = {
        'all': 'true', // no pagination for POS product list
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
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
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch products'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/inventory - add a new product
  static Future<Map<String, dynamic>> addProduct({
  required int categoryID,
  required String productName,
  required double basePrice,
  required int stockQuantity,
  String? description,
  String? unitMeasurement,
  DateTime? spoilageDate,
  bool? isFastMoving,
  DateTime? receivedDate,
}) async {
  try {
    final body = {
      'categoryID': categoryID,
      'productName': productName,
      'basePrice': basePrice,
      'stockQuantity': stockQuantity,
      if (description != null) 'description': description,
      if (unitMeasurement != null) 'unitMeasurement': unitMeasurement,
      if (spoilageDate != null) 'spoilageDate': spoilageDate.toIso8601String().split('T').first,
      'isFastMoving': isFastMoving,
      if (receivedDate != null) 'receivedDate': receivedDate.toIso8601String().split('T').first,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/inventory'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppState.token}',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to add product'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Cannot connect to server.'};
  }
}

// PUT /api/inventory/:id - update product
static Future<Map<String, dynamic>> updateProduct({
  required int productId,
  String? productName,
  int? categoryID,
  String? description,
  double? basePrice,
  double? markupPrice,
  String? unitMeasurement,
  int? stockQuantity,
  DateTime? spoilageDate,
  bool? isFastMoving,
  DateTime? receivedDate,
}) async {
  try {
    final body = <String, dynamic>{};
    if (productName != null) body['productName'] = productName;
    if (categoryID != null) body['categoryID'] = categoryID;
    if (description != null) body['description'] = description;
    if (basePrice != null) body['basePrice'] = basePrice;
    if (markupPrice != null) body['markupPrice'] = markupPrice;
    if (unitMeasurement != null) body['unitMeasurement'] = unitMeasurement;
    if (stockQuantity != null) body['stockQuantity'] = stockQuantity;
    if (spoilageDate != null) body['spoilageDate'] = spoilageDate.toIso8601String().split('T').first;
    if (isFastMoving != null) body['isFastMoving'] = isFastMoving;
    if (receivedDate != null) body['receivedDate'] = receivedDate.toIso8601String().split('T').first;

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/api/inventory/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppState.token}',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to update product'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Cannot connect to server.'};
  }
}

  // GET /api/inventory/categories — fetch categories for dropdown
static Future<Map<String, dynamic>> getCategories() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/inventory/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppState.token}',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'categories': data['categories']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch categories'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Cannot connect to server.'};
  }
}
}
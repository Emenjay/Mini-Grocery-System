import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

// Service class for handling product-related API calls
class ProductService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppState.token}',
  };

  // GET /api/inventory
  // supports: search, category, page, limit, all, recentlyAdded
  static Future<Map<String, dynamic>> getAllProducts({
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

      // Build the URI with query parameters
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/api/inventory',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      final data = jsonDecode(response.body);
      // Check if the response is successful
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch products',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/inventory/categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/inventory/categories'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'categories': data['categories']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch categories',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/inventory
  static Future<Map<String, dynamic>> addProduct({
    required int categoryID,
    required String productName,
    required double basePrice,
    String? description,
    String? unitMeasurement, // e.g. "500 (g/kg)" or "1 (mL/L)"
    int stockQuantity = 0,
    String? spoilageDate, // yyyy-MM-dd
    String? receivedDate, // yyyy-MM-dd
    double? markupPercent, // 5.0 or 10.0
    bool isFastMoving = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/inventory'),
        headers: _headers,
        body: jsonEncode({
          'categoryID': categoryID,
          'productName': productName,
          'basePrice': basePrice,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (unitMeasurement != null && unitMeasurement.isNotEmpty)
            'unitMeasurement': unitMeasurement,
          'stockQuantity': stockQuantity,
          if (spoilageDate != null) 'spoilageDate': spoilageDate,
          if (receivedDate != null) 'receivedDate': receivedDate,
          if (markupPercent != null) 'markupPercent': markupPercent,
          'isFastMoving': isFastMoving,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'product': data['product']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to add product',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PUT /api/inventory/:id
  static Future<Map<String, dynamic>> updateProduct({
    required int productID,
    String? productName,
    int? categoryID,
    String? description,
    double? basePrice,
    double? markupPercent,
    String? unitMeasurement,
    int? stockQuantity,
    String? spoilageDate,
    String? receivedDate,
    bool? isFastMoving,
    String? packagingLabel,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (productName != null) body['productName'] = productName;
      if (categoryID != null) body['categoryID'] = categoryID;
      if (description != null) body['description'] = description;
      if (basePrice != null) body['basePrice'] = basePrice;
      if (markupPercent != null) body['markupPercent'] = markupPercent;
      if (unitMeasurement != null) body['unitMeasurement'] = unitMeasurement;
      if (stockQuantity != null) body['stockQuantity'] = stockQuantity;
      if (spoilageDate != null) body['spoilageDate'] = spoilageDate;
      if (receivedDate != null) body['receivedDate'] = receivedDate;
      if (isFastMoving != null) body['isFastMoving'] = isFastMoving;
      if (packagingLabel != null) body['packagingLabel'] = packagingLabel;

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/inventory/$productID'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update product',
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete product',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class CheckoutService {

  // POST /api/checkout/pause - saves the current cart as a paused cart on the backend
  // returns { pausedCartID, cartNo }
  static Future<Map<String, dynamic>> pauseCart(List<Map<String, dynamic>> cart, {required String cartNo}) async {
    try {
      // map POS cart items to the format backend expects: product_id and quantity only
      // backend resolves prices itself from the product table
      final cartPayload = cart.map((item) => {
        'product_id': item['product_id'],
        'quantity': item['quantity'],
      }).toList();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/checkout/pause'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
        body: jsonEncode({'cart': cartPayload,
                          'cartNo': cartNo,}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to pause cart'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/checkout/paused - fetch all paused carts for the logged-in cashier
  static Future<Map<String, dynamic>> getPausedCarts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/checkout/paused'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'carts': data['carts']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch paused carts'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/checkout/paused/:id - fetch a single paused cart with its items for resuming
  static Future<Map<String, dynamic>> getPausedCartById(int pausedCartId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/checkout/paused/$pausedCartId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'cart': data['cart']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch paused cart'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // DELETE /api/checkout/paused/:id - discard a paused cart from the pending list
  static Future<Map<String, dynamic>> discardPausedCart(int pausedCartId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/checkout/paused/$pausedCartId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to discard paused cart'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // POST /api/checkout - process the transaction and deduct stock
  // cart items only need product_id and quantity — backend resolves prices
  // returns { cartNo, transactionID, totalAmount, changeAmount, warnings }
  static Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> cartItems,
    required String paymentMethod,
    required double amountReceived,
    required String cartNo, 
    String? referenceNumber,
  }) async {
    try {
      // map POS cart items to what backend expects — product_id and quantity only
      final cartPayload = cartItems.map((item) => {
        'product_id': item['product_id'],
        'quantity': item['quantity'],
      }).toList();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
        body: jsonEncode({
          'cart': cartPayload,
          'cartNo': cartNo,
          'payment': {
            'payment_method': paymentMethod,
            'amount_received': amountReceived,
            if (referenceNumber != null) 'reference_number': referenceNumber,
          },
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Checkout failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class TransactionService {

  // GET /api/checkout - fetch transaction history split into recent and previous
  static Future<Map<String, dynamic>> getTransactionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'recent': data['recent'],
          'previous': data['previous'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch transactions'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // GET /api/checkout/:id - fetch full transaction detail for receipt viewing
  static Future<Map<String, dynamic>> getTransactionDetail(int transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/checkout/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['receipt']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch transaction'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}
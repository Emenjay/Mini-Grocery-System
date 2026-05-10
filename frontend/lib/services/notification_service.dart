import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class NotificationService {

  // GET /api/notification - fetch all notifications (supports ?unread=true)
  static Future<Map<String, dynamic>> getAll({bool unreadOnly = false}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/api/notification')
          .replace(queryParameters: unreadOnly ? {'unread': 'true'} : {});

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
          'notifications': data['notifications'],
          'unreadCount': data['unreadCount'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch notifications'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PATCH /api/notification/:id/read - mark a single notification as read
  static Future<bool> markOneRead(int notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/api/notification/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // PATCH /api/notification/read-all - mark all notifications as read
  static Future<bool> markAllRead() async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/api/notification/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // DELETE /api/notification/:id - delete a single notification
  static Future<bool> deleteOne(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/notification/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
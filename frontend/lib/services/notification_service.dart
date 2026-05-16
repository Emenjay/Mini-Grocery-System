import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/app_state.dart';

class NotificationService {
  static StreamController<Map<String, dynamic>>? _controller;
  static http.Client? _client;
  // flag to prevent reconnect loop after intentional disconnect (logout)
  static bool _intentionalDisconnect = false;

  // stream that the UI listens to for real-time notifications
  static Stream<Map<String, dynamic>> get notificationStream {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  // reset the disconnect flag — call before connect() on re-login
  static void resetForReconnect() {
    _intentionalDisconnect = false;
  }

  // connect to SSE stream — call this after admin logs in
  static Future<void> connect() async {
    // don't reconnect if we intentionally disconnected (logout)
    if (_intentionalDisconnect) return;

    disconnect(
      intentional: false,
    ); // close any stale connection without setting the flag
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _client = http.Client();

    try {
      final request = http.Request(
        'GET',
        Uri.parse('${AppConstants.baseUrl}/api/notification/stream'),
      );
      request.headers['Authorization'] = 'Bearer ${AppState.token}';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await _client!.send(request);

      // listen to the stream line by line and parse SSE events
      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              // SSE data lines start with 'data: '
              if (line.startsWith('data: ')) {
                final jsonStr = line.substring(6); // strip 'data: ' prefix
                try {
                  final notification =
                      jsonDecode(jsonStr) as Map<String, dynamic>;
                  _controller?.add(notification);
                } catch (_) {
                  // ignore malformed lines (e.g. heartbeat pings that aren't JSON)
                }
              }
            },
            onDone: () {
              // connection closed by server — retry after 5 seconds unless intentional
              if (!_intentionalDisconnect) {
                Future.delayed(const Duration(seconds: 5), connect);
              }
            },
            onError: (_) {
              // network error — retry after 5 seconds unless intentional
              if (!_intentionalDisconnect) {
                Future.delayed(const Duration(seconds: 5), connect);
              }
            },
            cancelOnError: false,
          );
    } catch (e) {
      // connection failed — retry after 5 seconds unless intentional
      if (!_intentionalDisconnect) {
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }
  }

  // disconnect — pass intentional: true on logout to stop reconnect loop
  static void disconnect({bool intentional = true}) {
    if (intentional) _intentionalDisconnect = true;
    _client?.close();
    _client = null;
    _controller?.close();
    _controller = null;
  }

  // GET /api/notification - fetch all notifications (supports ?unread=true)
  static Future<Map<String, dynamic>> getAll({bool unreadOnly = false}) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/api/notification',
      ).replace(queryParameters: unreadOnly ? {'unread': 'true'} : {});

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
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch notifications',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // PATCH /api/notification/:id/read - mark a single notification as read
  static Future<bool> markOneRead(int notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '${AppConstants.baseUrl}/api/notification/$notificationId/read',
        ),
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

  // Russ's update aa
  // GET /api/notification/unread-count - get count of unread notifications
  static Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/notification/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppState.token}',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
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

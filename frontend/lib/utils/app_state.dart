// in-memory holder for the current session so any screen can access the token and user info without reading from storage every time
class AppState {
  static String? token;
  static Map<String, dynamic>? user;

  // helpers for common fields
  static String get userName => user?['fullName'] ?? '';
  static String get userRole => user?['role'] ?? '';
  static int get userID => user?['id'] ?? 0;

  static void setSession(String t, Map<String, dynamic> u) {
    token = t;
    user = u;
  }

  static void clearSession() {
    token = null;
    user = null;
  }
}
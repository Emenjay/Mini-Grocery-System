import 'package:flutter/material.dart';
//import 'theme/colors.dart';
import 'screens/login.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_inventory.dart';
import 'screens/admin/admin_product_detail.dart';
import 'screens/admin/notifications_screen.dart';
import 'screens/admin/staff_list_screen.dart';
import 'screens/cashier/cash_in.dart';
import 'screens/cashier/pos_screen.dart';
import 'screens/cashier/cash_out.dart';
import 'screens/cashier/transactions.dart';
import 'screens/inventory/add_new_product.dart';
import 'screens/inventory/staff_inventory.dart';
import 'screens/inventory/inventory_dashboard.dart';
import '../../services/session_service.dart';
import '../../utils/app_state.dart';

// The main entry point of the application. It initializes the app, checks for existing user sessions, and determines the initial screen based on the user's role.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // restore session if exists
  final token = await SessionService.getToken();
  final user = await SessionService.getUser();
  if (token != null && user != null) {
    AppState.setSession(token, user);
  }

  runApp(MyApp(initialRoute: _resolveInitialRoute(token, user)));
}

// decide where to start based on stored session
String _resolveInitialRoute(String? token, Map<String, dynamic>? user) {
  if (token == null || user == null) return '/login';

  final role = user['role'] ?? '';
  if (role == 'Inventory') return '/inventory-dashboard';
  if (role == 'Admin') return '/admin-dashboard';
  if (role == 'Cashier') return '/cash-in';
  return '/login'; // unknown role → back to login
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini-Grocery-System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C51)),
        useMaterial3: true,
      ),

      // starting point
      initialRoute: initialRoute, // determined by session state

      routes: {
        '/inventory-dashboard': (context) => const InventoryDashboard(),
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-inventory': (context) => const AdminInventoryScreen(),
        '/admin-product-detail': (context) =>
            const AdminProductDetailScreen(productList: [], initialIndex: 0),
        '/staff-inventory': (context) => const InventoryStaffScreen(),
        '/cash-in': (context) => const CashInScreen(),
        '/pos-screen': (context) => const PosScreen(),
        '/cash-out': (context) => const CashOutScreen(startingCash: 0),
        '/transactions': (context) => const TransactionsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/staff-list': (context) => const StaffListScreen(),
        '/admin-profile': (context) => const PlaceholderScreen('Admin Profile'),
      },
    );
  }
}

//place holder wla lng
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF3E5C51),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 20))),
    );
  }
}

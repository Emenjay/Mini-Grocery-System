import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/login.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_inventory.dart';
import 'screens/admin/admin_product_detail.dart';
import 'screens/admin/staff_list_screen.dart';
import 'screens/cashier/inventory_screen.dart';
import 'screens/cashier/payment_screen.dart';
import 'screens/cashier/cash_in.dart';
import 'screens/cashier/pos_screen.dart';
import 'screens/cashier/cash_out.dart';
import 'screens/cashier/transactions.dart';
import 'screens/inventory/add_new_product.dart';
import 'screens/inventory/product_detail.dart';
import 'screens/inventory/staff_inventory.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Mini-Grocery-System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C51)),
        useMaterial3: true,
      ),

      // ~TEMPORARY COMMENTS for testing staff_list screen only.
      home: const StaffListScreen(),
      /*
      // set login as the starting point for the flow
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-inventory': (context) => const AdminInventoryScreen(),
        '/admin-product-detail': (context) => const AdminProductDetailScreen(productList: [], initialIndex: 0),
        '/staff-inventory': (context) => const InventoryStaffScreen(),
        '/cash-in': (context) => const CashInScreen(),
        '/pos-screen': (context) => const PosScreen(),
        '/cash-out': (context) => const CashOutScreen(startingCash: 0),
        '/transactions': (context) => const TransactionsScreen(),
        // Placeholders for missing routes used in the dashboard
        '/staff-list': (context) => const PlaceholderScreen('Staff List'),
        '/admin-profile': (context) => const PlaceholderScreen('Admin Profile'),
        '/notifications': (context) => const PlaceholderScreen('Notifications'),
      },
    );
  }
}

// make use of this placeholder screen if you wish to create a new route and simulate your work
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

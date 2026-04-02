import 'package:flutter/material.dart';
import 'login.dart'; 
import 'cash_in.dart';
import 'owner_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 'initialRoute' and 'home' shouldn't be used together if they conflict.

      initialRoute: '/admin-dashboard', // for clean
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const OwnerDashboard(),
        '/cash-in': (context) => const CashInScreen(), 
        '/pos-screen': (context) => const PlaceholderScreen("POS Screen"),
        '/inventory': (context) => const PlaceholderScreen("Inventory Dashboard"),
      },
    );
  }
}
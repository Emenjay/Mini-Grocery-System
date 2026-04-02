import 'package:flutter/material.dart';
import 'login.dart'; 
import 'cash_in.dart'; 

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

      initialRoute: '/', // for clean
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const PlaceholderScreen("Admin Dashboard"),
        '/cash-in': (context) => const CashInScreen(), 
        '/pos-screen': (context) => const PlaceholderScreen("POS Screen"),
        '/inventory': (context) => const PlaceholderScreen("Inventory Dashboard"),
      },
    );
  }
}
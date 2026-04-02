import 'package:flutter/material.dart';
import 'login.dart'; // links login file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // this shows login page first
      home: const LoginPage(), 
      
      // must include these routes so _handleLogin logic works
      routes: {
        '/admin-dashboard': (context) => const PlaceholderScreen("Admin Dashboard"),
        '/cash-in': (context) => const PlaceholderScreen("Cashier Screen"),
        '/inventory': (context) => const PlaceholderScreen("Inventory Screen"),
      },
    );
  }
}
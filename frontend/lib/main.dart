// ignore_for_file: unused_import

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
      
      // set login as the starting point for the flow
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/cash-in': (context) => const CashInScreen(),
        '/pos-screen': (context) => const PosScreen(),
        '/cash-out': (context) => const CashOutScreen(startingCash: 0), // initialize with 0 or pass data
        '/transactions': (context) => const TransactionsScreen(),
      },
    );
  }
}
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:frontend/screens/product_detail.dart';
import 'package:frontend/screens/staff_inventory.dart';
import 'screens/pos_screen.dart';
import 'theme/colors.dart';
import 'screens/login.dart'; 
import 'screens/cash_in.dart';
import 'screens/owner_dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/admin_inventory.dart';
import 'screens/add_new_product.dart';
import 'screens/product_detail.dart';
import 'screens/staff_inventory.dart';

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
      // 'initialRoute' and 'home' shouldn't be used together if they conflict.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDarkTeal),
      ),
      
      /*home: const ProductDetailScreen(product: {
          'id': '2026PC0001',
          'name': 'Malunggay Lotion 500mL',
          'category': 'Personal Care',
          'stocks': 550,
          'status': 'In Stock',
        },),
        */

      initialRoute: '/', // for clean
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const OwnerDashboard(),
        '/cash-in': (context) => const CashInScreen(), 
        '/pos-screen': (context) => const PosScreen(),
        '/inventory': (context) => const InventoryScreen(),
      },
    );
  }
}
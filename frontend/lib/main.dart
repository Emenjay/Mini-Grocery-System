import 'package:flutter/material.dart';
import 'screens/pos/pos_screen.dart';
import 'theme/colors.dart';
import 'login.dart'; 
import 'cash_in.dart';
import 'owner_dashboard_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDarkTeal),
      ),

      initialRoute: '/', // for clean
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const OwnerDashboard(),
        '/cash-in': (context) => const CashInScreen(), 
        '/pos-screen': (context) => const PosScreen(),
        '/inventory': (context) => const PlaceholderScreen("Inventory Dashboard"),
      },
    );
  }
}
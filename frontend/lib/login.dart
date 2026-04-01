import 'package:flutter/material.dart';

void main() {
  runApp(const DingleApp());
}

class DingleApp extends StatelessWidget {
  const DingleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const PlaceholderScreen("Admin Dashboard (Add Employees)"),
        '/cash-in': (context) => const PlaceholderScreen("Cashier Cash-In Screen"),
        '/inventory': (context) => const PlaceholderScreen("Inventory Dashboard"),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controllers for input
  final _userController = TextEditingController();
  final _pinController = TextEditingController();

  void _handleLogin() {
    final user = _userController.text;
    final pin = _pinController.text;

    // mock api routing rule
    if (user == "admin" && pin == "1234") {
      // route for admin/owner
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else if (user == "cashier1" && pin == "0000") {
      // route for cashier
      Navigator.pushReplacementNamed(context, '/cash-in');
    } else if (user == "staff1" && pin == "8888") {
      // route for inventory
      Navigator.pushReplacementNamed(context, '/inventory');
    } else {
      // simple error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background color
          Container(color: const Color(0xFF345E4D)),

          // top logo section
          Positioned(
            top: 60, left: 0, right: 0,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 50, color: Color(0xFF345E4D)), // placeholder logo
                ),
                const SizedBox(height: 15),
                const Text(
                  "Dingle Plaza Mart",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Accessible Groceries for Every Home.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // login card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("Welcome!", 
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF345E4D))),
                  ),
                  const SizedBox(height: 30),

                  // user input
                  const Text("Username:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF345E4D))),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(hintText: "Enter your username"),
                  ),
                  const SizedBox(height: 20),

                  // pin input
                  const Text("Pincode:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF345E4D))),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number, // numeric pad for pins
                    decoration: const InputDecoration(hintText: "Enter your pincode"),
                  ),
                  const Spacer(),

                  // login button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF345E4D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Log in", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// simple placeholder for target screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF345E4D), foregroundColor: Colors.white),
      body: Center(child: Text("Welcome to $title")),
    );
  }
}
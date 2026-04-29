import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controllers for input
  final _userController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final user = _userController.text;
    final pin = _pinController.text;

    if (user.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both username and pincode")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // simulate delay before showing the dashboard (transition)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // mock api routing rule
    if (user == "admin" && pin == "1234") {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else if (user == "cashier1" && pin == "0000") {
      Navigator.pushReplacementNamed(context, '/cash-in');
    } else if (user == "staff1" && pin == "8888") {
      Navigator.pushReplacementNamed(context, '/inventory-dashboard');
    } else {
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
          // background
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // top logo section
          Positioned(
            top: 130, left: 0, right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      // If the image still won't show, this errorBuilder will tell us why
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.red, size: 40);
                      },
                    ),
                  ),
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
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  ),
                  const SizedBox(height: 30),

                  // user input
                  const Text("Username:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(hintText: "Enter your username"),
                  ),
                  const SizedBox(height: 20),

                  // pin input
                  const Text("Pincode:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(hintText: "Enter your pincode"),
                  ),
                  const Spacer(),

                  // login button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mutedGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Log in", style: TextStyle(color: Colors.white, fontSize: 18)),
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

import 'package:flutter/material.dart';

class CashOutScreen extends StatefulWidget {
  final double startingCash; // start money for validation
  const CashOutScreen({super.key, required this.startingCash});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _amountController = TextEditingController();
  bool _isValid = false; // logic for button state

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_checkAmount);
  }

  void _checkAmount() {
    double entered = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _isValid = entered >= widget.startingCash; // compare values
    });
  }

  void _showLogoutPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF8BC34A), size: 80),
            const SizedBox(height: 20),
            const Text("You have been successfully logged out.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D4B42))),
            const SizedBox(height: 8),
            const Text("Thank you!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D4B42),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("End Shift", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D4B42))),
              const SizedBox(height: 30),
              const Align(alignment: Alignment.centerLeft, child: Text("Enter Final Money:", style: TextStyle(color: Color(0xFF5E8B7E), fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Amount",
                  filled: true,
                  fillColor: const Color(0xFFEEEEEE),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCCCCCC), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF2D4B42), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isValid ? _showLogoutPopup : null, // null makes it gray
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A), 
                        disabledBackgroundColor: Colors.grey.shade400, // gray look
                        shape: const StadiumBorder(), 
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                      child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';

class CashInScreen extends StatefulWidget {
  const CashInScreen({super.key});

  @override
  State<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  final _amountController = TextEditingController();

  void _submitCashIn() {
    if (_amountController.text.isNotEmpty) {
      // 1. Implementation of the successful action SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shift started successfully!"),
          backgroundColor: Color(0xFF345E4D),
        ),
      );

      // 2. Route to POS screen after success
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
           Navigator.pushReplacementNamed(context, '/pos-screen');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashier Cash-In"),
        backgroundColor: const Color(0xFF345E4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter Starting Cash", // Required label
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "0.00",
                prefixText: "₱ ",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitCashIn, // Required button action
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF345E4D),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Start Shift", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
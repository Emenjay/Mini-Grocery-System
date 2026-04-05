import 'package:flutter/material.dart';
import 'pos_screen.dart';

class CashInScreen extends StatefulWidget {
  const CashInScreen({super.key});

  @override
  State<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  final _amountController = TextEditingController();

  void _submitCashIn() {
    double? amount = double.tryParse(_amountController.text);
    if (amount != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shift started successfully!"), backgroundColor: Colors.green),
      );

      // pass the amount to pos
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PosScreen(startingCash: amount)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cashier Cash-In"), backgroundColor: const Color(0xFF76BA99)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter Starting Cash", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                onPressed: _submitCashIn,
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
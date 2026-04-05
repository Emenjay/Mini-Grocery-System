import 'package:flutter/material.dart';
import 'receipt_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  // dummy data: this is what your database query will eventually return
  final List<Map<String, dynamic>> dummyTransactions = const [
    {
      'cartNo': '#010003',
      'total': 163.00,
      'date': 'March 11, 2026',
      'method': 'Cash',
      'received': 500.0,
      'items': [
        {'name': 'Ligo Sardines in Tomato Sauce | 155 g', 'price': 23.50, 'quantity': 1},
        {'name': 'Lucky Me! Pancit Canton (Original)', 'price': 28.50, 'quantity': 2},
        {'name': 'Datu Puti Vinegar (1L)', 'price': 43.00, 'quantity': 1},
        {'name': 'Safeguard Pure White | 175 g', 'price': 68.00, 'quantity': 1},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E5C51), // dark theme green
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // user avatar from your screenshot
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/user_profile.png'), 
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello,", style: TextStyle(color: Colors.white, fontSize: 12)),
                Text("Russel Marie!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          // greyed out history icon (current page indicator)
          const IconButton(
            icon: Icon(Icons.history, color: Colors.white38),
            onPressed: null, 
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Transactions",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _sectionLabel("Recent"),
                  _transactionCard(context, dummyTransactions[0], isPrevious: false),
                  _transactionCard(context, dummyTransactions[0], isPrevious: false),
                  _transactionCard(context, dummyTransactions[0], isPrevious: false),
                  
                  const SizedBox(height: 15),
                  _sectionLabel("Previous"),
                  // these cards use the light green background per screenshot
                  _transactionCard(context, dummyTransactions[0], isPrevious: true),
                  _transactionCard(context, dummyTransactions[0], isPrevious: true),
                  _transactionCard(context, dummyTransactions[0], isPrevious: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _transactionCard(BuildContext context, Map<String, dynamic> data, {required bool isPrevious}) {
    return GestureDetector(
      onTap: () {
        // click to view what products were bought
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(
              paymentMethod: data['method'],
              totalAmount: data['total'],
              amountReceived: data['received'],
              change: data['received'] - data['total'],
              items: data['items'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // recent = white, previous = light green/mint
          color: isPrevious ? const Color(0xFFE1ECEA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Cart No.", style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text(
                  data['cartNo'], 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E5C51))
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₱ ${data['total'].toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))
                ),
                Text(data['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
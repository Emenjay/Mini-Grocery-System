import 'package:flutter/material.dart';
import 'receipt_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
      backgroundColor: const Color(0xFF3D554E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_return,
                        color: Color(0xFF3D554E),
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    "Transactions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ListView(
                  children: [
                    const Text(
                      "Recent",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _transactionCard(context, dummyTransactions[0], isPrevious: false),
                    _transactionCard(context, dummyTransactions[0], isPrevious: false),
                    const SizedBox(height: 20),
                    const Text(
                      "Previous",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _transactionCard(context, dummyTransactions[0], isPrevious: true),
                    _transactionCard(context, dummyTransactions[0], isPrevious: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionCard(BuildContext context, Map<String, dynamic> data, {required bool isPrevious}) {
    return GestureDetector(
      onTap: () {
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
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrevious ? const Color(0xFFE1ECEA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cart No.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  data['cartNo'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF345149),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₱ ${data['total'].toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  data['date'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
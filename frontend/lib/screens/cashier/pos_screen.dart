import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'inventory_screen.dart';
import 'transactions.dart';
import 'cash_out.dart';

class PosScreen extends StatefulWidget {
  final double startingCash; // keep track of start money
  const PosScreen({super.key, this.startingCash = 0.0});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Ligo Sardines in Tomato Sauce | 155 g', 'price': 22.00, 'quantity': 2},
    {'name': 'Lucky Me! Pancit Canton (Original)', 'price': 28.50, 'quantity': 1},
    {'name': 'Datu Puti Vinegar (1L)', 'price': 43.00, 'quantity': 1},
    {'name': 'Safeguard Pure White | 175 g', 'price': 68.00, 'quantity': 1},
  ];

  double get total => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset('assets/images/logo_pos.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello,", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text("Michael!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D4B42))),
                    ],
                  ),
                  const Spacer(),
                  _topCircleButton(Icons.history, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                  }),
                  const SizedBox(width: 10),
                  // door button to cash out
                  _topCircleButton(Icons.logout, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CashOutScreen(startingCash: widget.startingCash)
                    ));
                  }),
                ],
              ),
            ),

            // cart container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Cart No.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text("#010003", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D4B42))),
                            ],
                          ),
                          Row(
                            children: [
                              _headerAction(Icons.refresh, "Reset"),
                              const SizedBox(width: 10),
                              _headerAction(Icons.delete_outline, "Delete", color: Colors.red),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) => setState(() => cartItems.removeAt(index)),
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                            ),
                            child: _buildCartItem(item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: const Color(0xFF35524A), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("₱ ${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen())),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF35524A), padding: const EdgeInsets.symmetric(vertical: 18), shape: const StadiumBorder()),
                          child: const Text("Add Product", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: total))),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF76BA99), padding: const EdgeInsets.symmetric(vertical: 18), shape: const StadiumBorder()),
                          child: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48, width: 48,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _headerAction(IconData icon, String label, {Color color = Colors.black54}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 12))]),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D4B42))),
              Text("Price: ₱ ${item['price'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFE8F1EF), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              _qtyBtn(Icons.remove, item),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold))),
              _qtyBtn(Icons.add, item),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => setState(() {
        if (icon == Icons.add) item['quantity']++;
        else if (item['quantity'] > 1) item['quantity']--;
      }),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFF35524A), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
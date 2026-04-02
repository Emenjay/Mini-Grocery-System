import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class PosScreen extends StatefulWidget{
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen>{
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Ligo Sardines in Tomato Sauce | 155g', 'price': 44.00, 'quantity': 2},
    {'name': 'Lucky Me! Pancit Canton (Original)', 'price': 28.50, 'quantity': 1},
    {'name': 'Datu Puti Vinegar (1L)', 'price': 43.00, 'quantity': 1},
    {'name': 'Safeguard Pure White | 175g', 'price': 68.00, 'quantity': 1},
  ];

  // total cart value - summing (price × quantity) for all items
  double get total => cartItems.fold(
    0, (sum, item) => sum + (item['price'] * item['quantity']));

  void _increaseQty(int index) => setState(() => cartItems[index]['quantity']++);
  void _decreaseQty(int index) => setState(() {
    if (cartItems[index]['quantity'] > 1) cartItems[index]['quantity']--;
  });

  void _deleteItem(int index) => setState(() => cartItems.removeAt(index));
  
  // _resetCart & _deleteCart methods - both clear items locally
  // TODO: needs to sync w backend later
  void _resetCart() {
    setState(() {
      cartItems.clear();
    });
  }

  void _deleteCart() { 
    setState(() {
      cartItems.clear();
    });
  }


  // reusable quantity adjustment button (+ / -)
  Widget _qtyButton(IconData icon, VoidCallback onPressed){
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGray,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_pos.png',
              width: 42,
              height: 42,
            ),
        
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Hello,', style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text('Michael!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryDarkTeal),
            // TODO: navigate to transaction history screen
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryDarkTeal),
            // TODO: implement logout confirmation
            onPressed: () {},
          ),
        ],
      ),


      body: Column(
        children: [
          // cart container
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cart no., reset button, & delete button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Cart No.', style: TextStyle(fontSize: 12, color: Colors.black)),
                            Text('#010003', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                          ],
                        ),
                        Row(
                          children: [

                            OutlinedButton.icon(
                              icon: const Icon(Icons.refresh, size: 14, color: AppColors.primaryDarkTeal),
                              label: const Text('Reset', style: TextStyle(fontSize: 12, color: AppColors.primaryDarkTeal)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.surfaceLightGray),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed:  _resetCart,
                            ),

                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                              label: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.surfaceLightGray),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed: _deleteCart,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // scrollable cart list with swipe‑to‑left to delete items (Dismissible)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index){
                        final item = cartItems[index];
                       
                        return Dismissible(
                          key: Key(item['name']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteItem(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: AppColors.surfaceLightGray),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: ListTile(
                              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),

                              // shows unit price and line total (price × quantity) for each cart item
                              subtitle: Text(
                                'Price: ₱${item['price'].toStringAsFixed(2)}  (₱${(item['price'] * item['quantity']).toStringAsFixed(2)})',
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyButton(Icons.remove, () => _decreaseQty(index)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  _qtyButton(Icons.add, () => _increaseQty(index)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // total amount bar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkTeal,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // add product & checkout buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkTeal,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

                    // TODO: navigate to Inventory list screen
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceMint,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

                    // TODO: navigate to payment options screen 
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
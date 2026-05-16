import 'package:flutter/material.dart';
import '../../services/checkout_service.dart';
import '../../utils/app_state.dart';
import 'payment_screen.dart';
import 'inventory_screen.dart';
import 'transactions.dart';
import 'cash_out.dart';

class PosScreen extends StatefulWidget {
  final double startingCash;
  const PosScreen({super.key, this.startingCash = 0.0});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {

  // active cart items - each map holds product_id, name, price, quantity
  List<Map<String, dynamic>> cartItems = [];

  // cart number shown to cashier before checkout - generated locally using #HHmmss format
  // regenerated on screen load and on delete
  late String _cartNo;

  // paused carts fetched from backend - shown in the pending bottom sheet
  List<Map<String, dynamic>> _pausedCarts = [];

  // true while pause or resume API calls are in flight
  bool _isPauseLoading = false;

  @override
  void initState() {
    super.initState();
    // generate initial cart number on screen load
    _cartNo = _generateCartNo();
  }

  // generate a local cart number using current time - #HHmmss format
  // matches the backend generateCartNo format so the number sent on pause is consistent
  String _generateCartNo() {
    final now = DateTime.now();
    return '#${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  double get total => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  // collect product IDs currently in the cart so inventory screen can grey them out on re-open
  Set<int> get _cartProductIds => cartItems.map((i) => i['product_id'] as int).toSet();

  // show a dialog to type a specific quantity — faster than tapping +/- for large amounts
  void _editQuantityDialog(Map<String, dynamic> item) {
    final controller = TextEditingController(text: '${item['quantity']}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item['name'],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quantity',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text.trim()) ?? 0;
              if (qty > 0) {
                setState(() => item['quantity'] = qty);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35524A)),
            child: const Text('Set', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // open inventory screen, passing current cart product IDs to preserve greyed-out state
  // when the cashier returns, any selected product is added to the cart
  Future<void> _openInventory() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryScreen(addedProductIds: _cartProductIds),
      ),
    );

    if (result == null) return;

    setState(() {
      // check if the product is already in the cart (defensive, inventory screen also prevents this)
      final existingIndex = cartItems.indexWhere((i) => i['product_id'] == result['product_id']);
      if (existingIndex >= 0) {
        // increment quantity if already present
        cartItems[existingIndex]['quantity'] += result['quantity'] as int;
      } else {
        // add as new cart item
        cartItems.add({
          'product_id': result['product_id'],
          'name': result['name'],
          'price': result['price'],
          'quantity': result['quantity'],
        });
      }
    });
  }

  // pause the current cart via backend, then optionally reload the pending list
  // called both from the Hold button and from resume flow
  Future<bool> _pauseCurrentCart() async {
    if (cartItems.isEmpty) return true; // nothing to pause, treat as success
    // Pass the current cart number
    final result = await CheckoutService.pauseCart(cartItems, cartNo: _cartNo);

    if (!mounted) return false;

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to pause cart')),
      );
      return false;
    }

    // clear the active cart after successful pause
    setState(() => cartItems.clear());
    return true;
  }

  // hold button handler - pauses current cart and shows snackbar feedback
  Future<void> _suspendCurrentCart() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty, nothing to hold')),
      );
      return;
    }

    setState(() => _isPauseLoading = true);

    final cartNoSnapshot = _cartNo; // snapshot before clearing
    final success = await _pauseCurrentCart();

    if (!mounted) return;
    setState(() => _isPauseLoading = false);

    if (success) {
      // generate new cart number for the next transaction after holding
      setState(() => _cartNo = _generateCartNo());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart $cartNoSnapshot held successfully')),
      );
    }
  }

  // fetch paused carts from backend then show the pending bottom sheet
  Future<void> _showPendingCarts() async {
    setState(() => _isPauseLoading = true);

    final result = await CheckoutService.getPausedCarts();

    if (!mounted) return;
    setState(() => _isPauseLoading = false);

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load paused carts')),
      );
      return;
    }

    // cast to list of maps for type safety
    _pausedCarts = (result['carts'] as List)
        .map((c) => Map<String, dynamic>.from(c))
        .toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Pending Carts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _pausedCarts.isEmpty
                    ? const Padding(padding: EdgeInsets.all(20), child: Text("No pending transactions"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _pausedCarts.length,
                          itemBuilder: (context, index) {
                            final pending = _pausedCarts[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F1EF),
                                child: Icon(Icons.shopping_cart, color: Color(0xFF2D4B42)),
                              ),
                              title: Text("Cart ${pending['cart_no']}"),
                              subtitle: Text(
                                "${pending['item_count']} items • ₱ ${double.tryParse(pending['total_amount'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                              ),
                              // discard button on the right
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  // delete paused cart from backend
                                  GestureDetector(
                                    onTap: () async {
                                      final discardResult = await CheckoutService.discardPausedCart(
                                        pending['paused_cart_id'],
                                      );
                                      if (!context.mounted) return;
                                      if (discardResult['success']) {
                                        setSheetState(() => _pausedCarts.removeAt(index));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(discardResult['message'] ?? 'Failed to discard')),
                                        );
                                      }
                                    },
                                    child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context); // close bottom sheet first

                                setState(() => _isPauseLoading = true);

                                // if current cart has items, pause it first before loading the selected one
                                if (cartItems.isNotEmpty) {
                                  final pauseSuccess = await _pauseCurrentCart();
                                  if (!mounted) return;
                                  if (!pauseSuccess) {
                                    setState(() => _isPauseLoading = false);
                                    return;
                                  }
                                }

                                // fetch the full paused cart items from backend
                                final resumeResult = await CheckoutService.getPausedCartById(
                                  pending['paused_cart_id'],
                                );

                                if (!mounted) return;
                                setState(() => _isPauseLoading = false);

                                if (!resumeResult['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(resumeResult['message'] ?? 'Failed to resume cart')),
                                  );
                                  return;
                                }

                                final resumedCart = resumeResult['cart'];

                                // map backend paused_cart_item fields back to POS cart format
                                final List<Map<String, dynamic>> resumedItems = (resumedCart['items'] as List).map((item) => {
                                  'product_id': item['product_id'],
                                  'name': item['product_name'],
                                  // retail_price was snapshotted at pause time
                                  'price': double.tryParse(item['retail_price'].toString()) ?? 0.0,
                                  'quantity': item['quantity'],
                                }).toList();

                                setState(() {
                                  cartItems = resumedItems;
                                  // restore the cart number from the paused cart
                                  _cartNo = resumedCart['cart_no'];
                                });

                                // delete the paused cart from backend since it's now active again
                                await CheckoutService.discardPausedCart(pending['paused_cart_id']);
                              },
                            );
                          },
                        ),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello,", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      // display logged-in user's name from AppState
                      Text(
                        "${AppState.userName}!",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D4B42)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // show loading indicator in header while pause/resume calls are in flight
                  if (_isPauseLoading)
                    const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D4B42)),
                    ),
                  if (_isPauseLoading) const SizedBox(width: 10),
                  // BUTTON TO VIEW PENDING CARTS
                  _topCircleButton(Icons.pause_presentation_rounded, _showPendingCarts),
                  const SizedBox(width: 10),
                  _topCircleButton(Icons.history, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                  }),
                  const SizedBox(width: 10),
                  _topCircleButton(Icons.logout, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CashOutScreen(startingCash: widget.startingCash),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Cart No.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              // locally generated cart number - sent to backend on pause or checkout
                              Text(_cartNo, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D4B42))),
                            ],
                          ),
                          Row(
                            children: [
                              // HOLD: saves current cart to backend and clears active cart
                              GestureDetector(
                                onTap: _isPauseLoading ? null : _suspendCurrentCart,
                                child: _headerAction(Icons.pause_circle_outline, "Hold", color: Colors.orange),
                              ),
                              const SizedBox(width: 10),
                              // RESET: clears items from the active cart without touching cart number
                              GestureDetector(
                                onTap: () => setState(() => cartItems.clear()),
                                child: _headerAction(Icons.refresh, "Reset"),
                              ),
                              const SizedBox(width: 10),
                              // DELETE: clears items AND regenerates cart number (new transaction slate)
                              // no backend call needed since unsaved carts don't exist on backend yet
                              GestureDetector(
                                onTap: () => setState(() {
                                  cartItems.clear();
                                  _cartNo = _generateCartNo();
                                }),
                                child: _headerAction(Icons.delete_outline, "", color: Colors.red),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    Expanded(
                      child: cartItems.isEmpty
                        ? const Center(
                            child: Text(
                              "Cart is empty",
                              style: TextStyle(color: Colors.black26, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
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
                          onPressed: _openInventory,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF35524A), padding: const EdgeInsets.symmetric(vertical: 18), shape: const StadiumBorder()),
                          child: const Text("Add Product", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          // disable checkout if cart is empty
                          onPressed: cartItems.isEmpty ? null : () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                totalAmount: total,
                                cartNo: _cartNo,
                                cartItems: cartItems,
                                // clear cart and generate new cart number once receipt is dismissed
                                onDone: () {
                                  setState(() {
                                    cartItems.clear();
                                    _cartNo = _generateCartNo();
                                  });
                                },
                              ),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76BA99),
                            disabledBackgroundColor: const Color(0xFF76BA99).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: const StadiumBorder(),
                          ),
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
            decoration: BoxDecoration(
                color: const Color(0xFFE8F1EF),
                borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              _qtyBtn(Icons.remove, item),
              // tap the number to type a custom quantity
              GestureDetector(
                onTap: () => _editQuantityDialog(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("${item['quantity']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
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
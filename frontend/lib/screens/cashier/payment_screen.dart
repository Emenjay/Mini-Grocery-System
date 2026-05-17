import 'package:flutter/material.dart';
import '../../services/checkout_service.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String cartNo;
  // cart items passed from PosScreen — used as payload for the checkout API call
  final List<Map<String, dynamic>> cartItems;
  // called after successful checkout, passed through to ReceiptScreen
  // PosScreen uses this to clear the cart and generate a new cart number
  final VoidCallback? onDone;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartNo,
    required this.cartItems,
    this.onDone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash';
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  double _change = 0.00;
  bool _isButtonEnabled = false;
  // tracks loading state while checkout API call is in progress
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(_validateInputs);
    _refController.addListener(_validateInputs);
  }

  void _validateInputs() {
    double received = double.tryParse(_receivedController.text) ?? 0.0;

    setState(() {
      // auto generate change
      _change = received >= widget.totalAmount ? received - widget.totalAmount : 0.00;

      // validation logic
      if (_selectedMethod == 'Cash') {
        _isButtonEnabled = received >= widget.totalAmount && _receivedController.text.isNotEmpty;
      } else {
        // Now just checks if not empty.
        _isButtonEnabled = received >= widget.totalAmount &&
                          _receivedController.text.isNotEmpty &&
                          _refController.text.isNotEmpty;
      }
    });
  }

  String _formatReceiptDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$month/$day/$year  $hour:$minute $period';
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _refController.dispose();
    super.dispose();
  }

  // call backend checkout endpoint, then navigate to receipt on success
  Future<void> _confirmPayment() async {
    final double amountReceived = double.tryParse(_receivedController.text) ?? 0.0;

    setState(() => _isLoading = true);

    final result = await CheckoutService.checkout(
      cartItems: widget.cartItems,
      paymentMethod: _selectedMethod,
      amountReceived: amountReceived,
      cartNo: widget.cartNo,
      referenceNumber: _selectedMethod == 'GCash' ? _refController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result['success']) {
      // show error and stay on screen — do not navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Checkout failed')),
      );
      return;
    }

    final data = result['data'];

    // show any stock warnings (low stock / out of stock) after successful checkout
    if (data['warnings'] != null && (data['warnings'] as List).isNotEmpty) {
      for (final warning in data['warnings']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warning.toString()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // map cart items to receipt format — name, price, quantity for display
    final List<Map<String, dynamic>> receiptItems = widget.cartItems.map((item) => {
      'name': item['name'],
      'price': item['price'],
      'quantity': item['quantity'],
    }).toList();

    if (!mounted) return;

    // replace PaymentScreen with ReceiptScreen so back button goes to POS not payment
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          paymentMethod: _selectedMethod,
          totalAmount: double.tryParse(data['totalAmount'].toString()) ?? widget.totalAmount,
          amountReceived: amountReceived,
          change: double.tryParse(data['changeAmount'].toString()) ?? _change,
          referenceNumber: _selectedMethod == 'GCash' ? _refController.text : null,
          // cart number comes from backend response to stay in sync
          cartNo: data['cartNo'] ?? widget.cartNo,
          dateTime: _formatReceiptDateTime(DateTime.now()),
          items: receiptItems,
          // clear POS cart and generate new cart number after successful transaction
          onDone: widget.onDone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E5C51),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // disable back button while API call is in progress
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E5C51)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMethod,
                      isExpanded: true,
                      items: ['Cash', 'GCash'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      // disable dropdown while loading
                      onChanged: _isLoading ? null : (val) {
                        setState(() {
                          _selectedMethod = val!;
                          _validateInputs();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // cart number passed from PosScreen
                _summaryRow("Cart No. :", widget.cartNo),
                const SizedBox(height: 10),
                _summaryRow("Total Amount:", "₱ ${widget.totalAmount.toStringAsFixed(2)}"),
                const SizedBox(height: 10),

                // only show change row for cash payments
                if (_selectedMethod == 'Cash')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Change:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Text("₱ ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                            Text(_change.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check,
                              size: 14,
                              color: _change >= 0 && _receivedController.text.isNotEmpty
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedMethod == 'GCash') ...[
                    const Text("Enter Reference Number:", style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    _inputField(_refController, "e.g. 1234ABC567890", isAlphanumeric: true),

                    const SizedBox(height: 20),
                  ],
                  const Text("Enter Money Received:", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  _inputField(_receivedController, "0.00", isAlphanumeric: false),

                  // error message shown when received amount is less than total
                  if (_receivedController.text.isNotEmpty &&
                      (double.tryParse(_receivedController.text) ?? 0.0) < widget.totalAmount)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        "Received money cannot be smaller than the total amount",
                        style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF67B285),
                        disabledBackgroundColor: Colors.grey,
                        shape: const StadiumBorder(),
                      ),
                      // disable while loading or inputs invalid — calls _confirmPayment which hits the backend
                      onPressed: _isButtonEnabled && !_isLoading ? _confirmPayment : null,
                      child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            // loading spinner while checkout API call is in flight
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _inputField(TextEditingController controller, String hint, {bool isAlphanumeric = false}) {
    return TextField(
      controller: controller,
      // disable input fields while loading
      enabled: !_isLoading,
      keyboardType: isAlphanumeric ? TextInputType.text : TextInputType.number,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: const Color(0xFFE0E0E0),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
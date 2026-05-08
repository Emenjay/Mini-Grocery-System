import 'package:flutter/material.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  // w db, pass a list of cart items here too
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash';
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  double _change = 0.00;
  bool _isButtonEnabled = false;

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
        // REMOVED: 13-char alphanumeric restriction. 
        // Now just checks if not empty.
        _isButtonEnabled = received >= widget.totalAmount && 
                          _receivedController.text.isNotEmpty && 
                          _refController.text.isNotEmpty;
      }
    });
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _refController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
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
                      onChanged: (val) {
                        setState(() {
                          _selectedMethod = val!;
                          _validateInputs(); 
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _summaryRow("Cart No. :", "#010003"),
                const SizedBox(height: 10),
                _summaryRow("Total Amount:", "₱ ${widget.totalAmount.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                
                // only show change for cash
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
                            Icon(Icons.check, size: 14, color: _change >= 0 && _receivedController.text.isNotEmpty ? Colors.green : Colors.grey),
                          ],
                        ),
                      )
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
                    
                    // REMOVED: 13-character restriction error message
                    const SizedBox(height: 20),
                  ],
                  const Text("Enter Money Received:", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  _inputField(_receivedController, "0.00", isAlphanumeric: false),

                  // Error message for Money Received
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
                        disabledBackgroundColor: Colors.grey, // grey when unclickable
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _isButtonEnabled 
                        ? () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => ReceiptScreen(
                                paymentMethod: _selectedMethod,
                                totalAmount: widget.totalAmount,
                                amountReceived: double.tryParse(_receivedController.text) ?? 0.0,
                                change: _change,
                                referenceNumber: _selectedMethod == 'GCash' ? _refController.text : null,
                                // passing manual list for now
                                items: const [
                                  {'name': 'Ligo Sardines in Tomato Sauce | 155 g', 'price': 23.50, 'quantity': 1},
                                  {'name': 'Lucky Me! Pancit Canton (Original)', 'price': 28.50, 'quantity': 2},
                                  {'name': 'Datu Puti Vinegar (1L)', 'price': 43.00, 'quantity': 1},
                                  {'name': 'Safeguard Pure White | 175 g', 'price': 68.00, 'quantity': 1},
                                ],
                              ),
                            ),
                          )
                        : null, 
                      child: const Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
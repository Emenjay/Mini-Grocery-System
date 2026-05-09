import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final String paymentMethod;
  final double totalAmount;
  final double amountReceived;
  final double change;
  final String cartNo;
  final String? referenceNumber;
  final List<Map<String, dynamic>> items;
  // called when cashier taps Done — PosScreen uses this to clear the cart
  // and generate a new cart number for the next transaction
  final VoidCallback? onDone;

  const ReceiptScreen({
    super.key,
    required this.paymentMethod,
    required this.totalAmount,
    required this.amountReceived,
    required this.change,
    this.referenceNumber,
    required this.cartNo,
    required this.items,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E5C51),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // hide back button - cashier must use Done to ensure cart is cleared properly
        automaticallyImplyLeading: false,
        title: const Text(
          "Receipt",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // main white card
          Container(
            margin: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E5C51),
                  ),
                ),
                const SizedBox(height: 20),

                // item list with individual and subtotal prices
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final double itemSubtotal = item['price'] * item['quantity'];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // individual price & subtotal calc
                                  Text(
                                    "Price: ₱ ${(item['price'] as double).toStringAsFixed(2)}  (₱ ${itemSubtotal.toStringAsFixed(2)})",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "x${item['quantity']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(thickness: 1),

                // summary section
                _receiptRow("Cart No. :", cartNo),
                _receiptRow("Total Amount:", "₱ ${totalAmount.toStringAsFixed(2)}"),
                _receiptRow("Amount Received:", "₱ ${amountReceived.toStringAsFixed(2)}"),

                // dynamic row: change for cash, reference number for GCash
                if (paymentMethod == 'Cash')
                  _receiptRow("Change:", "₱ ${change.toStringAsFixed(2)}")
                else
                  _receiptRow("Ref No. :", referenceNumber ?? "N/A"),

                _receiptRow("Payment Method:", paymentMethod),

                const SizedBox(height: 30),

                // done button - fires onDone callback so PosScreen clears cart,
                // then pops both receipt and payment screens back to PosScreen
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E5C51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      // fire PosScreen's cleanup first so cart is cleared before UI updates
                      onDone?.call();
                      // pop twice: receipt was pushed, payment used pushReplacement so
                      // only one screen sits between receipt and PosScreen on the stack
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // success icon badge
          Positioned(
            top: 15,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF8BC34A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
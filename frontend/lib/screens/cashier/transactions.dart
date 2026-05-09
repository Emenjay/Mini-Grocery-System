import 'package:flutter/material.dart';
import '../../services/transaction_service.dart';
import 'receipt_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // backend splits transactions into recent (today) and previous (older)
  List<dynamic> _recent = [];
  List<dynamic> _previous = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await TransactionService.getTransactionHistory();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _recent = result['recent'] ?? [];
        _previous = result['previous'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  // fetch full transaction detail then navigate to receipt screen
  Future<void> _openReceipt(int transactionId) async {
    // show loading indicator while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final result = await TransactionService.getTransactionDetail(transactionId);

    if (!mounted) return;
    Navigator.pop(context); // close loading indicator

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load receipt')),
      );
      return;
    }

    final data = result['data'];

    // map backend item fields to what ReceiptScreen expects
    final List<Map<String, dynamic>> items = (data['items'] as List).map((item) => {
      'name': item['product_name'],
      'price': double.tryParse(item['retail_price'].toString()) ?? 0.0,
      'quantity': item['quantity_sold'],
    }).toList();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          paymentMethod: data['transaction_type'] ?? 'Cash',
          totalAmount: double.tryParse(data['total_amount'].toString()) ?? 0.0,
          amountReceived: double.tryParse(data['amount_received'].toString()) ?? 0.0,
          change: double.tryParse(data['change_amount'].toString()) ?? 0.0,
          referenceNumber: data['reference_number'],
          cartNo: data['cart_no'],
          items: items,
        ),
      ),
    );
  }

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
                  // back button only - logout button removed
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
                  // placeholder to keep title centered
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : _recent.isEmpty && _previous.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions yet.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ListView(
                          children: [
                            // recent section - today's transactions
                            if (_recent.isNotEmpty) ...[
                              const Text(
                                "Recent",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._recent.map((t) => _transactionCard(context, t, isPrevious: false)),
                              const SizedBox(height: 20),
                            ],
                            // previous section - older transactions
                            if (_previous.isNotEmpty) ...[
                              const Text(
                                "Previous",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._previous.map((t) => _transactionCard(context, t, isPrevious: true)),
                            ],
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
      // fetch full detail on tap to get real items for receipt
      onTap: () => _openReceipt(data['transaction_id']),
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
                  data['cart_no'] ?? '',
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
                  "₱ ${double.tryParse(data['total'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                // date formatted from backend date_time field
                Text(
                  data['date'] ?? '',
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
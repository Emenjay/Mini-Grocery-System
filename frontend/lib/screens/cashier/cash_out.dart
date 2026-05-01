import 'package:flutter/material.dart';

class CashOutScreen extends StatefulWidget {
  final double startingCash;
  const CashOutScreen({super.key, required this.startingCash});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _amountController = TextEditingController();
  bool _isValid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_checkAmount);
  }

  void _checkAmount() {
    String text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isValid = false;
        _errorMessage = null;
      });
      return;
    }

    double entered = double.tryParse(text) ?? 0.0;
    setState(() {
      if (entered < widget.startingCash) {
        _isValid = false;
        _errorMessage = "Cash out amount cannot be lower than cash in (₱${widget.startingCash.toStringAsFixed(2)})";
      } else {
        _isValid = true;
        _errorMessage = null;
      }
    });
  }

  void _showLogoutPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF8BC34A), size: 80),
            SizedBox(height: 20),
            Text(
              "You have been successfully logged out.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D4B42)),
            ),
            SizedBox(height: 8),
            Text("Thank you!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D554E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text(
                        "Russel Marie!",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "End Shift",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF345149), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 35),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Final Money:",
                      style: TextStyle(color: Color(0xFF638D7E), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEBEBEB),
                      hintText: "Enter Amount",
                      hintStyle: const TextStyle(color: Colors.black26),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isValid ? _showLogoutPopup : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5B51),
                            disabledBackgroundColor: const Color(0xFF3B5B51).withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: _isValid ? Colors.white : Colors.white60,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
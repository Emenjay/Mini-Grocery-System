// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_state.dart';

class CashOutScreen extends StatefulWidget {
  final double startingCash;
  const CashOutScreen({super.key, required this.startingCash});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final _amountController = TextEditingController();
  bool _isValid = false;
  // tracks loading state while end-shift + logout API calls are in progress
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_checkAmount);
  }

  // check if the input is a valid number
  void _checkAmount() {
    String text = _amountController.text.trim();
    double? entered = double.tryParse(text);

    setState(() {
      // button is clickable as long as input is not empty and is a valid number
      _isValid = text.isNotEmpty && entered != null;
    });
  }

  // ends the shift via backend, logs out, clears session, then shows success popup
  Future<void> _showLogoutPopup() async {
    final double? cashOut = double.tryParse(_amountController.text.trim());
    if (cashOut == null) return;

    setState(() => _isLoading = true);

    // call backend to end shift and record cash-out amount
    final shiftResult = await AttendanceService.endShift(cashOut);

    if (!mounted) return;

    if (!shiftResult['success']) {
      // show error and stop if end-shift fails
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(shiftResult['message'] ?? 'Failed to end shift')),
      );
      return;
    }

    // call backend to clock out attendance and invalidate session
    await AuthService.logout(AppState.token!);

    // clear stored session data (shared_preferences + in-memory AppState)
    await SessionService.clearSession();
    AppState.clearSession();

    if (!mounted) return;
    setState(() => _isLoading = false);

    // show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

    // auto-close dialog after 2 seconds then navigate back to login screen
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      // display logged-in user's name from AppState
                      Text(
                        "${AppState.userName}!",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                  // display the cash-in amount passed in from PosScreen
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Cash-in Amount: ₱${widget.startingCash.toStringAsFixed(2)}",
                      style: const TextStyle(color: Color(0xFF638D7E), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Final Money:",
                      style: TextStyle(color: Color(0xFF345149), fontWeight: FontWeight.bold, fontSize: 15),
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
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        // disable cancel while API calls are in progress
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          // disable button while loading or input is invalid
                          onPressed: _isValid && !_isLoading ? _showLogoutPopup : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5B51),
                            disabledBackgroundColor: const Color(0xFF3B5B51).withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  // loading spinner while end-shift + logout calls are in flight
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
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
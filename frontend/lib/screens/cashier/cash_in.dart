import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_state.dart';
import 'pos_screen.dart';

class CashInScreen extends StatefulWidget {
  const CashInScreen({super.key});

  @override
  State<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  // true while the initial active-shift check is running on screen load
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {});
    });
    // check for an existing active shift as soon as the screen opens
    _checkForActiveShift();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // shows an alert informing the cashier of an existing shift, then navigates to POS
  // used by both _checkForActiveShift (on load) and _submitCashIn (as fallback on 400)
  void _redirectToPos(double existingCashIn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Active Shift Found", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "You already have an active shift for today. Redirecting you to the POS screen.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              // navigate to POS, passing the existing cash-in amount
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PosScreen(startingCash: existingCashIn),
                ),
              );
            },
            child: const Text(
              "Okay",
              style: TextStyle(color: Color(0xFF3B5B51), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // on screen load, call backend to see if cashier already has a running shift today
  // if yes, redirect straight to POS with the existing cash-in amount
  Future<void> _checkForActiveShift() async {
    final result = await AttendanceService.getActiveShift();

    if (!mounted) return;

    // if the check itself failed (network error etc.), just let the cashier proceed normally
    if (!result['success']) {
      setState(() => _isChecking = false);
      return;
    }

    final data = result['data'];
    final bool hasActiveShift = data['hasActiveShift'] == true;

    if (hasActiveShift) {
      // restore the cash-in amount from the existing shift
      final double existingCashIn = double.tryParse(data['cashIn'].toString()) ?? 0.0;
      _redirectToPos(existingCashIn);
      return; // don't update _isChecking — screen is being replaced anyway
    }

    // no active shift found, show the form normally
    setState(() => _isChecking = false);
  }

  Future<void> _submitCashIn() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    setState(() => _isLoading = true);

    // call backend to start shift with cash-in amount
    final result = await AttendanceService.startShift(amount);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result['success']) {
      // if backend says a shift already exists (e.g. _checkForActiveShift missed it due to a
      // timing issue or the GET route isn't deployed yet), fetch the real cashIn and redirect
      // instead of blocking the cashier with a dead-end error
      if (result['message'] == 'Already has an active shift today') {
        final activeResult = await AttendanceService.getActiveShift();
        if (!mounted) return;

        final double existingCashIn = (activeResult['success'] == true)
            ? double.tryParse(activeResult['data']['cashIn'].toString()) ?? 0.0
            : 0.0;

        _redirectToPos(existingCashIn);
        return;
      }

      // any other error (server error, network issue, etc.) - show as snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      return;
    }

    // show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text(
              "Success!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF345149)),
            ),
            SizedBox(height: 8),
            Text(
              "Shift started successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );

    // auto close dialog after 2 seconds then navigate to POS
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // close success dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PosScreen(startingCash: amount),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isInputEmpty = _amountController.text.trim().isEmpty;

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
                      const Text(
                        "Hello,",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      // display logged in user's name from AppState
                      Text(
                        "${AppState.userName}!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // show a loading indicator while the active-shift check is in progress
            // this prevents the form from flashing before a redirect
            if (_isChecking)
              const CircularProgressIndicator(color: Colors.white)
            else
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
                      "Start Shift",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF345149),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter Starting Money:",
                        style: TextStyle(
                          color: Color(0xFF638D7E),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          // disable button while loading or input is empty
                          onPressed: isInputEmpty || _isLoading ? null : _submitCashIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5B51),
                            disabledBackgroundColor: const Color(0xFF3B5B51).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                "Confirm",
                                style: TextStyle(
                                  color: isInputEmpty ? Colors.white60 : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
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
}
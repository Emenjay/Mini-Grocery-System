import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../utils/app_state.dart';
import '../services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controllers for input
  final _userController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // lockout logic
  int _failedAttempts = 0;
  DateTime? _lockoutTime;
  final int _maxAttempts = 5;
  Timer? _cooldownTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _userController.dispose();
    _pinController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    final totalDuration = const Duration(minutes: 3);
    final now = DateTime.now();
    final diff = now.difference(_lockoutTime!);
    
    if (diff >= totalDuration) {
      _resetLockout(showCooldownMessage: true);
      return;
    }

    _secondsRemaining = (totalDuration - diff).inSeconds;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _resetLockout(showCooldownMessage: true);
      }
    });
  }

  void _resetLockout({bool showCooldownMessage = false}) {
    if (mounted) {
      setState(() {
        _lockoutTime = null;
        _failedAttempts = 0;
        _secondsRemaining = 0;
        if (showCooldownMessage) {
          _errorMessage = "Cooldown finished. You can now try logging in again.";
        } else {
          _errorMessage = null;
        }
      });
    }
    _cooldownTimer?.cancel();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  bool _isLockedOut() {
    return _secondsRemaining > 0;
  }

  Future<void> _handleLogin() async {
    if (_isLockedOut()) {
      return;
    }
    
    final username = _userController.text.trim();
    final password = _pinController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both username and pincode.";
      });
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result['success']) {
      setState(() {
        _failedAttempts++;
        if (_failedAttempts >= _maxAttempts) {
          _lockoutTime = DateTime.now();
          _startCooldownTimer();
        } else {
          _errorMessage = "${result['message'] ?? 'Invalid login.'} ${_maxAttempts - _failedAttempts} ${_maxAttempts - _failedAttempts == 1 ? 'attempt' : 'attempts'} left.";
        }
      });
      return;
    }

    // login success - reset lockout state
    _resetLockout(showCooldownMessage: false);

    // login success - save token and user to storage and app state
    final data = result['data'];
    final token = data['token'];
    final user = data['user'];

    await SessionService.saveSession(token, user);
    AppState.setSession(token, user);

    // route based on role returned from backend
    final role = user['role'];
    if (role == 'Admin') {
      NotificationService.resetForReconnect(); // allow reconnect after re-login
      NotificationService.connect(); // start SSE connection for real-time notifications
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else if (role == 'Cashier') {
      Navigator.pushReplacementNamed(context, '/cash-in');
    } else if (role == 'Inventory') {
      Navigator.pushReplacementNamed(context, '/inventory-dashboard');
    } else {
      setState(() {
        _errorMessage = "Unknown role. Contact admin.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.fill,
            ),
          ),

          // top logo section
          Positioned(
            top: 130, left: 0, right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.red, size: 40);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Dingle Plaza Mart",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Accessible Groceries for Every Home.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // login card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("Welcome!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  ),
                  const SizedBox(height: 20),

                  // user input
                  const Text("Username:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      hintText: "Enter your username",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // pin input
                  const Text("Pincode:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter your pincode",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  // warning/lockout message area
                  if ((_errorMessage != null || _failedAttempts > 0) && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _secondsRemaining > 0 
                          ? Colors.red.withOpacity(0.1) 
                          : (_errorMessage != null && _errorMessage!.contains("finished") 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _secondsRemaining > 0 
                            ? Colors.red.withOpacity(0.3) 
                            : (_errorMessage != null && _errorMessage!.contains("finished") 
                                ? Colors.green.withOpacity(0.3) 
                                : Colors.orange.withOpacity(0.3)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _secondsRemaining > 0 
                              ? Icons.lock_clock 
                              : (_errorMessage != null && _errorMessage!.contains("finished") 
                                  ? Icons.check_circle_outline 
                                  : Icons.warning_amber_rounded),
                            color: _secondsRemaining > 0 
                              ? Colors.red 
                              : (_errorMessage != null && _errorMessage!.contains("finished") 
                                  ? Colors.green[800] 
                                  : Colors.orange[800]),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage ?? (_secondsRemaining > 0
                                ? "Locked out. Try again in ${_formatTime(_secondsRemaining)}."
                                : (_failedAttempts > 0 && _failedAttempts < _maxAttempts
                                    ? "Invalid login. ${_maxAttempts - _failedAttempts} ${_maxAttempts - _failedAttempts == 1 ? 'attempt' : 'attempts'} left."
                                    : "")),
                              style: TextStyle(
                                color: _secondsRemaining > 0 ? Colors.red : (_errorMessage != null && _errorMessage!.contains("finished") ? Colors.green[800] : Colors.orange[800]),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),
                  
                  // login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _secondsRemaining > 0) ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _secondsRemaining > 0 ? Colors.grey : AppColors.mutedGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _secondsRemaining > 0 
                              ? "${_formatTime(_secondsRemaining)}"
                              : "Log in", 
                            style: const TextStyle(color: Colors.white, fontSize: 18)
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
}
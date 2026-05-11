// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:frontend/theme/text_styles.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/inventory_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_state.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  bool _isLoading = true;
  String? _errorMessage;

  // dashboard counts
  String totalProducts = '...';
  String lowStock = '...';
  String expiredStocks = '...';
  String outOfStock = '...';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // call dashboard api
    final result = await InventoryService.getDashboardCounts();

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      setState(() {
        totalProducts = data['totalProducts'].toString();
        lowStock = data['lowStock'].toString();
        expiredStocks = data['expired'].toString();
        outOfStock = data['outOfStock'].toString();
        _isLoading = false;
      });
    } else {
      // token expired → clear session and force re-login
      if (result['message']?.toString().toLowerCase().contains('token') ==
          true) {
        await SessionService.clearSession();
        AppState.clearSession();
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _Header(onDashboardRefresh: _loadDashboard),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              // --- stats section grid ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _InventoryStatCard(
                        title: "Total Products",
                        count: _isLoading ? '...' : totalProducts,
                        icon: Icons.shopping_bag_outlined,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/staff-inventory',
                            arguments: 'All',
                          );
                          _loadDashboard(); // refresh on return
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InventoryStatCard(
                        title: "Low Stock Products",
                        count: _isLoading ? '...' : lowStock,
                        icon: Icons.inventory_2_outlined,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/staff-inventory',
                          arguments: 'Low Stock',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _InventoryStatCard(
                        title: "Expired Stocks",
                        count: _isLoading ? '...' : expiredStocks,
                        icon: Icons.calendar_today_outlined,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/staff-inventory',
                          arguments: 'Expired',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InventoryStatCard(
                        title: "Out of Stock Products",
                        count: _isLoading ? '...' : outOfStock,
                        icon: Icons.layers_clear_outlined,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/staff-inventory',
                          arguments: 'No Stock',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // --- calendar overview ---
              const _SyncfusionCalendarCard(),
              const SizedBox(height: 20),
              // --- quick actions ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ActionButton(
                      label: "Add New Product",
                      icon: Icons.add_circle_outline,
                      color: const Color(0xFF76BA99),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/add-product');
                        _loadDashboard(); // refresh counts when returning
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: "View Inventory",
                      icon: Icons.inventory_2,
                      color: const Color(0xFF35524A),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/staff-inventory');
                        _loadDashboard(); // refresh counts when returning
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onDashboardRefresh;
  const _Header({required this.onDashboardRefresh});

  // --- ʟᴏɢᴏᴜᴛ ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ ᴅɪᴀʟᴏɢ ---
  void _showLogoutConfirmation(BuildContext context) {
    final outerContext =
        context; // capture outer context for use in async callback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF35524A),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Logout Session",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext); // close confirm dialog
                        await _handleLogout(outerContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // call logout API - clocks out attendance and deletes paused carts
    // safely get token — don't crash if null
    final token = AppState.token;
    if (token != null && token.isNotEmpty) {
      await AuthService.logout(token);
    }

    // clear local session regardless of API result
    await SessionService.clearSession();
    AppState.clearSession();

    if (!context.mounted) return;
    _showLogoutSuccess(context);
  }

  // --- ʟᴏɢᴏᴜᴛ ꜱᴜᴄᴄᴇꜱꜱ ᴍᴏᴅᴀʟ ---
  void _showLogoutSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF2D936C),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Logged Out",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You have been successfully logged out.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello,",
                style: TextStyle(
                  fontFamily: AppFonts.avenir,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              // display logged in user's name from AppState
              Text(
                "${AppState.userName}!",
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E4F4F),
                ),
              ),
            ],
          ),
          // --- ᴛʀɪɢɢᴇʀ ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ ᴏɴ ᴛᴀᴘ ---
          const Spacer(),
          IconButton(
            onPressed: () => _showLogoutConfirmation(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _InventoryStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const _InventoryStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF5E8B7E), Color(0xFF76BA99)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.figtree,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontFamily: AppFonts.poppins,
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncfusionCalendarCard extends StatelessWidget {
  const _SyncfusionCalendarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF35524A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SfCalendarTheme(
        data: SfCalendarThemeData(backgroundColor: Colors.transparent),
        child: SfCalendar(
          view: CalendarView.month,
          showNavigationArrow: true,
          headerHeight: 50,
          backgroundColor: Colors.transparent,
          headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.left,
            backgroundColor: Colors.transparent,
            textStyle: TextStyle(
              fontFamily: AppFonts.poppins,
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          viewHeaderStyle: const ViewHeaderStyle(
            backgroundColor: Colors.transparent,
            dayTextStyle: TextStyle(
              fontFamily: AppFonts.avenir,
              color: Color(0xFF76BA99),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          monthViewSettings: const MonthViewSettings(
            showTrailingAndLeadingDates: false,
            monthCellStyle: MonthCellStyle(
              backgroundColor: Colors.transparent,
              textStyle: TextStyle(
                fontFamily: AppFonts.figtree,
                color: Colors.white,
                fontSize: 13,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          todayHighlightColor: const Color(0xFF76BA99),
          selectionDecoration: BoxDecoration(
            color: const Color(0xFF76BA99).withOpacity(0.3),
            border: Border.all(color: const Color(0xFF76BA99), width: 2),
            shape: BoxShape.circle,
          ),
          cellBorderColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.poppins,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

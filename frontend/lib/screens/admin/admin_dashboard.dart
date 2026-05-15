import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:frontend/theme/text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../services/dashboard_service.dart';
import '../../utils/app_state.dart';
import 'admin_inventory.dart';
import 'staff_list_screen.dart';
import 'admin_profile_screen.dart';
import '../../services/notification_service.dart';
import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = -1;

  void _onItemTapped(int index) {
    if (index == 4) {
      _showLogoutConfirmation(context);
      return;
    }
    setState(() {
      if (index == 0)
        _selectedIndex = 0;
      else if (index == 1)
        _selectedIndex = 1;
      else if (index == 2)
        _selectedIndex = -1;
      else if (index == 3)
        _selectedIndex = 2;
    });
  }

  // calls backend logout then clears session and navigates to login
  Future<void> _performLogout() async {
    await AuthService.logout(AppState.token!);
    await SessionService.clearSession();
    AppState.clearSession();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.help_outline_rounded, color: Color(0xFF35524A), size: 60),
                const SizedBox(height: 16),
                const Text("Logout Session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close confirm dialog
                        _performLogout();       // call backend then navigate
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35524A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: _buildBody(),
        ),
        bottomNavigationBar: _MovingCircleNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const AdminInventoryScreen(key: ValueKey('Inventory'), isSubPage: true);
      case 1:
        return const StaffListScreen(key: ValueKey('StaffList'), isSubPage: true);
      case 2:
        return const AdminProfileScreen(key: ValueKey('Profile'), isSubPage: true);
      default:
        return _DashboardContent(
          key: const ValueKey('Dashboard'),
          onViewStaff: () => _onItemTapped(1),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD CONTENT - fetches real sales and active shift data from backend
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardContent extends StatefulWidget {
  final VoidCallback onViewStaff;
  const _DashboardContent({super.key, required this.onViewStaff});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  String? _errorMessage;

  double _dailySales = 0;
  double _monthlySales = 0;
  List<Map<String, dynamic>> _activeShifts = [];

  // holds the stream subscription so we can cancel it on dispose to prevent memory leaks
  StreamSubscription<Map<String, dynamic>>? _notifSubscription;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();

    // subscribe to real-time notifications — connection was already opened in login.dart
    // store subscription so it can be cancelled on dispose
    _notifSubscription = NotificationService.notificationStream.listen((notification) {
      if (!mounted) return;
      _showNotificationBanner(notification);
    });
  }


  @override
  void dispose() {
    // cancel subscription to prevent calling setState on a disposed widget
    _notifSubscription?.cancel();
    super.dispose();
  }

  // show a floating snackbar when a real-time notification arrives
  void _showNotificationBanner(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Notification',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF35524A),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DashboardService.getAdminDashboard();

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      setState(() {
        _dailySales   = double.tryParse(data['dailySales'].toString())   ?? 0;
        _monthlySales = double.tryParse(data['monthlySales'].toString()) ?? 0;
        _activeShifts = (data['activeShifts'] as List)
            .map((s) => Map<String, dynamic>.from(s))
            .where((s) => s['role_name'] != 'Admin')
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            _Header(onRefresh: _fetchDashboard),
            const SizedBox(height: 12.0),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              )
            else ...[
              SizedBox(
                height: 90.0,
                child: _SalesCard(
                  title: 'Daily Sales Report',
                  amount: '₱ ${_dailySales.toStringAsFixed(2)}',
                  subtitle: 'as of today',
                  isMonthly: false,
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 90.0,
                child: _SalesCard(
                  title: 'Monthly Sales Report',
                  amount: '₱ ${_monthlySales.toStringAsFixed(2)}',
                  subtitle: 'for this month',
                  isMonthly: true,
                ),
              ),
              const SizedBox(height: 8.0),
              const _CalendarCard(),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 160.0,
                child: _ActiveStaffCard(
                  activeShifts: _activeShifts,
                  onViewMore: widget.onViewStaff,
                ),
              ),
            ],
            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER - uses AppState.userName from logged‑in admin
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello,', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2E4F4F), fontWeight: FontWeight.w400)),
                Text(
                  '${AppState.userName}!',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2E4F4F)),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 25, color: Colors.grey.shade300),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 20),
                ),
                Positioned(
                  top: 8, right: 10,
                  child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SALES CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SalesCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final bool isMonthly;

  const _SalesCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B7F), Color(0xFF6CCC97)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: isMonthly ? _BarPainter() : _RingPainter()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: isMonthly ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: isMonthly ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(amount, style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.5, height: 1.1)),
                  ),
                  const SizedBox(height: 1),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(30)..style = PaintingStyle.stroke..strokeWidth = 14;
    final cx = size.width * 0.85;
    final cy = size.height * 0.50;
    canvas.drawCircle(Offset(cx, cy), size.height * 0.40, paint);
    canvas.drawCircle(Offset(cx, cy), size.height * 0.70, paint);
  }
  @override bool shouldRepaint(_) => false;
}

class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(30)..style = PaintingStyle.fill;
    const heights = [0.5, 0.8, 0.4, 0.9, 0.6];
    const barW = 14.0, gapW = 6.0, startX = 15.0;
    for (int i = 0; i < heights.length; i++) {
      final barH = size.height * heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + i * (barW + gapW), size.height - barH, barW, barH),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR CARD
// ─────────────────────────────────────────────────────────────────────────────
class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF35524A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
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
            textStyle: TextStyle(fontFamily: AppFonts.poppins, color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          viewHeaderStyle: const ViewHeaderStyle(
            backgroundColor: Colors.transparent,
            dayTextStyle: TextStyle(fontFamily: AppFonts.avenir, color: Color(0xFF76BA99), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          monthViewSettings: const MonthViewSettings(
            showTrailingAndLeadingDates: false,
            monthCellStyle: MonthCellStyle(
              backgroundColor: Colors.transparent,
              textStyle: TextStyle(fontFamily: AppFonts.figtree, color: Colors.white, fontSize: 13),
              todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE STAFF CARD – uses real backend data (role_name, full_name, clock_in_timestamp)
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveStaffCard extends StatelessWidget {
  final List<Map<String, dynamic>> activeShifts;
  final VoidCallback onViewMore;

  const _ActiveStaffCard({required this.activeShifts, required this.onViewMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F4F4F), Color(0xFF3FAF9F)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Staff', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: onViewMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text('View More', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black87)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: activeShifts.isEmpty
              ? Center(child: Text('No staff currently on duty', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)))
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: activeShifts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) => _ActiveShiftItem(shift: activeShifts[i]),
                ),
          ),
        ],
      ),
    );
  }
}

class _ActiveShiftItem extends StatelessWidget {
  final Map<String, dynamic> shift;
  const _ActiveShiftItem({required this.shift});

  @override
  Widget build(BuildContext context) {
    final clockIn = shift['clock_in_timestamp']?.toString() ?? '';
    final timeStr = clockIn.isNotEmpty
        ? 'Active since ${clockIn.substring(11, 16)}' // extract HH:mm
        : 'Active';

    return Row(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(shift['role_name']?.toString() ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(shift['full_name']?.toString() ?? '', 
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11),
                overflow: TextOverflow.ellipsis, maxLines: 1,
              ),
              Text(timeStr, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: const Color(0xFF324A4A), borderRadius: BorderRadius.circular(5)),
              child: const Icon(Icons.person, color: Colors.white38, size: 18),
            ),
            Positioned(
              top: 2, right: 2,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOVING CIRCLE NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class _MovingCircleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _MovingCircleNavBar({required this.selectedIndex, required this.onItemSelected});

  int get activeIndex {
    if (selectedIndex == 0) return 0;
    if (selectedIndex == 1) return 1;
    if (selectedIndex == -1) return 2;
    if (selectedIndex == 2) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 5;
          final targetX = (activeIndex * itemWidth) + (itemWidth / 2);
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: targetX),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            builder: (context, x, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 65,
                  child: CustomPaint(painter: _NavPainter(x)),
                ),
                Positioned(
                  left: x - 30, bottom: 28,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4F4F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Center(child: Icon(_iconFor(activeIndex), color: Colors.white, size: 28)),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 65,
                  child: Row(
                    children: List.generate(5, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => onItemSelected(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Opacity(
                            opacity: activeIndex == i ? 0 : 0.6,
                            child: Icon(_iconFor(i), color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(int i) {
    switch (i) {
      case 0: return Icons.inventory_2_outlined;
      case 1: return Icons.group_outlined;
      case 2: return Icons.grid_view_rounded;
      case 3: return Icons.person_pin_outlined;
      case 4: return Icons.logout_rounded;
      default: return Icons.grid_view_rounded;
    }
  }
}

class _NavPainter extends CustomPainter {
  final double centerX;
  _NavPainter(this.centerX);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E8B7F)..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(centerX - 50, 0)
      ..quadraticBezierTo(centerX - 40, 0, centerX - 36, 12)
      ..arcToPoint(Offset(centerX + 36, 12), radius: const Radius.circular(38), clockwise: false)
      ..quadraticBezierTo(centerX + 40, 0, centerX + 50, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _NavPainter old) => old.centerX != centerX;
}
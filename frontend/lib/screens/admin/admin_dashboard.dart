import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:frontend/theme/text_styles.dart';
import 'admin_inventory.dart';
import 'staff_list_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STAFF DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _StaffData {
  final String role;
  final String name;
  final String time;
  final bool isActive;

  const _StaffData({
    required this.role,
    required this.name,
    required this.time,
    required this.isActive,
  });
}

const List<_StaffData> _sampleStaff = [
  _StaffData(role: 'Cashier',   name: 'Michael John Ramos',     time: 'Active since 2 mins ago', isActive: true),
  _StaffData(role: 'Inventory', name: 'Lyra Bellah Buenavista', time: 'Active since 8 mins ago', isActive: true),
  _StaffData(role: 'Cashier',   name: 'Gwen Tricia Lingling',   time: 'Active since 5 hrs ago',  isActive: false),
  _StaffData(role: 'Cashier',   name: 'Gwen Tricia Aman',       time: 'Off Duty',                isActive: false),
];

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
      if      (index == 0) _selectedIndex = 0;
      else if (index == 1) _selectedIndex = 1;
      else if (index == 2) _selectedIndex = -1;
      else if (index == 3) _selectedIndex = 2;
    });
  }

  // --- ʟᴏɢᴏᴜᴛ ᴄᴏɴꜰɪʀᴍᴀᴛɪᴏɴ ᴅɪᴀʟᴏɢ ---
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close confirm
                        _showLogoutSuccess(context);
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

  // --- ʟᴏɢᴏᴜᴛ ꜱᴜᴄᴄᴇꜱꜱ ᴍᴏᴅᴀʟ ---
  void _showLogoutSuccess(BuildContext context) {
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
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2D936C), size: 60),
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
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35524A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
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
      case 0: return const AdminInventoryScreen(key: ValueKey('Inventory'), isSubPage: true);
      case 1: return const StaffListScreen(key: ValueKey('StaffList'), isSubPage: true);
      case 2: return const PlaceholderPage(key: ValueKey('Profile'), title: 'Admin Profile');
      default:
        return _DashboardContent(
          key: const ValueKey('Dashboard'),
          onViewStaff: () => _onItemTapped(1),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD CONTENT
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final VoidCallback onViewStaff;

  const _DashboardContent({super.key, required this.onViewStaff});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            const _Header(),
            const SizedBox(height: 12.0),

            const SizedBox(
              height: 90.0,
              child: _SalesCard(
                title: 'Daily Sales Report',
                amount: '₱ 10,352',
                subtitle: 'as of March 11, 2026',
                isMonthly: false,
              ),
            ),
            const SizedBox(height: 8.0),

            const SizedBox(
              height: 90.0,
              child: _SalesCard(
                title: 'Monthly Sales Report',
                amount: '₱ 37,124',
                subtitle: 'for the month of March',
                isMonthly: true,
              ),
            ),
            const SizedBox(height: 8.0),

            const _CalendarCard(),
            const SizedBox(height: 12.0),

            SizedBox(
              height: 160.0,
              child: _ActiveStaffCard(
                staffList: _sampleStaff,
                onViewMore: onViewStaff,
              ),
            ),

            const SizedBox(height: 100.0), // navClear
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
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
              Text('Russel Marie!',
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
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 20),
            ),
            Positioned(top: 8, right: 10,
              child: Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
            ),
          ]),
        ),
      ]),
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
        child: Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: isMonthly ? _BarPainter() : _RingPainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: isMonthly ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: isMonthly ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(amount,
                    style: GoogleFonts.poppins(
                      fontSize: 30, fontWeight: FontWeight.w600,
                      color: Colors.white, letterSpacing: 1.5, height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
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
    const barW = 14.0; const gapW = 6.0; const startX = 15.0;
    for (int i = 0; i < heights.length; i++) {
      final barH = size.height * heights[i];
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + i * (barW + gapW), size.height - barH, barW, barH),
        const Radius.circular(4),
      ), paint);
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
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: SfCalendarTheme(
        data: SfCalendarThemeData(
          backgroundColor: Colors.transparent,
        ),
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
                fontWeight: FontWeight.bold
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE STAFF CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveStaffCard extends StatelessWidget {
  final List<_StaffData> staffList;
  final VoidCallback onViewMore;

  const _ActiveStaffCard({required this.staffList, required this.onViewMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F4F4F), Color(0xFF3FAF9F)],
          begin: Alignment.bottomLeft, end: Alignment.topRight,
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Active Staff',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: onViewMore,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text('View More',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black87)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: staffList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => _StaffItem(data: staffList[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffItem extends StatelessWidget {
  final _StaffData data;
  const _StaffItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
        child: Center(child: Text(data.role,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10))),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.name,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            Text(data.time, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Stack(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: const Color(0xFF324A4A), borderRadius: BorderRadius.circular(5)),
          child: const Icon(Icons.person, color: Colors.white38, size: 18),
        ),
        Positioned(top: 2, right: 2,
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: data.isActive ? Colors.greenAccent : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ]),
    ]);
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
    if (selectedIndex == 0)  return 0;
    if (selectedIndex == 1)  return 1;
    if (selectedIndex == -1) return 2;
    if (selectedIndex == 2)  return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95, color: Colors.transparent,
      child: LayoutBuilder(builder: (context, constraints) {
        final double itemWidth = constraints.maxWidth / 5;
        final double targetX   = (activeIndex * itemWidth) + (itemWidth / 2);

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetX),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          builder: (context, x, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(bottom: 0, left: 0, right: 0, height: 65,
                  child: CustomPaint(painter: _NavPainter(x))),
              Positioned(left: x - 30, bottom: 28,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4F4F), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Center(child: Icon(_iconFor(activeIndex), color: Colors.white, size: 28)),
                ),
              ),
              Positioned(bottom: 0, left: 0, right: 0, height: 65,
                child: Row(
                  children: List.generate(5, (i) => Expanded(
                    child: GestureDetector(
                      onTap: () => onItemSelected(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(child: Opacity(
                        opacity: activeIndex == i ? 0 : 0.6,
                        child: Icon(_iconFor(i), color: Colors.white, size: 24),
                      )),
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
      }),
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E8B7F)..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(centerX - 50, 0)
      ..quadraticBezierTo(centerX - 40, 0, centerX - 36, 12)
      ..arcToPoint(Offset(centerX + 36, 12), radius: const Radius.circular(38), clockwise: false)
      ..quadraticBezierTo(centerX + 40, 0, centerX + 50, 0)
      ..lineTo(size.width, 0)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavPainter old) => old.centerX != centerX;
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.construction, size: 64, color: Color(0xFF2E8B7F)),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2E4F4F))),
      ],
    )),
  );
}

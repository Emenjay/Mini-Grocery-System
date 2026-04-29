import 'package:flutter/material.dart';
import '../admin/staff_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Floating Action Button
      floatingActionButton: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF2E4F4F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2E8B7F),
        height: 60,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavIcon(icon: Icons.inventory_2_outlined, route: '/admin-inventory'),
            _NavIcon(icon: Icons.group_outlined, route: '/staff-list'),
            SizedBox(width: 48), // Spacer for FAB (for now wala pa adtunan)
            _NavIcon(icon: Icons.person_pin_outlined, route: '/admin-profile'),
            _NavIcon(icon: Icons.logout_rounded, route: '/'),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _Header(),
              const SizedBox(height: 16),

              // DAILY SALES
              const _SalesCard(
                title: "Daily Sales Report",
                amount: "₱ 10, 352",
                subtitle: "as of March 11, 2026",
                alignRight: false,
                isMonthly: false,
              ),

              const SizedBox(height: 12),

              // MONTHLY SALES
              const _SalesCard(
                title: "Monthly Sales Report",
                amount: "₱ 37, 124",
                subtitle: "for the month of March",
                alignRight: false,
                isMonthly: true,
              ),

              const SizedBox(height: 16),

              // CALENDAR
              const _CalendarCard(),

              const SizedBox(height: 16),

              // ACTIVE STAFF
              const _ActiveStaffCard(),

              const SizedBox(height: 24), // Padding for BottomBar
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String route;

  const _NavIcon({
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      icon: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 10),
          // Vertical Divider - Smaller
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello,", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                "Russel Marie!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4F4F)),
              ),
            ],
          ),
          const Spacer(),
          // Notification
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 24),
                ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final bool alignRight;
  final bool isMonthly;

  const _SalesCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.alignRight,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B7F), Color(0xFF3FAF9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: isMonthly
                  ? CustomPaint(painter: _BarPainter())
                  : CustomPaint(painter: _RingPainter()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    final center = Offset(size.width * 0.85, size.height * 0.4);
    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 65, paint);
    canvas.drawCircle(center, 90, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final bars = [0.7, 0.4, 0.6, 0.3, 0.5, 0.2];
    double barWidth = 16;
    double spacing = 8;
    double totalWidth = bars.length * (barWidth + spacing) - spacing;

    double startX = size.width - totalWidth - 20;

    for (var hFactor in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, size.height * (1 - hFactor), barWidth, size.height * hFactor),
          const Radius.circular(4),
        ),
        paint,
      );
      startX += barWidth + spacing;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final days = ["S", "M", "T", "W", "T", "F", "S"];
    final dates = List.generate(31, (index) => index + 1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF324A4A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("March 2026",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  _CalNavBtn(icon: Icons.arrow_back_ios_rounded),
                  SizedBox(width: 8),
                  _CalNavBtn(icon: Icons.arrow_forward_ios_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((d) => Expanded(
              child: Center(
                child: Text(d,
                    style: const TextStyle(color: Color(0xFF3FAF9F), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isToday = date == 11;
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF2E8B7F) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("$date",
                      style: TextStyle(
                          color: isToday ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  const _CalNavBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 12, color: Colors.black87),
    );
  }
}

class _ActiveStaffCard extends StatelessWidget {
  const _ActiveStaffCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F4F4F), Color(0xFF3FAF9F)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active Staff",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(  
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text("View More", style: TextStyle(fontSize: 10, color: Colors.black87)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _StaffItem(role: "Cashier", name: "Michael John Ramos", time: "Active since 2 minutes ago"),
          const SizedBox(height: 12),
          const _StaffItem(role: "Inventory", name: "Lyra Bellah Buenavista", time: "Active since 8 minutes ago"),
          const SizedBox(height: 12),
          const _StaffItem(role: "Helper", name: "Gwen Tricia Lingaling", time: "Active since 5 hours ago"),
        ],
      ),
    );
  }
}

class _StaffItem extends StatelessWidget {
  final String role;
  final String name;
  final String time;

  const _StaffItem({required this.role, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Role Badge
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ),
        const SizedBox(width: 12),
        // Name and Time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(time, style: const TextStyle(color: Colors.white70, fontSize: 8)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Profile placeholder with dot
        Stack(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFF324A4A), borderRadius: BorderRadius.circular(4)),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              ),
            )
          ],
        ),
      ],
    );
  }
}






